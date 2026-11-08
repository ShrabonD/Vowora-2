import 'package:flutter_test/flutter_test.dart';
import 'package:vowora/providers/auth_provider.dart';

void main() {
  group('MFA Auth State & Verification Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    test('Initial AuthProvider state handles MFA flags cleanly', () {
      expect(authProvider.needsMfaVerification, isFalse);
      expect(authProvider.isEnrollingMfa, isFalse);
      expect(authProvider.mfaFactorId, null);
    });

    test('Starting MFA enrollment sets enrollment mode flags', () {
      authProvider.startMfaEnrollmentMode();
      expect(authProvider.isEnrollingMfa, isTrue);
      expect(authProvider.needsMfaVerification, isFalse);
    });

    test('Completing MFA enrollment mode resets enrollment state', () {
      authProvider.startMfaEnrollmentMode();
      expect(authProvider.isEnrollingMfa, isTrue);

      authProvider.completeMfaEnrollmentMode();
      expect(authProvider.isEnrollingMfa, isFalse);
      expect(authProvider.needsMfaVerification, isFalse);
    });

    test('Cancelling MFA enrollment mode resets enrollment state', () {
      authProvider.startMfaEnrollmentMode();
      expect(authProvider.isEnrollingMfa, isTrue);

      authProvider.cancelMfaEnrollmentMode();
      expect(authProvider.isEnrollingMfa, isFalse);
      expect(authProvider.needsMfaVerification, isFalse);
    });
  });
}
