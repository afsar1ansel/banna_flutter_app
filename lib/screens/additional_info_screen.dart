import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  // Mock interactive dialog for Rate Us
  void _showRatingDialog() {
    int rating = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Rate Banna Dashboard',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.forestGreen,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How is your experience with Banna Aerosol dashboard?',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.muted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNum <= rating ? LucideIcons.star : LucideIcons.star,
                          color: starNum <= rating ? AppColors.activeAmber : AppColors.border,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = starNum;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text(
                          'Thank you for rating us $rating stars!',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Submit',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Mock interactive sheet for Privacy Policy
  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Privacy Policy',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          'Your privacy matters to us at Banna Aerosol. We collect, store, and manage administrative settings, store credentials, and metrics to strictly offer dashboard services.\n\n'
                          '1. Data Collection: We do not share database credentials or client-sensitive inventory information with third parties.\n\n'
                          '2. Security Protocols: All data flows over REST/HTTPS with Bearer JWT tokens. Session storage is protected via platform-level secure storage.\n\n'
                          '3. Changes: We reserve the right to modify policy updates. Please verify custom details periodically.',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.muted, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Close', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12)),
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

  // Dynamic Sign Out handler
  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Confirm Sign Out',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.forestGreen,
            ),
          ),
          content: Text(
            'Are you sure you want to log out from Banna Dashboard?',
            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Dismiss Dialog
                Navigator.pop(context);
                // Dismiss Additional Info Screen to clean navigation tree
                Navigator.pop(context);
                
                // Clear session tokens and logout
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.logout();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.errorRed,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      content: Text(
                        'Logged out successfully.',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Sign Out',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }

  // Tapping handler dispatcher
  void _onMenuItemTapped(String title) {
    switch (title) {
      case 'Privacy policy':
        _showPrivacyPolicy();
        break;
      case 'Rate us':
        _showRatingDialog();
        break;
      case 'Sign out':
        _showSignOutDialog(context);
        break;
      default:
        // Get in touch or any other fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.forestGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(
              'Opening contact details...',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 11),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Additional information',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Scrollable list items
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Card 1: Policies, touch contact, and rate
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        title: 'Privacy policy',
                        subtitle: 'Your privacy matters to us',
                        icon: LucideIcons.lock,
                        showDivider: true,
                      ),
                      _buildInfoTile(
                        title: 'Get in touch',
                        subtitle: 'Have any issues?',
                        icon: LucideIcons.mail,
                        showDivider: true,
                      ),
                      _buildInfoTile(
                        title: 'Rate us',
                        subtitle: 'Tell us what you think',
                        icon: LucideIcons.star,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Logout action block
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _buildInfoTile(
                    title: 'Sign out',
                    subtitle: 'Are you sure you want to log out?',
                    icon: LucideIcons.logOut,
                    showDivider: false,
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Version Label
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Text(
                'v4.5.0',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.muted.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable tile builder with grey custom container branding
  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => _onMenuItemTapped(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Custom light-grey container icon frame matching screenshot
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF616161),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.chevronRight,
                  color: AppColors.muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),
          ),
      ],
    );
  }
}
