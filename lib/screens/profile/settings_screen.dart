import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/theme/vowora_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Manage your info from your profile view.', style: GoogleFonts.plusJakartaSans()),
                            backgroundColor: VoworaColors.darkCardBackground,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update account security credentials',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Password reset link sent to your registered email.', style: GoogleFonts.plusJakartaSans()),
                            backgroundColor: VoworaColors.success,
                          ),
                        );
                      },
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
                      title: 'Account Security',
                      subtitle: 'Two-factor authentication & sessions',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Your account is secure with end-to-end encryption.', style: GoogleFonts.plusJakartaSans()),
                            backgroundColor: VoworaColors.success,
                          ),
                        );
                      },
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
            activeColor: VoworaColors.darkBackground,
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
          children: ['English (US)', 'Bengali (বাংলা)', 'Spanish (Español)', 'French (Français)'].map((lang) {
            return ListTile(
              title: Text(lang, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
              trailing: _selectedLanguage == lang ? const Icon(Icons.check, color: VoworaColors.champagneGold) : null,
              onTap: () {
                setState(() => _selectedLanguage = lang);
                Navigator.pop(context);
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
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
