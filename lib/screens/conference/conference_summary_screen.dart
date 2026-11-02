import 'package:flutter/material.dart';

import '../../models/conference/conference_event.dart';
import '../../models/conference/conference_service_booking.dart';
import '../../services/conference_repository.dart';
import 'conference_invitation_screen.dart';
import 'conference_wizard_screen.dart';

class ConferenceSummaryScreen extends StatefulWidget {
  const ConferenceSummaryScreen({super.key, required this.conference});

  final ConferenceEvent conference;

  @override
  State<ConferenceSummaryScreen> createState() =>
      _ConferenceSummaryScreenState();
}

class _ConferenceSummaryScreenState extends State<ConferenceSummaryScreen> {
  late ConferenceEvent _conference;
  late Future<List<ConferenceServiceBooking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _conference = widget.conference;
    _reload();
  }

  void _reload() {
    _bookingsFuture = ConferenceRepository.getBookings(_conference);
  }

  Future<void> _edit(int index) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConferenceWizardScreen(
          conference: _conference,
          initialStep: index,
          returnToSummary: true,
        ),
      ),
    );
    if (mounted) setState(_reload);
  }

  Future<void> _cancel(ConferenceServiceBooking booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this service?'),
        content: Text('Cancel ${booking.providerName} from the conference?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep booking'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
    if (shouldCancel != true) return;
    try {
      await ConferenceRepository.cancelBooking(_conference, booking);
      if (mounted) {
        setState(_reload);
        _showMessage('Booking cancelled.');
      }
    } catch (error) {
      if (mounted) _showMessage('Could not cancel booking: $error');
    }
  }

  Future<void> _changeDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      initialDate: _conference.eventDate.isBefore(today)
          ? today
          : _conference.eventDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (selected == null) return;
    try {
      final updated = await ConferenceRepository.updateConferenceDate(
        _conference,
        selected,
      );
      if (!mounted) return;
      setState(() {
        _conference = updated;
        _reload();
      });
      _showMessage('Conference date updated.');
    } catch (error) {
      if (mounted) _showMessage('Could not update date: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF3E2C26);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        foregroundColor: text,
        elevation: 0,
        title: const Text('Conference summary'),
        actions: [
          IconButton(
            tooltip: 'Make invitation',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ConferenceInvitationScreen(conference: _conference),
              ),
            ),
            icon: const Icon(Icons.mail_outline_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<ConferenceServiceBooking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load conference bookings.'),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF8A7A75),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => setState(_reload),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final bookings = snapshot.data ?? [];
          final total = bookings.fold<num>(
            0,
            (sum, booking) => sum + booking.totalPrice,
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              _conferenceInfo(),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Selected services',
                      style: TextStyle(
                        color: text,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            ConferenceWizardScreen(conference: _conference),
                      ),
                    ),
                    child: const Text('Continue planning'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (
                var index = 0;
                index < ConferenceServiceCategory.steps.length;
                index++
              )
                _serviceRow(
                  index,
                  ConferenceServiceCategory.steps[index],
                  _bookingForCategory(
                    bookings,
                    ConferenceServiceCategory.steps[index].key,
                  ),
                ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E2C26),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Estimated grand total',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Text(
                      '৳${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (_conference.isLocalOnly) ...[
                const SizedBox(height: 12),
                const Text(
                  'Guest event and service selections are saved on this device only. '
                  'They are estimates, not provider-confirmed bookings, and are not synced to Supabase.',
                  style: TextStyle(color: Color(0xFF8A7A75), fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _conferenceInfo() {
    final event = _conference;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9DED5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              color: Color(0xFF3E2C26),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (event.slogan.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.slogan,
              style: const TextStyle(color: Color(0xFF8A7A75)),
            ),
          ],
          const Divider(height: 26),
          _infoLine('Date', _date(event.eventDate)),
          _infoLine('Organizer', event.organizerName),
          _infoLine('Email', event.organizerEmail),
          _infoLine('Location', event.location),
          _infoLine('Conference code', event.code),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _changeDate,
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('Change date'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: Text(label, style: const TextStyle(color: Color(0xFF8A7A75))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF3E2C26),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _serviceRow(
    int index,
    ConferenceServiceCategory category,
    ConferenceServiceBooking? booking,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE9DED5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 8, 13),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.label,
                    style: const TextStyle(
                      color: Color(0xFF3E2C26),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking == null
                        ? 'Not selected'
                        : '${booking.providerName} · ${booking.packageName}',
                    style: const TextStyle(
                      color: Color(0xFF8A7A75),
                      fontSize: 12,
                    ),
                  ),
                  if (booking != null) ...[
                    if (_selectionDescription(booking).isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        _selectionDescription(booking),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6D625E),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      '৳${booking.totalPrice.toStringAsFixed(0)} · ${booking.status}',
                      style: const TextStyle(
                        color: Color(0xFF3E2C26),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (booking != null)
              IconButton(
                tooltip: 'Cancel service',
                onPressed: () => _cancel(booking),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFF9A5E4E),
                ),
              ),
            IconButton(
              tooltip: booking == null ? 'Choose service' : 'Edit service',
              onPressed: () => _edit(index),
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB88A68),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ConferenceServiceBooking? _bookingForCategory(
    List<ConferenceServiceBooking> bookings,
    String category,
  ) {
    for (final booking in bookings) {
      if (booking.category == category) return booking;
    }
    return null;
  }

  String _selectionDescription(ConferenceServiceBooking booking) {
    if (booking.category == 'food') {
      final items = booking.selectionDetails['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((item) => '${item['name']} × ${item['quantity']}')
            .join(' · ');
      }
    }
    if (booking.category == 'transportation') {
      final vehicles = booking.selectionDetails['vehicles'];
      if (vehicles is List) {
        return vehicles
            .whereType<Map>()
            .map(
              (item) =>
                  '${item['name']} × ${item['quantity']} for ${item['days']} day(s)',
            )
            .join(' · ');
      }
    }
    final details = booking.selectionDetails['package_details'];
    if (details is String && details.isNotEmpty) return details;
    final inclusions = booking.selectionDetails['inclusions'];
    return inclusions is List ? inclusions.join(', ') : '';
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}
