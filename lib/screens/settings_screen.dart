import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {"title": "Store Profile Settings", "desc": "Manage addresses, billing details, and domain links", "icon": LucideIcons.store},
      {"title": "Delivery Integrations", "desc": "Configure courier partners and delivery zones", "icon": LucideIcons.truck},
      {"title": "Notification Alerts", "desc": "Toggle push, email, and SMS customer updates", "icon": LucideIcons.bell},
      {"title": "System Audit Logs", "desc": "Review administrative logins and database edits", "icon": LucideIcons.fileText},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Settings Panel',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.foreground),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final opt = options[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(opt['icon'], color: AppColors.forestGreen, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['title'],
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        opt['desc'],
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppColors.muted, size: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
