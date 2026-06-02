import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';
import '../core/api_client.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  Map<String, dynamic>? _liveOrderDetails;
  
  // Custom tag list matching screenshot
  final List<String> _tags = ['freebie_order'];
  final TextEditingController _tagController = TextEditingController();

  // Internal states
  late String _orderStatus;

  static const int _fallbackTimeoutMs = 1500;

  @override
  void initState() {
    super.initState();
    _orderStatus = widget.order['status'] ?? 'Pending';
    _fetchOrderDetails();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    final orderId = widget.order['id'];
    if (orderId == null || orderId.toString().length < 20) {
      // Mock sandbox order, skip backend call
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient
          .get('/admin/orders/$orderId')
          .timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _liveOrderDetails = jsonDecode(response.body);
            // Sync status variables
            final serverStatus = _liveOrderDetails?['order_status'] ?? 'pending';
            if (serverStatus == 'accepted') {
              _orderStatus = 'Accepted';
            } else if (serverStatus == 'shipped') {
              _orderStatus = 'Shipped';
            } else if (serverStatus == 'delivered') {
              _orderStatus = 'Delivered';
            } else if (serverStatus == 'cancelled') {
              _orderStatus = 'Abandoned';
            }
          });
        }
      }
    } catch (_) {
      // Fallback gracefully
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateStatus(String statusValue) async {
    final orderId = widget.order['id'];
    final oldStatus = _orderStatus;
    
    setState(() {
      _orderStatus = statusValue == 'accepted' ? 'Accepted' : (statusValue == 'shipped' ? 'Shipped' : 'Abandoned');
    });

    if (orderId == null || orderId.toString().length < 20) {
      _showToast('Mock status changed to $statusValue.');
      return;
    }

    try {
      final response = await _apiClient.patch('/admin/orders/$orderId/status', {
        'order_status': statusValue
      }).timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode == 200) {
        _showToast('Order status updated successfully!');
      } else {
        setState(() {
          _orderStatus = oldStatus;
        });
        _showToast('Failed to save status on server.');
      }
    } catch (e) {
      _showToast('Offline: Toggled local sandbox status.');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    _showToast('$fieldName copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    final String orderNum = widget.order['number'] ?? '23893314';
    final String orderDate = widget.order['date'] ?? '02 Jun 2026, 12:17 PM';

    // Renders status badge colors
    Color statusColor = const Color(0xFF3FAE5A);
    Color statusBg = const Color(0xFFE2F6E9);
    if (_orderStatus == 'Abandoned') {
      statusColor = AppColors.errorRed;
      statusBg = const Color(0xFFFEE2E2);
    } else if (_orderStatus == 'Pending') {
      statusColor = AppColors.activeAmber;
      statusBg = const Color(0xFFFEF3C7);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.foreground, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Order ID #$orderNum',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _orderStatus,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 8,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3FAE5A)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==================== TOP ACTION BUTTONS ====================
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _updateStatus('cancelled'),
                          child: Text(
                            'Cancel order',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              color: AppColors.errorRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangeButton,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => _updateStatus('shipped'),
                          child: Text(
                            'Ship order',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================== ORDER ID & TIMELINE HEADER ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#$orderNum',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              orderDate,
                              style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3FAE5A)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: () => _showToast('Downloading Receipt...'),
                          icon: const Icon(LucideIcons.fileText, size: 12, color: Color(0xFF3FAE5A)),
                          label: Text(
                            'Receipt',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF3FAE5A),
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== ITEMS LIST CARD ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4 items',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.foreground),
                        ),
                        const Divider(height: 16),
                        _buildOrderItem(
                          imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100&q=80",
                          title: "Sand Drift Grey Chevrolet Automotive Spray Paint",
                          quantity: 1,
                          price: 319.00,
                        ),
                        const Divider(height: 16),
                        _buildOrderItem(
                          imageUrl: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=100&q=80",
                          title: "Black Primer - High-Performance Base Coat by Banna",
                          quantity: 1,
                          price: 199.00,
                        ),
                        const Divider(height: 16),
                        _buildOrderItem(
                          imageUrl: "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=100&q=80",
                          title: "Lacquer - Premium Clear Coat Spray by Banna",
                          quantity: 1,
                          price: 199.00,
                        ),
                        const Divider(height: 16),
                        _buildOrderItem(
                          imageUrl: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100&q=80",
                          title: "Desi Flow Gloves V2",
                          subtitle: "SKU ID: DSFLOW",
                          quantity: 1,
                          price: 75.00,
                          isFree: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== INVOICE DETAILS PANEL ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInvoiceRow('Subtotal', '₹792.01'),
                        const SizedBox(height: 6),
                        _buildInvoiceRow('Freebie coupon discount (DESIFLOWV2)', '-₹75.00', isDiscount: true),
                        const SizedBox(height: 6),
                        _buildInvoiceRow('Delivery', 'FREE', isGreenText: true),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.foreground),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF1E6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.order['paymentMode'] ?? 'COD',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 7,
                                      color: const Color(0xFFEE7423),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '₹${widget.order['total'] ?? 717}',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.foreground),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Loyalty Points earned',
                              style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              '35.85 points',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 8, color: AppColors.foreground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== CUSTOMER DETAILS SECTION ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Customer details',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.foreground),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.edit2, size: 12, color: AppColors.muted),
                              onPressed: () => _showToast('Edit Customer...'),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        
                        // Name & Mobile
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  InkWell(
                                    onTap: () => _copyToClipboard('Amit Singh', 'Customer Name'),
                                    child: Text(
                                      'Amit Singh',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        color: const Color(0xFF3FAE5A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mobile', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '+91-9839812391',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      color: AppColors.foreground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Email
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () => _copyToClipboard('amit.singh.dr@gmail.com', 'Customer Email'),
                              child: Text(
                                'amit.singh.dr@gmail.com',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  color: const Color(0xFF3FAE5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Shipping address
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shipping address', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Flat No. FF-02, Type 5, Maharshi Vashishtha Medical College Rampur, Basti, 272124 Uttar Pradesh',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: AppColors.foreground,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.border),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  onPressed: () => _copyToClipboard(
                                    'Flat No. FF-02, Type 5, Maharshi Vashishtha Medical College Rampur, Basti, 272124 Uttar Pradesh',
                                    'Address',
                                  ),
                                  icon: const Icon(LucideIcons.copy, size: 8, color: AppColors.foreground),
                                  label: Text(
                                    'Copy',
                                    style: GoogleFonts.outfit(color: AppColors.foreground, fontSize: 7, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Referral Link
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Referral Link', style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: () => _copyToClipboard('https://banna.in/ref=amit100', 'Referral Link'),
                              child: Text(
                                'Copy referral link',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                  color: const Color(0xFF3FAE5A),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== ACTIVITY TIMELINE CARD ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Activity',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.foreground),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () => _showToast('Add note flow...'),
                              child: Text(
                                'Add note',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                  color: const Color(0xFF3FAE5A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        const SizedBox(height: 4),
                        
                        // Timeline Rows
                        _buildTimelineItem(
                          title: 'Order accepted',
                          subtitle: 'Automated',
                          timeStr: '02/06/26, 12:17 PM',
                          isLast: false,
                          isActive: true,
                        ),
                        _buildTimelineItem(
                          title: 'Order received',
                          subtitle: 'Via online store',
                          timeStr: '02/06/26, 12:17 PM',
                          isLast: true,
                          isActive: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==================== TAGS CARD ====================
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tags',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.foreground),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.edit2, size: 10, color: AppColors.muted),
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        TextField(
                          controller: _tagController,
                          style: GoogleFonts.outfit(fontSize: 8),
                          decoration: InputDecoration(
                            hintText: 'Search or create tags',
                            hintStyle: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setState(() {
                                _tags.add(val.trim());
                                _tagController.clear();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        
                        // Tag Chips wrap
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _tags.map((tag) {
                            return Chip(
                              backgroundColor: AppColors.background,
                              labelStyle: GoogleFonts.outfit(fontSize: 7, color: AppColors.foreground, fontWeight: FontWeight.bold),
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.only(left: 6, right: 2, top: 0, bottom: 0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: const BorderSide(color: AppColors.border),
                              ),
                              label: Text(tag),
                              deleteIcon: const Icon(LucideIcons.x, size: 8, color: AppColors.muted),
                              onDeleted: () {
                                setState(() {
                                  _tags.remove(tag);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Row Item Builder
  Widget _buildOrderItem({
    required String imageUrl,
    required String title,
    String? subtitle,
    required int quantity,
    required double price,
    bool isFree = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            imageUrl,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => Container(
              width: 32,
              height: 32,
              color: Colors.grey[100],
              child: const Icon(LucideIcons.image, size: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 8, color: AppColors.foreground),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 6.5, color: AppColors.muted, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 3),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Text(
                      '$quantity',
                      style: GoogleFonts.outfit(fontSize: 6.5, fontWeight: FontWeight.bold, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'x',
                    style: GoogleFonts.outfit(fontSize: 6.5, color: AppColors.muted),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '₹$price',
                    style: GoogleFonts.outfit(fontSize: 6.5, fontWeight: FontWeight.bold, color: AppColors.foreground),
                  ),
                  if (isFree) ...[
                    const SizedBox(width: 4),
                    Text(
                      '[FREE]',
                      style: GoogleFonts.outfit(fontSize: 6.5, fontWeight: FontWeight.bold, color: const Color(0xFF3FAE5A)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹${(price * quantity).toStringAsFixed(2)}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 8, color: AppColors.foreground),
        ),
      ],
    );
  }

  // Invoice Row Builder
  Widget _buildInvoiceRow(String label, String value, {bool isDiscount = false, bool isGreenText = false}) {
    Color valColor = AppColors.foreground;
    if (isDiscount) valColor = AppColors.errorRed;
    else if (isGreenText) valColor = const Color(0xFF3FAE5A);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted, fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 8,
            color: valColor,
          ),
        ),
      ],
    );
  }

  // Timeline Event Row Builder
  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String timeStr,
    required bool isLast,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots and Lines column
        Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? const Color(0xFF3FAE5A) : AppColors.muted,
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? const Color(0xFF3FAE5A) : Colors.transparent,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 24,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 8),

        // Event descriptions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 7.5,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 6.5,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10), // Padding below item
            ],
          ),
        ),

        // Event Time
        Text(
          timeStr,
          style: GoogleFonts.outfit(
            fontSize: 6.5,
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
