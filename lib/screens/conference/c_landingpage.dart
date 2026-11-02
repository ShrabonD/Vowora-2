// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../routes/app_routes.dart';

// class ConferenceLandingPage extends StatelessWidget {
//   const ConferenceLandingPage({super.key});

//   // Updated services list
//   static const _services = [
//     (
//       title: 'Explore and Book Halls',
//       icon: Icons.roofing_rounded,
//       route: AppRoutes.hallList,
//     ),
//     (
//       title: 'Restaurant and Food',
//       icon: Icons.restaurant_rounded,
//       route: AppRoutes.conferenceFood,
//     ),
//     (
//       title: 'Sounds and Screens',
//       icon: Icons.volume_up_rounded,
//       route: AppRoutes.conferenceSound,
//     ),
//     (
//       title: 'Decorations',
//       icon: Icons.local_florist_rounded,
//       route: AppRoutes.conferenceDecoration,
//     ),
//     (
//       title: 'Photography',
//       icon: Icons.camera_alt_rounded,
//       route: AppRoutes.conferencePhotography,
//     ),
//     (
//       title: 'Transportation',
//       icon: Icons.directions_car_filled_rounded,
//       route: AppRoutes.conferencePhotography, // Update route when ready
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // Colors matching the provided images
//     const Color bgColor = Color(0xFFF8F1EA); // Soft cream background
//     const Color textColor = Color(0xFF3E2C26); // Dark brown text
//     const Color subTextColor = Color(0xFF8A7A75); // Lighter brown text
//     const Color iconBgColor = Color(0xFFF0E6DD); // Light brown for icon backgrounds
//     const Color iconColor = Color(0xFFB88A68); // Bronze/gold icon color

//     return Scaffold(
//       backgroundColor: bgColor,
//       // Custom App Bar to match design
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Conference Studio',
//           style: GoogleFonts.playfairDisplay(
//             color: textColor,
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: textColor),
//             onPressed: () {},
//           ),
//         ],
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- TITLE SECTION ---
//               Row(
//                 children: [
//                   Text(
//                     'Conference Studio',
//                     style: GoogleFonts.playfairDisplay(
//                       color: textColor,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   const Icon(Icons.business_center, color: iconColor, size: 24),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Plan your next big event with ease.',
//                 style: GoogleFonts.plusJakartaSans(
//                   color: subTextColor,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // --- CUSTOM GRADIENT BANNER ---
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24.0),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF4A1C40), // Deep Purple
//                       Color(0xFF7B3A5D), // Magenta
//                       Color(0xFFC55F45), // Orange/Red
//                     ],
//                   ),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: Stack(
//                     children: [
//                       // Decorative Circle (Right)
//                       Positioned(
//                         right: -40,
//                         top: -40,
//                         child: Container(
//                           width: 180,
//                           height: 180,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.08),
//                           ),
//                         ),
//                       ),
//                       // Decorative Circle (Bottom Left)
//                       Positioned(
//                         left: -20,
//                         bottom: -50,
//                         child: Container(
//                           width: 120,
//                           height: 120,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white.withOpacity(0.05),
//                           ),
//                         ),
//                       ),
//                       // Banner Content
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 10, vertical: 4),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                             ),

//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'Plan Your Next\nBig Conference',
//                             style: GoogleFonts.playfairDisplay(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               height: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           // Small Button inside banner
//                           ElevatedButton.icon(
//                             onPressed: () {},
//                             icon: const Icon(Icons.add, size: 16, color: Colors.white),
//                             label: Text(
//                               'Start Planning',
//                               style: GoogleFonts.plusJakartaSans(
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white.withOpacity(0.25),
//                               elevation: 0,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 8),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // --- SERVICES SECTION HEADER ---
//               Text(
//                 'What We Provide',
//                 style: GoogleFonts.playfairDisplay(
//                   color: textColor,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // --- SERVICES GRID ---
//               GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 16,
//                   mainAxisSpacing: 16,
//                   childAspectRatio: 0.95, // Adjusts card height
//                 ),
//                 itemCount: _services.length,
//                 itemBuilder: (context, index) {
//                   final service = _services[index];
//                   return _ServiceCard(
//                     title: service.title,
//                     icon: service.icon,
//                     iconColor: iconColor,
//                     iconBgColor: iconBgColor,
//                     textColor: textColor,
//                     subTextColor: subTextColor,
//                   );
//                 },
//               ),

//               const SizedBox(height: 32),

//               // --- BOTTOM ACTION BUTTON ---
//               SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // TODO: Navigate to the form/creation flow
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                           content: Text('Create Now Flow Coming Soon')),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: textColor, // Dark brown
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     'Create now!!',
//                     style: GoogleFonts.plusJakartaSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- CUSTOM SERVICE CARD WIDGET (NON-CLICKABLE) ---
// class _ServiceCard extends StatelessWidget {
//   const _ServiceCard({
//     required this.title,
//     required this.icon,
//     required this.iconColor,
//     required this.iconBgColor,
//     required this.textColor,
//     required this.subTextColor,
//   });

//   final String title;
//   final IconData icon;
//   final Color iconColor;
//   final Color iconBgColor;
//   final Color textColor;
//   final Color subTextColor;

//   @override
//   Widget build(BuildContext context) {
//     // Using Container instead of InkWell/Material to remove click effects
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: const Color(0xFFF0E6DD), // Very subtle border
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Rounded Icon Container
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: iconBgColor,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(icon, color: iconColor, size: 30),
//           ),
//           const SizedBox(height: 16),
//           // Title
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 12.0),
//             child: Text(
//               title,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.plusJakartaSans(
//                 color: textColor,
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//                 height: 1.2,
//               ),
//             ),
//           ),
//           const SizedBox(height: 6),
//           // Subtitle
//           Text(
//             'Tap to explore',
//             style: GoogleFonts.plusJakartaSans(
//               color: subTextColor,
//               fontSize: 11,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_routes.dart';

class ConferenceLandingPage extends StatelessWidget {
  const ConferenceLandingPage({super.key});

  static const _services = [
    (
      title: 'Halls',
      description: 'Find event spaces sized for your conference.',
      icon: Icons.roofing_rounded,
    ),
    (
      title: 'Restaurant & Food',
      description: 'Plan menus and catering for every guest.',
      icon: Icons.restaurant_rounded,
    ),
    (
      title: 'Sound & Screens',
      description: 'Equip the room for clear, confident presentations.',
      icon: Icons.volume_up_rounded,
    ),
    (
      title: 'Decorations',
      description: 'Create a polished setting for your event.',
      icon: Icons.local_florist_rounded,
    ),
    (
      title: 'Photography',
      description: 'Capture the moments and the message.',
      icon: Icons.camera_alt_rounded,
    ),
    (
      title: 'Transportation',
      description: 'Coordinate guest and team travel.',
      icon: Icons.directions_car_filled_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF8F1EA);
    const Color textColor = Color(0xFF3E2C26);
    const Color subTextColor = Color(0xFF8A7A75);
    const Color iconBgColor = Color(0xFFF0E6DD);
    const Color iconColor = Color(0xFFB88A68);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vowora',
          style: GoogleFonts.playfairDisplay(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Vowora',
                    style: GoogleFonts.playfairDisplay(
                      color: textColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.business_center, color: iconColor, size: 24),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'All Best Providers in One Place',
                style: GoogleFonts.plusJakartaSans(
                  color: subTextColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/conference/c_wall.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Color(0xAA3E2C26),
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFERENCE PLANNING, MADE SIMPLE',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE7D3C3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bring every detail\ninto one plan',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A coordinated experience for your team, guests, and providers.',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'What We Provide',
                style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Services Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return _ServiceCard(
                    title: _services[index].title,
                    description: _services[index].description,
                    icon: _services[index].icon,
                    iconColor: iconColor,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  );
                },
              ),
              const SizedBox(height: 32),

              // Create Now Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.conferenceCreate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Create Now!!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color textColor;
  final Color subTextColor;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E6DD), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: subTextColor,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
