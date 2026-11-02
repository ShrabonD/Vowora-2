import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/vowora_theme.dart';
import '../../models/conference/conference_event.dart';
import '../../models/conference/conference_service_booking.dart';
import '../../services/conference_repository.dart';
import 'c_landingpage.dart';
import 'conference_summary_screen.dart';

class ConferenceEventsSection extends StatefulWidget {
  const ConferenceEventsSection({super.key});

  @override
  State<ConferenceEventsSection> createState() =>
      _ConferenceEventsSectionState();
}

class _ConferenceEventsSectionState extends State<ConferenceEventsSection> {
  late Future<List<ConferenceEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _eventsFuture = ConferenceRepository.getConferences();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionHeader()),
            TextButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ConferenceLandingPage(),
                  ),
                );
                if (mounted) setState(_reload);
              },
              child: Text(
                '+ Add New',
                style: GoogleFonts.plusJakartaSans(
                  color: VoworaColors.champagneGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FutureBuilder<List<ConferenceEvent>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: VoworaColors.champagneGold,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return _messageCard(
                'Conference events could not be loaded.',
                trailing: TextButton(
                  onPressed: () => setState(_reload),
                  child: const Text('Retry'),
                ),
              );
            }
            final events = snapshot.data ?? [];
            if (events.isEmpty) {
              return _messageCard('No conferences created yet.');
            }
            return Column(
              children: events
                  .map((event) => _ConferenceEventCard(event: event))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _sectionHeader() => Text(
    'YOUR EVENTS · CONFERENCE',
    style: GoogleFonts.plusJakartaSans(
      color: VoworaColors.champagneGold,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.1,
    ),
  );

  Widget _messageCard(String message, {Widget? trailing}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class _ConferenceEventCard extends StatefulWidget {
  const _ConferenceEventCard({required this.event});

  final ConferenceEvent event;

  @override
  State<_ConferenceEventCard> createState() => _ConferenceEventCardState();
}

class _ConferenceEventCardState extends State<_ConferenceEventCard> {
  late Future<List<ConferenceServiceBooking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = ConferenceRepository.getBookings(widget.event);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ConferenceSummaryScreen(conference: widget.event),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.business_center_outlined,
                  color: VoworaColors.champagneGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_date(widget.event.eventDate)} · ${widget.event.organizerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code ${widget.event.code}',
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.champagneGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FutureBuilder<List<ConferenceServiceBooking>>(
                      future: _bookingsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Booking progress unavailable',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.orange.shade200,
                              fontSize: 10,
                            ),
                          );
                        }
                        final bookings = snapshot.data ?? [];
                        final total = bookings.fold<num>(
                          0,
                          (sum, booking) => sum + booking.totalPrice,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bookings.length}/6 services · ৳${total.toStringAsFixed(0)} estimated',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                            if (bookings.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              for (final booking in bookings)
                                Text(
                                  '${_categoryLabel(booking.category)}: ${booking.providerName} · ${booking.packageName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';

  String _categoryLabel(String category) => switch (category) {
    'hall' => 'Hall',
    'food' => 'Food',
    'sound' => 'Sound',
    'decoration' => 'Decoration',
    'photography' => 'Photography',
    'transportation' => 'Transport',
    _ => category,
  };
}
