import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';

class StoreManagementScreen extends StatefulWidget {
  const StoreManagementScreen({super.key});

  @override
  State<StoreManagementScreen> createState() => _StoreManagementScreenState();
}

class _StoreManagementScreenState extends State<StoreManagementScreen> {
  bool _isStoreOnline = true;

  // Custom vector illustration representing a phone overlapping a desktop screen with an arrow
  Widget _buildDesktopOnlyIllustration() {
    return Container(
      height: 140,
      width: 200,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Desktop monitor mockup background
          Positioned(
            left: 30,
            top: 10,
            child: Container(
              width: 140,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFFD0E1F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Diagonal Arrow representing screen extension or growth
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Icon(
                      LucideIcons.arrowUpRight,
                      color: Colors.white.withOpacity(0.9),
                      size: 26,
                    ),
                  ),
                  // Bottom taskbar / accent highlight line
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Desktop Stand
          Positioned(
            left: 92,
            top: 100,
            child: Container(
              width: 16,
              height: 16,
              color: Colors.white,
            ),
          ),
          // Desktop base
          Positioned(
            left: 75,
            top: 114,
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 2. Mobile Phone mockup overlapping in foreground
          Positioned(
            left: 14,
            top: 45,
            child: Container(
              width: 44,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF2F80ED),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Top notch / ear speaker line
                  Positioned(
                    top: 3,
                    left: 14,
                    right: 14,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Screen content (simple outline representing progress)
                  Center(
                    child: Container(
                      width: 24,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opens the custom desktop-only modal bottom sheet
  void _showDesktopOnlyBottomSheet(BuildContext context, String feature) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handler line
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),

              // Vector Illustration
              _buildDesktopOnlyIllustration(),
              const SizedBox(height: 24),

              // Bold Title
              Text(
                'This feature is only available on desktop!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.foreground,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Descriptive Subtitle (dynamic feature name and brand domain)
              Text(
                'To manage ${feature.toLowerCase()}, please navigate to\nweb.banna.in on desktop.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Solid Banna Forest-Green Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Okay',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // General click handler dispatcher
  void _onMenuItemTapped(String title) {
    if (title == 'Warehouses' ||
        title == 'Staff accounts' ||
        title == 'Checkout' ||
        title == 'Notifications') {
      _showDesktopOnlyBottomSheet(context, title);
    } else {
      // General feedback for Domains or Tax
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            'Opening $title settings...',
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
          'Store Management',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // 1. Store Status Switch Tile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF3FC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.clock,
                        color: Color(0xFF2F80ED),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Store status',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                    Text(
                      _isStoreOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _isStoreOnline,
                      onChanged: (val) {
                        setState(() {
                          _isStoreOnline = val;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: _isStoreOnline ? AppColors.primary : AppColors.errorRed,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(milliseconds: 800),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Text(
                              _isStoreOnline ? 'Store is now Online!' : 'Store is now Offline!',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                            ),
                          ),
                        );
                      },
                      activeColor: Colors.white,
                      activeTrackColor: AppColors.primary,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.border,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 68),
                child: Divider(height: 1, thickness: 1, color: AppColors.border),
              ),

              // 2. Domains
              _buildStoreManagementTile(
                title: 'Domains',
                subtitle: 'Manage your store\'s custom domain',
                icon: LucideIcons.globe,
                showDivider: true,
              ),

              // 3. Warehouses
              _buildStoreManagementTile(
                title: 'Warehouses',
                subtitle: 'View and manage your warehouses',
                icon: LucideIcons.home,
                showDivider: true,
              ),

              // 4. Tax
              _buildStoreManagementTile(
                title: 'Tax',
                subtitle: 'Manage GST charges on products',
                icon: LucideIcons.percent,
                showDivider: true,
              ),

              // 5. Staff accounts
              _buildStoreManagementTile(
                title: 'Staff accounts',
                subtitle: 'View and manage your store\'s staff',
                icon: LucideIcons.contact,
                showDivider: true,
              ),

              // 6. Checkout
              _buildStoreManagementTile(
                title: 'Checkout',
                subtitle: 'Configure your store\'s checkout',
                icon: LucideIcons.shoppingCart,
                showDivider: true,
              ),

              // 7. Notifications
              _buildStoreManagementTile(
                title: 'Notifications',
                subtitle: 'Manage your store notifications',
                icon: LucideIcons.sliders,
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable tile builder with consistent blue container branding
  Widget _buildStoreManagementTile({
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
                // Custom light-blue container icon frame matching screenshot
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBF3FC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2F80ED),
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
