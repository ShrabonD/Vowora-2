// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import '../../core/constants/vowora_constants.dart';
// import '../../core/theme/vowora_theme.dart';
// import '../../models/wedding_ecosystem_models.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/wedding_ecosystem_provider.dart';
// import '../../providers/wedding_wizard_provider.dart';
// import '../../routes/app_routes.dart';
// import '../../widgets/support_card.dart';
// import 'widgets/my_events_section.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   String? _localAvatarPath;

//   Future<void> _pickAvatarImage(AuthProvider authProvider) async {
//     try {
//       final picker = ImagePicker();
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           _localAvatarPath = image.path;
//         });
//         await authProvider.uploadAvatar(image.path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Profile picture updated successfully! 📸'),
//               backgroundColor: VoworaColors.success,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Avatar selected locally: ${e.toString()}'),
//             backgroundColor: VoworaColors.champagneGold,
//           ),
//         );
//       }
//     }
//   }

//   void _showEditProfileModal(BuildContext context, AuthProvider authProvider) {
//     final user = authProvider.userProfile;
//     final nameCtrl = TextEditingController(text: user?.fullName ?? '');
//     final phoneCtrl = TextEditingController(text: user?.phone ?? '');
//     final locationCtrl = TextEditingController(text: user?.location ?? '');

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: const Color(0xFF1A1816),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//             top: 24,
//             left: 20,
//             right: 20,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Edit Profile Details 👤',
//                     style: GoogleFonts.playfairDisplay(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.close_rounded,
//                       color: Colors.white60,
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: nameCtrl,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Full Name',
//                   labelStyle: const TextStyle(color: Colors.white70),
//                   filled: true,
//                   fillColor: Colors.white.withValues(alpha: 0.08),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: phoneCtrl,
//                 keyboardType: TextInputType.phone,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   labelStyle: const TextStyle(color: Colors.white70),
//                   filled: true,
//                   fillColor: Colors.white.withValues(alpha: 0.08),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: locationCtrl,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: InputDecoration(
//                   labelText: 'Location / City',
//                   labelStyle: const TextStyle(color: Colors.white70),
//                   filled: true,
//                   fillColor: Colors.white.withValues(alpha: 0.08),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     await authProvider.updateProfile(
//                       fullName: nameCtrl.text.trim(),
//                       phone: phoneCtrl.text.trim(),
//                       location: locationCtrl.text.trim(),
//                     );
//                     if (context.mounted) {
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Profile updated successfully! ✨'),
//                           backgroundColor: VoworaColors.success,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: VoworaColors.champagneGold,
//                     foregroundColor: const Color(0xFF141210),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: Text(
//                     'Save Profile Changes',
//                     style: GoogleFonts.plusJakartaSans(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E1A17),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//           side: BorderSide(
//             color: VoworaColors.champagneGold.withValues(alpha: 0.3),
//           ),
//         ),
//         title: Row(
//           children: [
//             const Icon(Icons.logout_rounded, color: VoworaColors.champagneGold),
//             const SizedBox(width: 8),
//             Text(
//               'Sign Out?',
//               style: GoogleFonts.playfairDisplay(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'Are you sure you want to sign out of Vowora?',
//           style: GoogleFonts.plusJakartaSans(
//             color: Colors.white70,
//             fontSize: 14,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.plusJakartaSans(color: Colors.white60),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               final authProvider = Provider.of<AuthProvider>(
//                 context,
//                 listen: false,
//               );
//               final wizardProvider = Provider.of<WeddingWizardProvider>(
//                 context,
//                 listen: false,
//               );

//               // 1. Instant Navigation to Login Page on 1 Click
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 AppRoutes.login,
//                 (route) => false,
//               );

//               // 2. Clear Session & State in Background
//               authProvider.logout();
//               wizardProvider.resetForNewUser();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: VoworaColors.error,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             child: Text(
//               'Sign Out',
//               style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final wizardProvider = Provider.of<WeddingWizardProvider>(context);
//     final ecosystemProvider = Provider.of<WeddingEcosystemProvider>(context);

//     final user = authProvider.userProfile;
//     final booking = wizardProvider.booking;
//     final activeRole = ecosystemProvider.activeRole;

//     return Scaffold(
//       backgroundColor: VoworaColors.darkBackground,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new_rounded,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             if (Navigator.canPop(context)) {
//               Navigator.pop(context);
//             } else {
//               Navigator.pushReplacementNamed(context, AppRoutes.home);
//             }
//           },
//         ),
//         title: Text(
//           'Profile & Settings ⚙️',
//           style: GoogleFonts.playfairDisplay(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.edit_note_rounded,
//               color: VoworaColors.champagneGold,
//             ),
//             tooltip: 'Edit Profile',
//             onPressed: () => _showEditProfileModal(context, authProvider),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/wedding_background.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned.fill(
//             child: Container(color: Colors.black.withValues(alpha: 0.8)),
//           ),
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 1. Profile Avatar & User Header Card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           VoworaColors.champagneGold.withValues(alpha: 0.22),
//                           Colors.black.withValues(alpha: 0.7),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(24),
//                       border: Border.all(
//                         color: VoworaColors.champagneGold.withValues(
//                           alpha: 0.4,
//                         ),
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Avatar with Camera Badge
//                         GestureDetector(
//                           onTap: () => _pickAvatarImage(authProvider),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 width: 90,
//                                 height: 90,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: VoworaColors.champagneGold,
//                                     width: 2.5,
//                                   ),
//                                   color: Colors.white12,
//                                 ),
//                                 child: ClipOval(
//                                   child: _buildAvatarImage(user?.avatarUrl),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(6),
//                                   decoration: const BoxDecoration(
//                                     color: VoworaColors.champagneGold,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.camera_alt_rounded,
//                                     color: Color(0xFF141210),
//                                     size: 16,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 14),

//                         // Name & Role Tag
//                         Text(
//                           user?.fullName.isNotEmpty == true
//                               ? user!.fullName
//                               : 'Wedding Planner',
//                           style: GoogleFonts.playfairDisplay(
//                             color: Colors.white,
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),

//                         // Role Badge Chip
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: VoworaColors.champagneGold.withValues(
//                               alpha: 0.2,
//                             ),
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(
//                               color: VoworaColors.champagneGold.withValues(
//                                 alpha: 0.5,
//                               ),
//                             ),
//                           ),
//                           child: Text(
//                             '👑 ${_getRoleName(activeRole)}',
//                             style: GoogleFonts.plusJakartaSans(
//                               color: VoworaColors.champagneGold,
//                               fontSize: 11,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         Text(
//                           user?.email ?? 'planner@vowora.app',
//                           style: GoogleFonts.plusJakartaSans(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                         if (user?.phone.isNotEmpty == true ||
//                             user?.location.isNotEmpty == true)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               '📍 ${user?.location ?? 'Dhaka'} • 📞 ${user?.phone ?? ''}',
//                               style: GoogleFonts.plusJakartaSans(
//                                 color: VoworaColors.champagneGold,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // 2. Role Switcher Mode Selector
//                   _sectionHeader('ACTIVE PERSPECTIVE / ROLE'),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _buildRoleTile(
//                         'Client Host',
//                         UserRole.client,
//                         ecosystemProvider,
//                       ),
//                       const SizedBox(width: 8),
//                       _buildRoleTile(
//                         'Guest Mode',
//                         UserRole.guest,
//                         ecosystemProvider,
//                       ),
//                       const SizedBox(width: 8),
//                       _buildRoleTile(
//                         'Vendor',
//                         UserRole.serviceProvider,
//                         ecosystemProvider,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // 3. Active Wedding Summary Card
//                   _sectionHeader('ACTIVE CELEBRATION SUMMARY'),
//                   const SizedBox(height: 8),

//                   if (booking.isConfirmed &&
//                       booking.brideName.trim().isNotEmpty) ...[
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.08),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: VoworaColors.champagneGold.withValues(
//                             alpha: 0.3,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   '${booking.brideName} & ${booking.groomName}',
//                                   style: GoogleFonts.playfairDisplay(
//                                     color: Colors.white,
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 8,
//                                   vertical: 3,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: VoworaColors.champagneGold.withValues(
//                                     alpha: 0.2,
//                                   ),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Text(
//                                   booking.weddingId,
//                                   style: GoogleFonts.plusJakartaSans(
//                                     color: VoworaColors.champagneGold,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             '📍 ${booking.selectedVenue?.name ?? 'Venue Selected'} • 📅 ${booking.daysUntilWedding} Days Remaining',
//                             style: GoogleFonts.plusJakartaSans(
//                               color: Colors.white70,
//                               fontSize: 11,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: ElevatedButton.icon(
//                                   onPressed: () {
//                                     Navigator.pushNamed(
//                                       context,
//                                       AppRoutes.weddingDashboard,
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: VoworaColors.champagneGold,
//                                     foregroundColor: Colors.black,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 8,
//                                     ),
//                                   ),
//                                   icon: const Icon(
//                                     Icons.dashboard_rounded,
//                                     size: 16,
//                                   ),
//                                   label: const Text('Dashboard'),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               OutlinedButton.icon(
//                                 onPressed: () {
//                                   Navigator.pushNamed(
//                                     context,
//                                     AppRoutes.joinWedding,
//                                   );
//                                 },
//                                 style: OutlinedButton.styleFrom(
//                                   foregroundColor: Colors.white,
//                                   side: const BorderSide(color: Colors.white38),
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 8,
//                                   ),
//                                 ),
//                                 icon: const Icon(
//                                   Icons.qr_code_scanner_rounded,
//                                   size: 16,
//                                 ),
//                                 label: const Text('Join Event'),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ] else ...[
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.05),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: VoworaColors.champagneGold.withValues(
//                             alpha: 0.3,
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'No Active Event Created Yet 💍',
//                             style: GoogleFonts.playfairDisplay(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Start planning your wedding in 9 easy steps.',
//                             style: GoogleFonts.plusJakartaSans(
//                               color: Colors.white60,
//                               fontSize: 11,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 wizardProvider.startNewBookingWizard();
//                                 Navigator.pushNamed(
//                                   context,
//                                   AppRoutes.weddingManager,
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: VoworaColors.champagneGold,
//                                 foregroundColor: Colors.black,
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 8,
//                                 ),
//                               ),
//                               icon: const Icon(
//                                 Icons.add_circle_outline_rounded,
//                                 size: 16,
//                               ),
//                               label: const Text('+ Create Your Wedding'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 24),

//                   // 4. Account Settings Menu List
//                   _sectionHeader('ACCOUNT & SETTINGS'),
//                   const SizedBox(height: 8),

//                   _settingMenuTile(
//                     icon: Icons.person_outline_rounded,
//                     title: 'Edit Personal Information',
//                     subtitle: 'Update name, phone number & location',
//                     onTap: () => _showEditProfileModal(context, authProvider),
//                   ),
//                   _settingMenuTile(
//                     icon: Icons.storefront_rounded,
//                     title: 'Vendor Marketplace & Bookings',
//                     subtitle: 'Browse photographers, caterers & decorators',
//                     onTap: () => Navigator.pushNamed(
//                       context,
//                       AppRoutes.serviceProviderMarketplace,
//                     ),
//                   ),
//                   _settingMenuTile(
//                     icon: Icons.photo_library_outlined,
//                     title: 'Wedding Photo Gallery',
//                     subtitle: 'View albums & manage guest moment uploads',
//                     onTap: () =>
//                         Navigator.pushNamed(context, AppRoutes.weddingGallery),
//                   ),
//                   _settingMenuTile(
//                     icon: Icons.access_time_filled_rounded,
//                     title: 'Event Schedule & Timeline',
//                     subtitle: 'View ceremony timeline milestones',
//                     onTap: () =>
//                         Navigator.pushNamed(context, AppRoutes.weddingSchedule),
//                   ),
//                   _settingMenuTile(
//                     icon: Icons.help_outline_rounded,
//                     title: 'Help & 24/7 Support Hotline',
//                     subtitle: 'Get instant assistance for your event',
//                     onTap: () {
//                       showModalBottomSheet(
//                         context: context,
//                         backgroundColor: const Color(0xFF1C1917),
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(24),
//                           ),
//                         ),
//                         builder: (context) => const Padding(
//                           padding: EdgeInsets.all(24),
//                           child: SupportCard(isDark: true),
//                         ),
//                       );
//                     },
//                   ),
//                   _settingMenuTile(
//                     icon: Icons.description_outlined,
//                     title: 'Terms & Privacy Policy',
//                     subtitle: 'View legal terms and data policies',
//                     onTap: () =>
//                         Navigator.pushNamed(context, AppRoutes.termsPrivacy),
//                   ),
//                   const SizedBox(height: 12),
//                   const MyEventsSection(),
//                   const SizedBox(height: 12),

//                   // 5. Sign Out Button
//                   _settingMenuTile(
//                     icon: Icons.logout_rounded,
//                     title: 'Sign Out',
//                     subtitle: 'Log out of your Vowora account',
//                     isDestructive: true,
//                     onTap: () => _showLogoutDialog(context),
//                   ),
//                   const SizedBox(height: 28),

//                   // Footer
//                   Center(
//                     child: Text(
//                       '${VoworaConstants.appName}  ·  v1.0.0',
//                       style: GoogleFonts.plusJakartaSans(
//                         color: Colors.white38,
//                         fontSize: 11,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAvatarImage(String? avatarUrl) {
//     if (_localAvatarPath != null && _localAvatarPath!.isNotEmpty) {
//       return Image.file(File(_localAvatarPath!), fit: BoxFit.cover);
//     }
//     if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
//       if (avatarUrl.startsWith('http')) {
//         return Image.network(
//           avatarUrl,
//           fit: BoxFit.cover,
//           errorBuilder: (c, e, s) => const Icon(
//             Icons.person_rounded,
//             size: 52,
//             color: VoworaColors.champagneGold,
//           ),
//         );
//       } else {
//         return Image.file(File(avatarUrl), fit: BoxFit.cover);
//       }
//     }
//     return const Icon(
//       Icons.person_rounded,
//       size: 52,
//       color: VoworaColors.champagneGold,
//     );
//   }

//   Widget _sectionHeader(String text) {
//     return Text(
//       text,
//       style: GoogleFonts.plusJakartaSans(
//         fontSize: 10.5,
//         fontWeight: FontWeight.bold,
//         color: VoworaColors.champagneGold,
//         letterSpacing: 1.5,
//       ),
//     );
//   }

//   Widget _buildRoleTile(
//     String title,
//     UserRole role,
//     WeddingEcosystemProvider provider,
//   ) {
//     final isSel = provider.activeRole == role;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => provider.setActiveRole(role),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isSel
//                 ? VoworaColors.champagneGold
//                 : Colors.white.withValues(alpha: 0.08),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: isSel ? VoworaColors.champagneGold : Colors.white24,
//             ),
//           ),
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.plusJakartaSans(
//               color: isSel ? const Color(0xFF141210) : Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 11,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _settingMenuTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     bool isDestructive = false,
//   }) {
//     final color = isDestructive ? VoworaColors.error : Colors.white;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: isDestructive
//               ? VoworaColors.error.withValues(alpha: 0.4)
//               : Colors.white.withValues(alpha: 0.12),
//         ),
//       ),
//       child: ListTile(
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isDestructive
//                 ? VoworaColors.error.withValues(alpha: 0.2)
//                 : VoworaColors.champagneGold.withValues(alpha: 0.2),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(
//             icon,
//             size: 20,
//             color: isDestructive
//                 ? VoworaColors.error
//                 : VoworaColors.champagneGold,
//           ),
//         ),
//         title: Text(
//           title,
//           style: GoogleFonts.plusJakartaSans(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: GoogleFonts.plusJakartaSans(
//             fontSize: 11,
//             color: Colors.white60,
//           ),
//         ),
//         trailing: const Icon(
//           Icons.chevron_right_rounded,
//           size: 20,
//           color: Colors.white38,
//         ),
//         onTap: onTap,
//       ),
//     );
//   }

//   String _getRoleName(UserRole role) {
//     switch (role) {
//       case UserRole.client:
//         return 'Client Host';
//       case UserRole.guest:
//         return 'Guest User';
//       case UserRole.serviceProvider:
//         return 'Service Provider';
//       case UserRole.admin:
//         return 'Administrator';
//     }
//   }
// }




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/vowora_constants.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../providers/wedding_wizard_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/support_card.dart';
import 'widgets/my_events_section.dart';

import '../conference/conference_events_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _localAvatarPath;

  Future<void> _pickAvatarImage(AuthProvider authProvider) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _localAvatarPath = image.path;
        });
        await authProvider.uploadAvatar(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully! 📸'),
              backgroundColor: VoworaColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Avatar selected locally: ${e.toString()}'),
            backgroundColor: VoworaColors.champagneGold,
          ),
        );
      }
    }
  }

  void _showEditProfileModal(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.userProfile;
    final nameCtrl = TextEditingController(text: user?.fullName ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final locationCtrl = TextEditingController(text: user?.location ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1816),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
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
                    'Edit Profile Details 👤',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white60),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Location / City',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.updateProfile(
                      fullName: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully! ✨'),
                          backgroundColor: VoworaColors.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VoworaColors.champagneGold,
                    foregroundColor: const Color(0xFF141210),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text(
                    'Save Profile Changes',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1A17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: VoworaColors.champagneGold),
            const SizedBox(width: 8),
            Text(
              'Sign Out?',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of Vowora?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final wizardProvider = Provider.of<WeddingWizardProvider>(context, listen: false);
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              authProvider.logout();
              wizardProvider.resetForNewUser();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VoworaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Sign Out', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final wizardProvider = Provider.of<WeddingWizardProvider>(context);
    final ecosystemProvider = Provider.of<WeddingEcosystemProvider>(context);

    final user = authProvider.userProfile;
    final booking = wizardProvider.booking;
    final activeRole = ecosystemProvider.activeRole;

    return Scaffold(
      backgroundColor: VoworaColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Profile & Settings ⚙️',
          style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: VoworaColors.champagneGold),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileModal(context, authProvider),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.8)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Profile Avatar & User Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VoworaColors.champagneGold.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _pickAvatarImage(authProvider),
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: VoworaColors.champagneGold, width: 2.5),
                                  color: Colors.white12,
                                ),
                                child: ClipOval(child: _buildAvatarImage(user?.avatarUrl)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: VoworaColors.champagneGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF141210), size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          user?.fullName.isNotEmpty == true ? user!.fullName : 'Wedding Planner',
                          style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            '👑 ${_getRoleName(activeRole)}',
                            style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.email ?? 'planner@vowora.app',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                        ),
                        if (user?.phone.isNotEmpty == true || user?.location.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '📍 ${user?.location ?? 'Dhaka'} • 📞 ${user?.phone ?? ''}',
                              style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Role Switcher
                  _sectionHeader('ACTIVE PERSPECTIVE / ROLE'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildRoleTile('Client Host', UserRole.client, ecosystemProvider),
                      const SizedBox(width: 8),
                      _buildRoleTile('Guest Mode', UserRole.guest, ecosystemProvider),
                      const SizedBox(width: 8),
                      _buildRoleTile('Vendor', UserRole.serviceProvider, ecosystemProvider),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Active Wedding Summary Card
                  _sectionHeader('ACTIVE CELEBRATION SUMMARY'),
                  const SizedBox(height: 8),

                  if (booking.isConfirmed && booking.brideName.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${booking.brideName} & ${booking.groomName}',
                                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: VoworaColors.champagneGold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  booking.weddingId,
                                  style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '📍 ${booking.selectedVenue?.name ?? 'Venue Selected'} • 📅 ${booking.daysUntilWedding} Days Remaining',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.weddingDashboard),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: VoworaColors.champagneGold,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  icon: const Icon(Icons.dashboard_rounded, size: 16),
                                  label: const Text('Dashboard'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.joinWedding),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white38),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                                label: const Text('Join Event'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No Active Event Created Yet 💍', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Start planning your wedding in 9 easy steps.', style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 11)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                wizardProvider.startNewBookingWizard();
                                Navigator.pushNamed(context, AppRoutes.weddingManager);
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 8)),
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                              label: const Text('+ Create Your Wedding'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  const ConferenceEventsSection(),
                  const SizedBox(height: 24),

                  // 4. Account Settings Menu List
                  _sectionHeader('ACCOUNT & SETTINGS'),
                  const SizedBox(height: 8),

                  _settingMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Personal Information',
                    subtitle: 'Update name, phone number & location',
                    onTap: () => _showEditProfileModal(context, authProvider),
                  ),
                  _settingMenuTile(
                    icon: Icons.storefront_rounded,
                    title: 'Vendor Marketplace & Bookings',
                    subtitle: 'Browse photographers, caterers & decorators',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.serviceProviderMarketplace),
                  ),
                  _settingMenuTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Wedding Photo Gallery',
                    subtitle: 'View albums & manage guest moment uploads',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.weddingGallery),
                  ),
                  _settingMenuTile(
                    icon: Icons.access_time_filled_rounded,
                    title: 'Event Schedule & Timeline',
                    subtitle: 'View ceremony timeline milestones',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.weddingSchedule),
                  ),
                  _settingMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & 24/7 Support Hotline',
                    subtitle: 'Get instant assistance for your event',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF1C1917),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (context) => const Padding(
                          padding: EdgeInsets.all(24),
                          child: SupportCard(isDark: true),
                        ),
                      );
                    },
                  ),
                  _settingMenuTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Privacy Policy',
                    subtitle: 'View legal terms and data policies',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.termsPrivacy),
                  ),
                  const SizedBox(height: 12),
                  const MyEventsSection(),
                  const SizedBox(height: 12),

                  // 5. Sign Out Button
                  _settingMenuTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of your Vowora account',
                    isDestructive: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                  const SizedBox(height: 28),

                  Center(
                    child: Text(
                      '${VoworaConstants.appName}  ·  v1.0.0',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String? avatarUrl) {
    if (_localAvatarPath != null && _localAvatarPath!.isNotEmpty) {
      return Image.file(File(_localAvatarPath!), fit: BoxFit.cover);
    }
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      if (avatarUrl.startsWith('http')) {
        return Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Icon(Icons.person_rounded, size: 52, color: VoworaColors.champagneGold),
        );
      } else {
        return Image.file(File(avatarUrl), fit: BoxFit.cover);
      }
    }
    return const Icon(Icons.person_rounded, size: 52, color: VoworaColors.champagneGold);
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.bold, color: VoworaColors.champagneGold, letterSpacing: 1.5),
    );
  }

  Widget _buildRoleTile(String title, UserRole role, WeddingEcosystemProvider provider) {
    final isSel = provider.activeRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setActiveRole(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSel ? VoworaColors.champagneGold : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSel ? VoworaColors.champagneGold : Colors.white24),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: isSel ? const Color(0xFF141210) : Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
        ),
      ),
    );
  }

  Widget _settingMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? VoworaColors.error : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDestructive ? VoworaColors.error.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? VoworaColors.error.withValues(alpha: 0.2) : VoworaColors.champagneGold.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: isDestructive ? VoworaColors.error : VoworaColors.champagneGold),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        subtitle: Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.client: return 'Client Host';
      case UserRole.guest: return 'Guest User';
      case UserRole.serviceProvider: return 'Service Provider';
      case UserRole.admin: return 'Administrator';
    }
  }
}