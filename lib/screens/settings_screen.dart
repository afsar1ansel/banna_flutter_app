import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _availableCredits = 25;

  // Custom wallet illustration matching the sleek leather design
  Widget _buildWalletIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 75,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 64,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F75BC), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Card slot lines
              Positioned(
                top: 5,
                left: 5,
                right: 5,
                child: Container(
                  height: 1.5,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              // Golden coin logo
              Positioned(
                right: 6,
                top: 12,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD54F),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '₹',
                      style: GoogleFonts.outfit(
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ),
                ),
              ),
              // Wallet flap overlap
              Positioned(
                right: 0,
                top: 8,
                bottom: 8,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D47A1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 1.5,
                        offset: const Offset(-0.8, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Interactive popup to mock adding credits
  void _showAddCreditsDialog(BuildContext context) {
    int selectedAmount = 100;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Buy Banna Credits',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.forestGreen,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase high-speed server transactions & premium tools.',
                    style: GoogleFonts.outfit(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [50, 100, 250].map((amt) {
                      final isSelected = selectedAmount == amt;
                      return InkWell(
                        onTap: () => setDialogState(() => selectedAmount = amt),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.forestGreen : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.forestGreen : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '₹$amt',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isSelected ? Colors.white : AppColors.foreground,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                    setState(() {
                      _availableCredits += selectedAmount;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        content: Text(
                          'Successfully added ₹$selectedAmount credits!',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Confirm',
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

  // Interactive Bottom Sheet to view history
  void _showCreditHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        final List<Map<String, dynamic>> logs = [
          {"desc": "Sign-up Welcome bonus received", "amt": "+25", "date": "June 1, 2026", "isAdd": true},
          {"desc": "Banna Premium API call usage", "amt": "-5", "date": "May 28, 2026", "isAdd": false},
          {"desc": "Automated order callback fee", "amt": "-2", "date": "May 25, 2026", "isAdd": false},
        ];
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Credit Transaction History',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                separatorBuilder: (c, idx) => const Divider(color: AppColors.border),
                itemBuilder: (c, idx) {
                  final log = logs[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['desc'],
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log['date'],
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          log['amt'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                            color: log['isAdd'] ? AppColors.primary : AppColors.errorRed,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Create store sheet
  void _showCreateStoreBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Create New Store',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter Store Name',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g. Banna Plastics',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.forestGreen),
                  ),
                ),
                style: GoogleFonts.outfit(fontSize: 12),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          content: Text(
                            'Created and launched $name store!',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Create and Launch',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Interactive Sign out dialog
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.errorRed,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    content: Text(
                      'Signed out successfully (demo)!',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                );
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

  // Settings click dispatcher
  void _onSettingItemClicked(String title) {
    switch (title) {
      case 'Additional information':
        _showSignOutDialog(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.forestGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(
              'Navigating to $title settings...',
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
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credits Header & Wallet Panel
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Green Header area
                Container(
                  width: double.infinity,
                  color: AppColors.forestGreen,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Banna Credits',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supercharge your business by using credits for transaction fees',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w400,
                          fontSize: 10.5,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                // Overlapping credits card
                Positioned(
                  bottom: -28,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Available credits',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$_availableCredits',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColors.foreground,
                              ),
                            ),
                          ],
                        ),
                        _buildWalletIllustration(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40), // Spacing below overlap card

            // Add Credits and View History buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAddCreditsDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add credits',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCreditHistoryBottomSheet(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        side: const BorderSide(color: AppColors.forestGreen),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View history',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // MY STORE section header
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 16, top: 22, bottom: 6),
              child: Text(
                'MY STORE',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                  color: AppColors.muted,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // Create store button card (Active Banna Aerosol card removed per request)
            InkWell(
              onTap: () => _showCreateStoreBottomSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2EFE9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.plus,
                        color: AppColors.muted,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Create store',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.foreground,
                        ),
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

            // SETTINGS section header
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 16, top: 20, bottom: 6),
              child: Text(
                'SETTINGS',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                  color: AppColors.muted,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            // Unified Settings group container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    title: 'Store management',
                    subtitle: 'Timings, Domains, Warehouses, Tax',
                    icon: LucideIcons.store,
                    iconBgColor: const Color(0xFFEBF3FC),
                    iconColor: const Color(0xFF1E88E5),
                    showDivider: true,
                  ),
                  _buildSettingsTile(
                    title: 'Payments',
                    subtitle: 'Payment providers, COD',
                    icon: LucideIcons.creditCard,
                    iconBgColor: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF388E3C),
                    showDivider: true,
                  ),
                  _buildSettingsTile(
                    title: 'Shipping',
                    subtitle: 'Delivery, Returns & Replacements',
                    icon: LucideIcons.truck,
                    iconBgColor: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFF57C00),
                    showDivider: true,
                  ),
                  _buildSettingsTile(
                    title: 'Pages',
                    subtitle: 'SEO, Support & Social, Policies',
                    icon: LucideIcons.files,
                    iconBgColor: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF5E35B1),
                    showDivider: true,
                  ),
                  _buildSettingsTile(
                    title: 'Subscription',
                    subtitle: 'Upgrade plan, Billing details',
                    icon: LucideIcons.crown,
                    iconBgColor: const Color(0xFFFFFAEB),
                    iconColor: const Color(0xFFFFB300),
                    showDivider: true,
                  ),
                  _buildSettingsTile(
                    title: 'Additional information',
                    subtitle: 'Get in touch, Rate us, Sign out',
                    icon: LucideIcons.moreHorizontal,
                    iconBgColor: const Color(0xFFF5F5F5),
                    iconColor: const Color(0xFF616161),
                    showDivider: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Reusable dynamic setting row tile builder
  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => _onSettingItemClicked(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Circular icon frame
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
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
                  color: AppColors.border,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(left: 64),
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
