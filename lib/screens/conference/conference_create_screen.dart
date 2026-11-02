import 'package:flutter/material.dart';

import '../../services/conference_repository.dart';
import 'conference_wizard_screen.dart';

class ConferenceCreateScreen extends StatefulWidget {
  const ConferenceCreateScreen({super.key});

  @override
  State<ConferenceCreateScreen> createState() => _ConferenceCreateScreenState();
}

class _ConferenceCreateScreenState extends State<ConferenceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sloganController = TextEditingController();
  final _organizerController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController(text: 'Dhaka');
  DateTime? _eventDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _sloganController.dispose();
    _organizerController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? today.add(const Duration(days: 14)),
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3E2C26),
            onPrimary: Colors.white,
            surface: Color(0xFFFFFDF9),
            onSurface: Color(0xFF3E2C26),
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      _showMessage('Select an event date to continue.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final event = await ConferenceRepository.createConference(
        title: _titleController.text,
        slogan: _sloganController.text,
        eventDate: _eventDate!,
        organizerName: _organizerController.text,
        organizerEmail: _emailController.text,
        location: _locationController.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ConferenceWizardScreen(conference: event),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Could not save conference: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF3E2C26);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1EA),
        foregroundColor: textColor,
        elevation: 0,
        title: const Text(
          'Create Conference',
          style: TextStyle(color: textColor),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              Text(
                'Start with the details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your conference and provider selections will be saved together.',
                style: TextStyle(color: Color(0xFF8A7A75), height: 1.4),
              ),
              const SizedBox(height: 24),
              _field(
                controller: _titleController,
                label: 'Conference Title',
                validator: _required,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _sloganController,
                label: 'Slogan',
                validator: _required,
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _isSaving ? null : _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Event Date',
                    labelStyle: TextStyle(color: Color(0xFF6E5B54)),
                    floatingLabelStyle: TextStyle(color: textColor),
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                      color: textColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                  child: Text(
                    _eventDate == null
                        ? 'Choose a date'
                        : MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(_eventDate!),
                    style: TextStyle(
                      color: _eventDate == null
                          ? const Color(0xFF8A7A75)
                          : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _organizerController,
                label: 'Organizer Name',
                validator: _required,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _emailController,
                label: 'Organizer Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final requiredError = _required(value);
                  if (requiredError != null) return requiredError;
                  final email = value!.trim();
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                      ? null
                      : 'Enter a valid email address.';
                },
              ),
              const SizedBox(height: 14),
              _field(
                controller: _locationController,
                label: 'City / Location',
                validator: _required,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox.square(
                          dimension: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      style: const TextStyle(color: Color(0xFF3E2C26)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6E5B54)),
        floatingLabelStyle: const TextStyle(color: Color(0xFF3E2C26)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9DED5)),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}
