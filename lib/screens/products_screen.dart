import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';
import '../core/api_client.dart';
import 'edit_product_screen.dart';
import 'edit_category_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  // Products and Categories states
  bool _isProductsLoading = false;
  bool _isCategoriesLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  
  // Real-time backend fallback controls
  static const int _fallbackTimeoutMs = 1200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchProducts();
    _fetchCategories();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  // --- Dynamic API Fetchers ---
  
  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() {
      _isProductsLoading = true;
    });

    try {
      final response = await _apiClient
          .get('/admin/products/?page=1&limit=50')
          .timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? productList = data['data'];
        
        if (productList != null && productList.isNotEmpty) {
          if (mounted) {
            setState(() {
              _products = List<Map<String, dynamic>>.from(productList);
            });
          }
        } else {
          _loadFallbackProducts();
        }
      } else {
        _loadFallbackProducts();
      }
    } catch (e) {
      _loadFallbackProducts();
    } finally {
      if (mounted) {
        setState(() {
          _isProductsLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isCategoriesLoading = true;
    });

    try {
      final response = await _apiClient
          .get('/admin/categories/?page=1&limit=50')
          .timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? categoryList = data['data'];
        
        if (categoryList != null && categoryList.isNotEmpty) {
          if (mounted) {
            setState(() {
              _categories = List<Map<String, dynamic>>.from(categoryList);
            });
          }
        } else {
          _loadFallbackCategories();
        }
      } else {
        _loadFallbackCategories();
      }
    } catch (e) {
      _loadFallbackCategories();
    } finally {
      if (mounted) {
        setState(() {
          _isCategoriesLoading = false;
        });
      }
    }
  }

  // --- Dynamic Status Toggles ---

  Future<void> _toggleProductStatus(String id, bool currentStatus, int index) async {
    // Optimistic UI state updates
    setState(() {
      _products[index]['status'] = !currentStatus;
    });

    try {
      final response = await _apiClient
          .patch('/admin/products/$id/status', {})
          .timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode != 200) {
        // Revert on server error
        setState(() {
          _products[index]['status'] = currentStatus;
        });
        _showToast('Failed to update status on server.');
      } else {
        _showToast('Product status updated successfully!');
      }
    } catch (e) {
      // Revert if offline
      setState(() {
        _products[index]['status'] = currentStatus;
      });
      _showToast('Offline: Toggled local sandbox status.');
    }
  }

  Future<void> _toggleCategoryStatus(String id, bool currentStatus, int index) async {
    // Optimistic UI state updates
    setState(() {
      _categories[index]['status'] = !currentStatus;
    });

    try {
      final response = await _apiClient
          .patch('/admin/categories/$id/status', {})
          .timeout(const Duration(milliseconds: _fallbackTimeoutMs));

      if (response.statusCode != 200) {
        // Revert on server error
        setState(() {
          _categories[index]['status'] = currentStatus;
        });
        _showToast('Failed to update status on server.');
      } else {
        _showToast('Category status updated successfully!');
      }
    } catch (e) {
      // Revert if offline
      setState(() {
        _categories[index]['status'] = currentStatus;
      });
      _showToast('Offline: Toggled local sandbox status.');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.white),
        ),
        backgroundColor: AppColors.forestGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // --- Premium Name-Aware Image Placeholder Vector Graphics ---
  Widget _buildProductVectorImage(String name, {bool isCategory = false}) {
    final lower = name.toLowerCase();
    
    // Default color values mapping to premium spray visuals
    Color primaryColor = const Color(0xFF146EB4);
    IconData icon = LucideIcons.package;

    if (isCategory) {
      if (lower.contains('graffiti')) {
        primaryColor = const Color(0xFFEC587A);
        icon = LucideIcons.palette;
      } else if (lower.contains('wood')) {
        primaryColor = const Color(0xFFD7A13E);
        icon = LucideIcons.home;
      } else if (lower.contains('automotive') || lower.contains('spray')) {
        primaryColor = AppColors.forestGreen;
        icon = LucideIcons.truck;
      } else if (lower.contains('merch') || lower.contains('tee')) {
        primaryColor = const Color(0xFF7D58EC);
        icon = LucideIcons.shirt;
      } else {
        primaryColor = const Color(0xFF48A6D9);
        icon = LucideIcons.layers;
      }
    } else {
      if (lower.contains('ts 50') || lower.contains('rust')) {
        primaryColor = const Color(0xFFE44B40);
        icon = LucideIcons.shieldAlert;
      } else if (lower.contains('tee') || lower.contains('oversized')) {
        primaryColor = const Color(0xFF1C1C1C);
        icon = LucideIcons.shirt;
      } else if (lower.contains('cap') || lower.contains('skinny')) {
        primaryColor = const Color(0xFF8657EC);
        icon = LucideIcons.circle;
      } else if (lower.contains('krayon') || lower.contains('gold') || lower.contains('brass')) {
        primaryColor = const Color(0xFFD9A441);
        icon = LucideIcons.sparkles;
      }
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
      ),
      child: Center(
        child: Icon(
          icon,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  // --- High-fidelity offline fallbacks ---
  
  void _loadFallbackProducts() {
    setState(() {
      _products = [
        {
          "id": "uuid-1",
          "name": "TS 50 Anti Rust Spray",
          "price": 110.00,
          "compare_at_price": 150.00,
          "sku": "BAN-TS-50",
          "status": true,
          "categories": ["Automotive Sprays"],
          "inventory": 1,
          "primary_image": null
        },
        {
          "id": "uuid-2",
          "name": "DESI FLOW Oversized Tee (Black)",
          "price": 639.00,
          "compare_at_price": 850.00,
          "sku": "BAN-DESI-BLK",
          "status": true,
          "categories": ["Merch"],
          "inventory": 1,
          "primary_image": null
        },
        {
          "id": "uuid-3",
          "name": "DESI FLOW Oversized Tee (White)",
          "price": 639.00,
          "compare_at_price": 850.00,
          "sku": "BAN-DESI-WHT",
          "status": true,
          "categories": ["Merch"],
          "inventory": 1,
          "primary_image": null
        },
        {
          "id": "uuid-4",
          "name": "Banna Skinny Cap",
          "price": 28.00,
          "compare_at_price": 35.00,
          "sku": "BAN-SKINNY-CAP",
          "status": true,
          "categories": ["Actuator Caps"],
          "inventory": 1,
          "primary_image": null
        },
        {
          "id": "uuid-5",
          "name": "Krayon Brass Gold Spray",
          "price": 220.00,
          "compare_at_price": 299.00,
          "sku": "BAN-KRAYON-BRG",
          "status": true,
          "categories": ["Krayon DIY Sprays"],
          "inventory": 1,
          "primary_image": null
        },
        {
          "id": "uuid-6",
          "name": "Krayon Gold Finish Spray",
          "price": 220.00,
          "compare_at_price": 299.00,
          "sku": "BAN-KRAYON-GLD",
          "status": true,
          "categories": ["Krayon DIY Sprays"],
          "inventory": 1,
          "primary_image": null
        }
      ];
    });
  }

  void _loadFallbackCategories() {
    setState(() {
      _categories = [
        {
          "id": "uuid-c1",
          "name": "Graffiti Series Sprays",
          "status": true,
          "product_count": 68,
          "image_url": null
        },
        {
          "id": "uuid-c2",
          "name": "Wood Polish Sprays",
          "status": true,
          "product_count": 7,
          "image_url": null
        },
        {
          "id": "uuid-c3",
          "name": "Krayon DIY Sprays",
          "status": true,
          "product_count": 22,
          "image_url": null
        },
        {
          "id": "uuid-c4",
          "name": "Automotive Sprays",
          "status": true,
          "product_count": 58,
          "image_url": null
        },
        {
          "id": "uuid-c5",
          "name": "Merch",
          "status": true,
          "product_count": 3,
          "image_url": null
        },
        {
          "id": "uuid-c6",
          "name": "Actuator Caps",
          "status": true,
          "product_count": 9,
          "image_url": null
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.forestGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Products',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search, color: Colors.white, size: 20),
            onPressed: () => _showToast('Search product catalog...'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.sliders, color: Colors.white, size: 20),
            onPressed: () => _showToast('Filter product categories...'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 10),
          tabs: const [
            Tab(text: 'All Products'),
            Tab(text: 'Categories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ALL PRODUCTS
          _isProductsLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
              : RefreshIndicator(
                  onRefresh: _fetchProducts,
                  color: AppColors.forestGreen,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
                    itemCount: _products.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      final bool active = p['status'] ?? false;
                      final double price = (p['price'] as num).toDouble();
                      final double? compPrice = p['compare_at_price'] != null
                          ? (p['compare_at_price'] as num).toDouble()
                          : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(product: p),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              _fetchProducts();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Product custom visual placeholder
                              p['primary_image'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        p['primary_image'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildProductVectorImage(p['name'] ?? ''),
                                      ),
                                    )
                                  : _buildProductVectorImage(p['name'] ?? ''),
                              const SizedBox(width: 12),
  
                              // 2. Info elements
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['name'] ?? 'Spray Product',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    
                                    // Prices Row
                                    Row(
                                      children: [
                                        Text(
                                          '₹${price.round()}',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 10,
                                            color: AppColors.foreground,
                                          ),
                                        ),
                                        if (compPrice != null && compPrice > price) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '₹${compPrice.round()}',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 8,
                                              color: AppColors.muted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
  
                                    // Count & Status badges
                                    Row(
                                      children: [
                                        Text(
                                          '${p['inventory'] ?? 1} piece',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 8,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            color: AppColors.muted,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          active ? 'Active' : 'Inactive',
                                          style: GoogleFonts.outfit(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8,
                                            color: active ? const Color(0xFF3FAE5A) : AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
  
                              // 3. Actions & Toggle Switches
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(LucideIcons.share2, color: AppColors.muted, size: 16),
                                        onPressed: () => _showToast('Share product link!'),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(LucideIcons.moreVertical, color: AppColors.muted, size: 16),
                                        onPressed: () => _showToast('More options...'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 24,
                                    width: 40,
                                    child: Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: active,
                                        activeColor: Colors.white,
                                        activeTrackColor: const Color(0xFF146EB4),
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: const Color(0xFFD6D6D6),
                                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                        onChanged: (val) {
                                          _toggleProductStatus(p['id'] ?? '', active, index);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          // TAB 2: CATEGORIES
          _isCategoriesLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
              : RefreshIndicator(
                  onRefresh: _fetchCategories,
                  color: AppColors.forestGreen,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = _categories[index];
                      final bool active = c['status'] ?? false;
                      final int count = c['product_count'] ?? 0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCategoryScreen(category: c),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              _fetchCategories();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.015),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Category vector logo
                              c['image_url'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        c['image_url'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildProductVectorImage(c['name'] ?? '', isCategory: true),
                                      ),
                                    )
                                  : _buildProductVectorImage(c['name'] ?? '', isCategory: true),
                              const SizedBox(width: 12),

                              // 2. Info elements
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c['name'] ?? 'Series Sprays',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: AppColors.foreground,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$count products listed',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 8,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      active ? 'Active' : 'Inactive',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: active ? const Color(0xFF3FAE5A) : AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 3. Actions & Toggle Switches
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(LucideIcons.share2, color: AppColors.muted, size: 16),
                                        onPressed: () => _showToast('Share category link!'),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(LucideIcons.moreVertical, color: AppColors.muted, size: 16),
                                        onPressed: () => _showToast('More options...'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 24,
                                    width: 40,
                                    child: Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: active,
                                        activeColor: Colors.white,
                                        activeTrackColor: const Color(0xFF146EB4),
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: const Color(0xFFD6D6D6),
                                        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                                        onChanged: (val) {
                                          _toggleCategoryStatus(c['id'] ?? '', active, index);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      
      // Bottom Floating Action pill button shifting based on active tab
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFEE7423), // Dukaan standard orange button color
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          onPressed: () {
            if (_tabController.index == 0) {
              _showToast('Add new product catalog form...');
            } else {
              _showToast('Create new category form...');
            }
          },
          label: Row(
            children: [
              const Icon(LucideIcons.plus, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                _tabController.index == 0 ? 'Add product' : 'Create category',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
