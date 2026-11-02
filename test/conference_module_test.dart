import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/data/conference/conference_seed_data.dart';
import 'package:vowora/models/conference/conference_event.dart';
import 'package:vowora/services/conference_repository.dart';
import 'package:vowora/widgets/conference_progress_indicator.dart';

void main() {
  testWidgets('all six conference steps fit in the progress indicator', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(18),
            child: ConferenceProgressIndicator(
              labels: ConferenceServiceCategory.steps
                  .map((step) => step.label)
                  .toList(),
              currentIndex: 0,
              bookedCategories: const {},
              skippedCategories: const {},
              onStepSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Step 1 of 6'), findsOneWidget);
    expect(find.text('Halls'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Decor'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
  });

  group('Conference planning calculations', () {
    test('conference codes are exactly five digits', () {
      for (var index = 0; index < 100; index++) {
        expect(
          ConferenceRepository.generateConferenceCode(),
          matches(RegExp(r'^\d{5}$')),
        );
      }
    });

    test('food quantities are independent and calculate per item', () {
      final total = ConferenceOrderMath.foodTotal([
        {'unit_price': 250, 'quantity': 20},
        {'unit_price': 40, 'quantity': 20},
        {'unit_price': 80, 'quantity': 10},
      ]);

      expect(total, 6600);
    });

    test('transport calculates price by quantity and rental days', () {
      final total = ConferenceOrderMath.transportTotal([
        {'price_per_day': 8000, 'quantity': 2, 'days': 2},
        {'price_per_day': 12000, 'quantity': 1, 'days': 2},
      ]);

      expect(total, 56000);
    });

    test('the service workflow contains all six categories in order', () {
      expect(ConferenceServiceCategory.steps.map((step) => step.key).toList(), [
        'hall',
        'food',
        'sound',
        'decoration',
        'photography',
        'transportation',
      ]);
    });

    test('seed adapter preserves ten demo providers per category', () {
      expect(ConferenceSeedData.halls, hasLength(10));
      expect(ConferenceSeedData.foods, hasLength(10));
      expect(ConferenceSeedData.sounds, hasLength(10));
      expect(ConferenceSeedData.decorations, hasLength(10));
      expect(ConferenceSeedData.photography, hasLength(10));
      expect(ConferenceSeedData.transport, hasLength(10));
      expect(ConferenceSeedData.halls.first['id'], 'hall_01');
      expect(ConferenceSeedData.transport.last['id'], 'transport_10');
    });
  });
}
