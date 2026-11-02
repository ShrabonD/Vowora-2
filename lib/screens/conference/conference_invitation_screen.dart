import 'package:flutter/material.dart';

import '../../models/conference/conference_event.dart';
import '../../services/conference_repository.dart';

class ConferenceInvitationScreen extends StatefulWidget {
  const ConferenceInvitationScreen({super.key, required this.conference});

  final ConferenceEvent conference;

  @override
  State<ConferenceInvitationScreen> createState() =>
      _ConferenceInvitationScreenState();
}

class _ConferenceInvitationScreenState
    extends State<ConferenceInvitationScreen> {
  final _numberController = TextEditingController();
  final _scheduleController = TextEditingController();
  final List<String> _guestNumbers = [];
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 12, minute: 0);
  bool _isSaving = false;

  @override
  void dispose() {
    _numberController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _addNumber() {
    final number = _numberController.text.trim();
    if (!RegExp(r'^\+?[0-9][0-9\s()-]{6,18}$').hasMatch(number)) {
      _message('Enter a valid guest mobile number.');
      return;
    }
    final normalized = number.replaceAll(RegExp(r'[\s()-]'), '');
    if (_guestNumbers.contains(normalized)) {
      _message('This number is already on the invitation list.');
      return;
    }
    setState(() {
      _guestNumbers.add(normalized);
      _numberController.clear();
    });
  }

  Future<void> _chooseTime({required bool start}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }

  Future<void> _save() async {
    if (_guestNumbers.isEmpty) {
      _message('Add at least one guest mobile number.');
      return;
    }
    if (_minutes(_endTime) <= _minutes(_startTime)) {
      _message('End time must be later than start time.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ConferenceRepository.saveInvitation(
        event: widget.conference,
        startTime: _startTime.format(context),
        endTime: _endTime.format(context),
        schedule: _scheduleController.text.trim(),
        guestNumbers: List<String>.unmodifiable(_guestNumbers),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invitation saved'),
          content: Text(
            'The invitation draft was saved for ${_guestNumbers.length} guest(s). '
            'No SMS was sent.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _message('Could not save invitation: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF3E2C26);
    final event = widget.conference;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        foregroundColor: text,
        elevation: 0,
        title: const Text('Make Invitation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE9DED5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(event.eventDate)} · ${event.location}',
                  style: const TextStyle(color: Color(0xFF8A7A75)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _chooseTime(start: true),
                  icon: const Icon(Icons.access_time),
                  label: Text('Start ${_startTime.format(context)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _chooseTime(start: false),
                  icon: const Icon(Icons.access_time),
                  label: Text('End ${_endTime.format(context)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _scheduleController,
            minLines: 2,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Event schedule',
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Guest mobile numbers',
            style: TextStyle(
              color: text,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+880 1XXXXXXXXX',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _addNumber(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addNumber,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_guestNumbers.isEmpty)
            const Text(
              'No guests added yet. Contact-book access is not available in the current app dependencies.',
              style: TextStyle(color: Color(0xFF8A7A75), fontSize: 12),
            ),
          for (final number in _guestNumbers)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.phone_outlined),
              title: Text(number),
              trailing: IconButton(
                tooltip: 'Remove guest',
                onPressed: () => setState(() => _guestNumbers.remove(number)),
                icon: const Icon(Icons.close),
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: text,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send Invitation'),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is a saved invitation draft only. SMS delivery is not enabled.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8A7A75), fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
