import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/vowora_theme.dart';
import '../../models/wedding_ecosystem_models.dart';
import '../../providers/wedding_ecosystem_provider.dart';
import '../../routes/app_routes.dart';

class WeddingGalleryScreen extends StatefulWidget {
  const WeddingGalleryScreen({super.key});

  @override
  State<WeddingGalleryScreen> createState() => _WeddingGalleryScreenState();
}

class _WeddingGalleryScreenState extends State<WeddingGalleryScreen> {
  String _selectedAlbum = 'All';

  final List<String> _albums = [
    'All',
    'Pre-Wedding',
    'Ceremony',
    'Couple',
    'Family',
    'Guests',
    'Reception',
    'Candid',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WeddingEcosystemProvider>(context);
    final isClient = provider.activeRole == UserRole.client;
    final allPhotos = provider.weddingPhotos;

    // Filter approved public photos vs client's pending approvals
    final approvedPhotos = allPhotos.where((p) {
      if (p.approvalStatus != PhotoApprovalStatus.approved) return false;
      if (_selectedAlbum != 'All' && p.albumName != _selectedAlbum) return false;
      return true;
    }).toList();

    final pendingApprovalPhotos = allPhotos
        .where((p) => p.approvalStatus == PhotoApprovalStatus.pendingApproval)
        .toList();

    return DefaultTabController(
      length: isClient ? 2 : 1,
      child: Scaffold(
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
            'Wedding Gallery 📸',
            style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_a_photo_rounded, color: VoworaColors.champagneGold),
              tooltip: 'Share Your Moments',
              onPressed: () => _showGuestUploadModal(context, provider),
            ),
          ],
          bottom: isClient
              ? TabBar(
                  indicatorColor: VoworaColors.champagneGold,
                  labelColor: VoworaColors.champagneGold,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    const Tab(text: 'Public Gallery'),
                    Tab(text: 'Guest Approvals (${pendingApprovalPhotos.length})'),
                  ],
                )
              : null,
        ),
        body: SafeArea(
          child: TabBarView(
            physics: isClient ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            children: [
              // 1. Public Gallery Tab
              _buildGalleryTab(context, provider, approvedPhotos),

              // 2. Client Guest Photo Approvals Tab (Only if Client)
              if (isClient) _buildApprovalTab(context, provider, pendingApprovalPhotos),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryTab(BuildContext context, WeddingEcosystemProvider provider, List<WeddingGalleryPhotoModel> photos) {
    return Column(
      children: [
        // Album Filter Pills
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _albums.length,
            itemBuilder: (context, index) {
              final album = _albums[index];
              final isSel = _selectedAlbum == album;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedAlbum = album),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? VoworaColors.champagneGold : Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? VoworaColors.champagneGold : Colors.white24,
                      ),
                    ),
                    child: Text(
                      album,
                      style: GoogleFonts.plusJakartaSans(
                        color: isSel ? const Color(0xFF141210) : Colors.white,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Photo Grid
        Expanded(
          child: photos.isEmpty
              ? Center(
                  child: Text(
                    'No photos in this album yet.\nBe the first to share a moment!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            photo.imageUrl,
                            fit: BoxFit.cover,
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded || frame != null) return child;
                              return Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover);
                            },
                            errorBuilder: (c, e, s) => Image.asset('assets/images/wedding_background.png', fit: BoxFit.cover),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black87],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  photo.albumName,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: VoworaColors.champagneGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'By ${photo.uploaderName}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildApprovalTab(BuildContext context, WeddingEcosystemProvider provider, List<WeddingGalleryPhotoModel> pendingPhotos) {
    if (pendingPhotos.isEmpty) {
      return Center(
        child: Text('No guest photos pending approval ✓', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pendingPhotos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final photo = pendingPhotos[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  photo.imageUrl,
                  width: 75,
                  height: 75,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded || frame != null) return child;
                    return Image.asset(
                      'assets/images/wedding_background.png',
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                    );
                  },
                  errorBuilder: (c, e, s) => Image.asset(
                    'assets/images/wedding_background.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(photo.uploaderName, style: GoogleFonts.playfairDisplay(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Album: ${photo.albumName}', style: GoogleFonts.plusJakartaSans(color: VoworaColors.champagneGold, fontSize: 11)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => provider.approveGuestPhoto(photo.id),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6FCFB0), foregroundColor: Colors.black),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => provider.rejectGuestPhoto(photo.id),
                          style: OutlinedButton.styleFrom(foregroundColor: VoworaColors.error, side: const BorderSide(color: VoworaColors.error)),
                          child: const Text('Reject'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGuestUploadModal(BuildContext context, WeddingEcosystemProvider provider) {
    final urlCtrl = TextEditingController(text: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622');
    String selectedAlbum = 'Guests';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF181513),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share Your Moments 📸', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Upload your wedding guest photo. Guest photos will be reviewed by the host before publishing.', style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedAlbum,
                dropdownColor: const Color(0xFF181513),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Select Album'),
                items: ['Pre-Wedding', 'Ceremony', 'Couple', 'Family', 'Guests', 'Reception', 'Candid']
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) selectedAlbum = val;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Photo Image URL', labelStyle: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (urlCtrl.text.trim().isNotEmpty) {
                      provider.uploadPhotoToWedding(
                        weddingId: provider.activeWedding.weddingId,
                        albumName: selectedAlbum,
                        imageUrl: urlCtrl.text.trim(),
                        uploaderName: provider.activeRole == UserRole.guest ? 'Nusrat (Guest)' : 'Host',
                        uploaderRole: provider.activeRole,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Photo uploaded! Pending host review 🎉')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: VoworaColors.champagneGold, foregroundColor: Colors.black),
                  child: Text('Submit Photo', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
