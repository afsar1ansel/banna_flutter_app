import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockOrders = [
      {"number": "23435966", "cust": "Aniket Nath", "total": "₹1,435.00", "status": "Cancelled", "date": "11 Apr"},
      {"number": "22410340", "cust": "Himanshu Arora", "total": "₹57,944.50", "status": "Delivered", "date": "31 Dec"},
      {"number": "22143400", "cust": "Aniket Nath", "total": "₹4,590.00", "status": "Delivered", "date": "02 Dec"},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Manage Orders',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.foreground),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppColors.border, height: 1.0),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ord = mockOrders[index];
          final isDelivered = ord['status'] == 'Delivered';
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${ord['number']}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Customer: ${ord['cust']}  •  Date: ${ord['date']}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ord['total'],
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.forestGreen),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDelivered ? AppColors.primary.withOpacity(0.1) : AppColors.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ord['status'],
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          color: isDelivered ? AppColors.primary : AppColors.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
