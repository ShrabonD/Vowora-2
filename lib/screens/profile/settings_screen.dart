import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/vowora_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/guest_gate_dialog.dart';
import 'mfa_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _eventReminders = true;
  bool _invitationUpdates = true;
  bool _eventAnnouncements = false;
  String _selectedTheme = 'Dark Luxury';
  String _selectedLanguage = 'English (US)';

  void _showChangePasswordModal(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isOAuthUser) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: VoworaColors.darkCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
          ),
          title: Text('Google OAuth Account', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(
            'You signed in using Google OAuth. Password and security options are managed directly through your Google Account.',
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, height: 1.45),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: VoworaColors.darkBackground),
              child: Text('Got It', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VoworaColors.darkCardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 24,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password 🔒',
                        style: GoogleFonts.playfairDisplay(
                          color: VoworaColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: VoworaColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: obscureCurrent,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white60),
                        onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white60),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white60),
                        onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final newPass = newPassCtrl.text.trim();
                        final confirmPass = confirmPassCtrl.text.trim();
                        if (newPass.isEmpty || newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password must be at least 6 characters long.'), backgroundColor: VoworaColors.error),
                          );
                          return;
                        }
                        if (newPass != confirmPass) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New passwords do not match.'), backgroundColor: VoworaColors.error),
                          );
                          return;
                        }
                        final success = await authProvider.updatePassword(newPass);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? 'Password updated successfully! ✨' : (authProvider.errorMessage ?? 'Failed to update password'),
                              ),
                              backgroundColor: success ? VoworaColors.success : VoworaColors.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VoworaColors.champagneGold,
                        foregroundColor: VoworaColors.darkBackground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: Text(
                        'Update Password',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMfaStatusModal(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isGuest) {
      GuestGateDialog.show(
        context,
        onCreateAccount: () => Navigator.pushNamed(context, AppRoutes.signup),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: VoworaColors.darkCardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => const _MfaStatusBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userProfile;

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: VoworaColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            color: VoworaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/wedding_background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Text(
                  'Personalize your experience.',
                  style: GoogleFonts.plusJakartaSans(
                    color: VoworaColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),

                // 1. Account & Preferences Section
                _buildSectionHeader('ACCOUNT & PREFERENCES'),
                const SizedBox(height: 10),
                _buildGlassCard(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: user?.email ?? 'Update profile details',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.personalInformation),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update account security credentials',
                      onTap: () => _showChangePasswordModal(context, authProvider),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: _selectedLanguage,
                      trailing: Text(
                        _selectedLanguage,
                        style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showLanguageDialog(context),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: _selectedTheme,
                      trailing: Text(
                        _selectedTheme,
                        style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showThemeDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Notification Preferences Section
                _buildSectionHeader('NOTIFICATION PREFERENCES'),
                const SizedBox(height: 10),
                _buildGlassCard(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Event Reminders',
                      subtitle: 'Get notified for upcoming ceremony countdowns',
                      value: _eventReminders,
                      onChanged: (val) => setState(() => _eventReminders = val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.mail_outline_rounded,
                      title: 'Invitation Updates',
                      subtitle: 'RSVP responses and guest notifications',
                      value: _invitationUpdates,
                      onChanged: (val) => setState(() => _invitationUpdates = val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.announcement_outlined,
                      title: 'Event Announcements',
                      subtitle: 'Exclusive luxury vendor deals & tips',
                      value: _eventAnnouncements,
                      onChanged: (val) => setState(() => _eventAnnouncements = val),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Privacy & Security Section
                _buildSectionHeader('PRIVACY & SECURITY'),
                const SizedBox(height: 10),
                _buildGlassCard(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Read our data protection policies',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.termsPrivacy),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Event management terms of service',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.termsPrivacy),
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Two-Step Verification (MFA)',
                      subtitle: 'Manage authenticator factors & security',
                      onTap: () => _showMfaStatusModal(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Support & About Section
                _buildSectionHeader('SUPPORT & ABOUT'),
                const SizedBox(height: 10),
                _buildGlassCard(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      subtitle: 'FAQs and user guides',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact support at ${VoworaConstants.supportEmail}', style: GoogleFonts.plusJakartaSans()),
                            backgroundColor: VoworaColors.champagneGold,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Vowora',
                      subtitle: '${VoworaConstants.appName} v1.0.0 (Luxury Edition)',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: VoworaColors.champagneGold,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: VoworaColors.darkCardBackground.withValues(alpha: 0.65),
            border: Border.all(
              color: VoworaColors.champagneGold.withValues(alpha: 0.3),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VoworaColors.champagneGold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: VoworaColors.champagneGold, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        color: VoworaColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: VoworaColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? const Icon(Icons.chevron_right_rounded, color: VoworaColors.textSecondary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: VoworaColors.champagneGold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.35)),
            ),
            child: Icon(icon, color: VoworaColors.champagneGold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    color: VoworaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: VoworaColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: VoworaColors.darkBackground,
            activeTrackColor: VoworaColors.champagneGold,
            inactiveThumbColor: VoworaColors.textSecondary,
            inactiveTrackColor: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withValues(alpha: 0.08),
      indent: 58,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VoworaColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
        ),
        title: Text('Select Language', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English (US)', 'বাংলা (Bangla)', 'Spanish (Español)', 'French (Français)'].map((lang) {
            return ListTile(
              title: Text(lang, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
              trailing: _selectedLanguage == lang ? const Icon(Icons.check, color: VoworaColors.champagneGold) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language updated to $lang'), backgroundColor: VoworaColors.success),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VoworaColors.darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
        ),
        title: Text('Select Appearance', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Dark Luxury', 'Light Elegant', 'System Default'].map((theme) {
            return ListTile(
              title: Text(theme, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
              trailing: _selectedTheme == theme ? const Icon(Icons.check, color: VoworaColors.champagneGold) : null,
              onTap: () {
                setState(() => _selectedTheme = theme);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Appearance updated to $theme'), backgroundColor: VoworaColors.success),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MfaStatusBottomSheet extends StatefulWidget {
  const _MfaStatusBottomSheet();

  @override
  State<_MfaStatusBottomSheet> createState() => _MfaStatusBottomSheetState();
}

class _MfaStatusBottomSheetState extends State<_MfaStatusBottomSheet> {
  bool _isLoading = true;
  List<dynamic> _factors = [];

  @override
  void initState() {
    super.initState();
    _loadFactors();
  }

  Future<void> _loadFactors() async {
    setState(() => _isLoading = true);
    try {
      final factors = await SupabaseService.getVerifiedTotpFactors();
      if (mounted) {
        setState(() {
          _factors = factors;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDisableMfa(String factorId) async {
    final passwordCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: VoworaColors.darkCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: VoworaColors.error.withValues(alpha: 0.5)),
          ),
          title: Text('Disable Two-Step Verification', style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('For security, enter your account password and a current 6-digit authenticator code to disable MFA.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12.5, height: 1.4)),
              const SizedBox(height: 14),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.white, letterSpacing: 4.0),
                decoration: InputDecoration(
                  labelText: '6-Digit Authenticator Code',
                  labelStyle: const TextStyle(color: Colors.white70),
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                setDialogState(() => isLoading = true);
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final isOAuth = authProvider.isOAuthUser;
                  final pass = passwordCtrl.text.trim();
                  final code = codeCtrl.text.trim();

                  if (!isOAuth) {
                    if (pass.isEmpty) {
                      throw Exception('Please enter your account password.');
                    }
                    final reauth = await SupabaseService.reauthenticateUser(pass);
                    if (!reauth) throw Exception('Password reauthentication failed.');
                  }

                  if (code.length != 6) {
                    throw Exception('Please enter a valid 6-digit authenticator code.');
                  }

                  final verified = await SupabaseService.challengeAndVerifyTotpMfa(factorId: factorId, code: code);
                  if (!verified) throw Exception('Incorrect 6-digit authenticator code.');

                  await SupabaseService.unenrollTotpFactor(factorId);
                  if (context.mounted) {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // close bottom sheet
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Two-Step Verification disabled successfully.'), backgroundColor: VoworaColors.success),
                    );
                  }
                } catch (e) {
                  setDialogState(() => isLoading = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: VoworaColors.error),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.error, foregroundColor: Colors.white),
              child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Disable 2FA'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Two-Step Verification (MFA)',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white60),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: VoworaColors.champagneGold)))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _factors.isNotEmpty ? VoworaColors.champagneGold.withValues(alpha: 0.15) : Colors.white10,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _factors.isNotEmpty ? VoworaColors.champagneGold.withValues(alpha: 0.4) : Colors.white24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _factors.isNotEmpty ? Icons.verified_user_rounded : Icons.security_outlined,
                            color: _factors.isNotEmpty ? VoworaColors.champagneGold : Colors.white60,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _factors.isNotEmpty ? 'Protected & Active (${_factors.length} Enrolled)' : 'Two-Step Verification Disabled',
                                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _factors.isNotEmpty ? 'Google Authenticator / Authy linked' : 'Enable 2FA to secure your account',
                                  style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add / Enroll second factor button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const MfaSetupScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VoworaColors.champagneGold,
                          foregroundColor: VoworaColors.darkBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        icon: const Icon(Icons.add_moderator_rounded, size: 18),
                        label: Text(_factors.isNotEmpty ? 'Enroll Second Authenticator Factor' : 'Set Up Two-Step Verification', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                      ),
                    ),

                    if (_factors.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmDisableMfa(_factors.first.id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: VoworaColors.error,
                            side: BorderSide(color: VoworaColors.error.withValues(alpha: 0.5), width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          ),
                          icon: const Icon(Icons.remove_moderator_rounded, size: 18),
                          label: Text('Disable Two-Step Verification', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    // Lost Authenticator Recovery Info Notice
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lost Authenticator Recovery Procedure:',
                            style: GoogleFonts.playfairDisplay(color: VoworaColors.champagneGold, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If you lose access to your authenticator app, account recovery requires verification via our Support Hotline or Admin Edge Function (which securely unenrolls lost factors using Supabase Admin API). Password-only recovery is disabled to prevent unauthorized MFA bypass.',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
        ],
      ),
    );
  }
}
