import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/constants.dart';
import '../core/api_client.dart';

class EditCategoryScreen extends StatefulWidget {
  final Map<String, dynamic> category;

  const EditCategoryScreen({super.key, required this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  // Collapsible Card States
  bool _isInfoExpanded = true;
  bool _isBannerExpanded = false;
  bool _isContentExpanded = false;
  bool _isSubcategoriesExpanded = false;
  bool _isProductsExpanded = false;
  bool _isSeoExpanded = false;

  // Basic Info States
  late TextEditingController _nameController;
  late TextEditingController _sortOrderController;
  bool _statusVal = true;
  String _imageUrl = '';
  bool _isSubcategory = false;
  String? _parentId;

  // Parent Category list for dropdowns
  List<Map<String, dynamic>> _categoriesList = [];

  // Banner States
  late TextEditingController _bannerUrlDesktopController;
  late TextEditingController _bannerUrlMobileController;
  String _bannerTab = 'desktop';

  // Description Content State
  late TextEditingController _descriptionController;

  // SEO States
  late TextEditingController _seoTitleController;
  late TextEditingController _seoMetaDescriptionController;
  String _seoSocialImage = '';

  // Associated collections
  List<Map<String, dynamic>> _subcategories = [];
  List<Map<String, dynamic>> _products = [];
  bool _isSubcategoriesLoading = false;
  bool _isProductsLoading = false;
  bool _isSaving = false;

  // Real-time toast helpers
  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.checkCircle, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 9),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1D1B20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final c = widget.category;

    _nameController = TextEditingController(text: c['name'] ?? '');
    _sortOrderController = TextEditingController(text: (c['sort_order'] ?? 1).toString());
    _statusVal = c['status'] != false;
    _imageUrl = c['image_url'] ?? '';
    _isSubcategory = c['is_subcategory'] ?? (c['parent_id'] != null);
    _parentId = c['parent_id'];

    _bannerUrlDesktopController = TextEditingController(text: c['banner_url_desktop'] ?? '');
    _bannerUrlMobileController = TextEditingController(text: c['banner_url_mobile'] ?? '');

    _descriptionController = TextEditingController(text: c['description'] ?? '');

    _seoTitleController = TextEditingController(text: c['seo_title'] ?? '');
    _seoMetaDescriptionController = TextEditingController(text: c['seo_meta_description'] ?? '');
    _seoSocialImage = c['seo_social_image'] ?? '';

    _fetchCategoriesList();
    _fetchSubcategoriesAndProducts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sortOrderController.dispose();
    _bannerUrlDesktopController.dispose();
    _bannerUrlMobileController.dispose();
    _descriptionController.dispose();
    _seoTitleController.dispose();
    _seoMetaDescriptionController.dispose();
    super.dispose();
  }

  // Fetch parents catalog dropdown list
  Future<void> _fetchCategoriesList() async {
    try {
      final res = await _apiClient.get('/admin/categories/?page=1&limit=100');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null) {
          setState(() {
            _categoriesList = List<Map<String, dynamic>>.from(data['data'])
                .where((cat) => cat['id'] != widget.category['id']) // Exclude self
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading parents: $e');
    }
  }

  // Load associated subcategories and products
  Future<void> _fetchSubcategoriesAndProducts() async {
    final catId = widget.category['id'];
    if (catId == null) return;

    setState(() {
      _isSubcategoriesLoading = true;
      _isProductsLoading = true;
    });

    try {
      // 1. Load subcategories
      final catsRes = await _apiClient.get('/admin/categories/?page=1&limit=100');
      if (catsRes.statusCode == 200) {
        final data = jsonDecode(catsRes.body);
        if (data['data'] != null) {
          final List<Map<String, dynamic>> allCats = List<Map<String, dynamic>>.from(data['data']);
          setState(() {
            _subcategories = allCats.where((c) => c['parent_id'] == catId).toList();
          });
        }
      }

      // 2. Load products
      final prodsRes = await _apiClient.get('/admin/products/?category_id=$catId&limit=100');
      if (prodsRes.statusCode == 200) {
        final data = jsonDecode(prodsRes.body);
        if (data['data'] != null) {
          setState(() {
            _products = List<Map<String, dynamic>>.from(data['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading lists: $e');
    } finally {
      setState(() {
        _isSubcategoriesLoading = false;
        _isProductsLoading = false;
      });
    }
  }

  // Save changes to backend
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      'image_url': _imageUrl.isEmpty ? null : _imageUrl,
      'status': _statusVal,
      'sort_order': int.tryParse(_sortOrderController.text) ?? 1,
      'parent_id': _isSubcategory ? _parentId : null,
      'banner_url_desktop': _bannerUrlDesktopController.text.isEmpty ? null : _bannerUrlDesktopController.text,
      'banner_url_mobile': _bannerUrlMobileController.text.isEmpty ? null : _bannerUrlMobileController.text,
      'is_subcategory': _isSubcategory,
      'seo_title': _seoTitleController.text.isEmpty ? null : _seoTitleController.text,
      'seo_meta_description': _seoMetaDescriptionController.text.isEmpty ? null : _seoMetaDescriptionController.text,
      'seo_social_image': _seoSocialImage.isEmpty ? null : _seoSocialImage,
    };

    try {
      final res = await _apiClient.put('/admin/categories/${widget.category['id']}', payload);
      if (res.statusCode == 200) {
        _showToast('Category updated successfully!');
        Future.delayed(const Duration(milliseconds: 600), () {
          Navigator.pop(context, true);
        });
      } else {
        final body = jsonDecode(res.body);
        _showToast('Error: ${body['detail'] ?? 'Failed to update category'}');
      }
    } catch (e) {
      _showToast('Error updating category.');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // Unlink subcategory child
  Future<void> _handleUnlinkSubcategory(String subId) async {
    try {
      final res = await _apiClient.put('/admin/categories/$subId', {
        'parent_id': null,
        'is_subcategory': false,
      });
      if (res.statusCode == 200) {
        _showToast('Subcategory unlinked successfully!');
        _fetchSubcategoriesAndProducts();
      }
    } catch (e) {
      _showToast('Error unlinking subcategory.');
    }
  }

  // Delete subcategory child
  Future<void> _handleDeleteSubcategory(String subId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Subcategory', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to permanently delete this subcategory?', style: GoogleFonts.outfit()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: GoogleFonts.outfit(color: AppColors.errorRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final res = await _apiClient.delete('/admin/categories/$subId');
      if (res.statusCode == 200) {
        _showToast('Subcategory deleted successfully!');
        _fetchSubcategoriesAndProducts();
      }
    } catch (e) {
      _showToast('Error deleting subcategory.');
    }
  }

  // Unlink product from category
  Future<void> _handleUnlinkProduct(String prodId) async {
    try {
      final detailRes = await _apiClient.get('/admin/products/$prodId');
      if (detailRes.statusCode == 200) {
        final prodData = jsonDecode(detailRes.body);
        final List<dynamic> currentCats = prodData['categories'] ?? [];
        final updatedIds = currentCats
            .map((c) => c['id'].toString())
            .where((id) => id != widget.category['id'])
            .toList();

        final updateRes = await _apiClient.put('/admin/products/$prodId', {
          'category_ids': updatedIds,
        });

        if (updateRes.statusCode == 200) {
          _showToast('Product unlinked successfully!');
          _fetchSubcategoriesAndProducts();
        }
      }
    } catch (e) {
      _showToast('Error unlinking product.');
    }
  }

  // Select Products picker modal bottom sheet
  Future<void> _showProductSelector() async {
    List<Map<String, dynamic>> allProds = [];
    List<String> selectedIds = _products.map((p) => p['id'].toString()).toList();
    bool loadingProds = true;
    String searchQuery = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Load products once
            if (loadingProds && allProds.isEmpty) {
              _apiClient.get('/admin/products/?limit=100').then((res) {
                if (res.statusCode == 200) {
                  final data = jsonDecode(res.body);
                  if (data['data'] != null) {
                    setModalState(() {
                      allProds = List<Map<String, dynamic>>.from(data['data']);
                      loadingProds = false;
                    });
                  }
                }
              }).catchError((e) {
                setModalState(() => loadingProds = false);
              });
            }

            final filtered = allProds.where((p) {
              final q = searchQuery.toLowerCase().trim();
              if (q.isEmpty) return true;
              final name = (p['name'] ?? '').toString().toLowerCase();
              final sku = (p['sku'] ?? '').toString().toLowerCase();
              return name.contains(q) || sku.contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Select products',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.x, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Search box
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        onChanged: (val) => setModalState(() => searchQuery = val),
                        style: GoogleFonts.outfit(fontSize: 10),
                        decoration: InputDecoration(
                          hintText: 'Search products by name or SKU...',
                          prefixIcon: const Icon(LucideIcons.search, size: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),

                    // List view
                    Expanded(
                      child: loadingProds
                          ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
                          : filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    'No products found.',
                                    style: GoogleFonts.outfit(color: AppColors.muted, fontSize: 10),
                                  ),
                                )
                              : ListView.separated(
                                  controller: scrollController,
                                  itemCount: filtered.length,
                                  separatorBuilder: (c, i) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final p = filtered[index];
                                    final pId = p['id'].toString();
                                    final isChecked = selectedIds.contains(pId);

                                    return ListTile(
                                      onTap: () {
                                        setModalState(() {
                                          if (isChecked) {
                                            selectedIds.remove(pId);
                                          } else {
                                            selectedIds.add(pId);
                                          }
                                        });
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: p['primary_image'] != null
                                            ? Image.network(
                                                p['primary_image'],
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => Container(
                                                  width: 40,
                                                  height: 40,
                                                  color: Colors.grey[100],
                                                  child: const Icon(LucideIcons.image, size: 18),
                                                ),
                                              )
                                            : Container(
                                                width: 40,
                                                height: 40,
                                                color: Colors.grey[100],
                                                child: const Icon(LucideIcons.image, size: 18),
                                              ),
                                      ),
                                      title: Text(
                                        p['name'] ?? 'Product Item',
                                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                      subtitle: Text(
                                        'SKU: ${p['sku'] ?? 'N/A'} • \$${(p['price'] ?? 0).toString()}',
                                        style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted),
                                      ),
                                      trailing: Icon(
                                        isChecked ? LucideIcons.checkSquare : LucideIcons.square,
                                        color: isChecked ? const Color(0xFF146EB4) : AppColors.muted,
                                        size: 20,
                                      ),
                                    );
                                  },
                                ),
                    ),

                    const Divider(height: 1),
                    // Action Footer
                    Container(
                      color: Colors.grey[50],
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${selectedIds.length} products selected',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF146EB4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              _syncProductSelections(selectedIds);
                            },
                            child: Text('Save selection', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // Update backend selections in background
  Future<void> _syncProductSelections(List<String> newIds) async {
    setState(() => _isProductsLoading = true);
    final currentIds = _products.map((p) => p['id'].toString()).toList();
    final catId = widget.category['id'];

    final added = newIds.where((id) => !currentIds.contains(id)).toList();
    final removed = currentIds.where((id) => !newIds.contains(id)).toList();

    try {
      // 1. Process additions
      for (final pId in added) {
        final res = await _apiClient.get('/admin/products/$pId');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final List<dynamic> cats = data['categories'] ?? [];
          final List<String> catIds = cats.map((c) => c['id'].toString()).toList();
          if (!catIds.contains(catId)) {
            catIds.add(catId);
            await _apiClient.put('/admin/products/$pId', {'category_ids': catIds});
          }
        }
      }

      // 2. Process removals
      for (final pId in removed) {
        final res = await _apiClient.get('/admin/products/$pId');
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final List<dynamic> cats = data['categories'] ?? [];
          final List<String> catIds = cats
              .map((c) => c['id'].toString())
              .where((id) => id != catId)
              .toList();
          await _apiClient.put('/admin/products/$pId', {'category_ids': catIds});
        }
      }

      _showToast('Category product links updated!');
      _fetchSubcategoriesAndProducts();
    } catch (e) {
      _showToast('Failed to update product linkages.');
    } finally {
      setState(() => _isProductsLoading = false);
    }
  }

  // Collapsible panel layout helper
  Widget _buildCollapsibleSection({
    required IconData mainIcon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.012),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(mainIcon, color: AppColors.forestGreen, size: 18),
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
                            fontSize: 12,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 8,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    color: AppColors.muted,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(14),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'Edit Category',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF146EB4),
                foregroundColor: Colors.white,
                elevation: 0.5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9)),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // ==================== SECTION 1: INFORMATION ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.info,
                title: 'Information',
                subtitle: 'Thumbnail visuals, name, and nesting tags.',
                isExpanded: _isInfoExpanded,
                onToggle: () => setState(() => _isInfoExpanded = !_isInfoExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image selector row
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(_imageUrl, fit: BoxFit.cover),
                                )
                              : const Icon(LucideIcons.camera, color: AppColors.muted, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category Thumbnail Icon',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              const SizedBox(height: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.foreground,
                                  elevation: 0,
                                  side: const BorderSide(color: AppColors.border),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _imageUrl = 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80';
                                  });
                                  _showToast('Mock thumbnail uploaded!');
                                },
                                child: Text('Mock Upload', style: GoogleFonts.outfit(fontSize: 8)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Name
                    Text(
                      'Category Name *',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.outfit(fontSize: 10),
                      decoration: const InputDecoration(hintText: 'Enter category name (e.g. Primers)'),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Sort order & Status Switch
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sort Order',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _sortOrderController,
                                style: GoogleFonts.outfit(fontSize: 10),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(hintText: '1'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Status',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                            ),
                            const SizedBox(height: 4),
                            Switch(
                              value: _statusVal,
                              activeColor: AppColors.forestGreen,
                              onChanged: (val) => setState(() => _statusVal = val),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Subcategory toggle
                    CheckboxListTile(
                      value: _isSubcategory,
                      activeColor: AppColors.forestGreen,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Add as subcategory',
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      onChanged: (val) => setState(() => _isSubcategory = val ?? false),
                    ),

                    if (_isSubcategory) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Select Parent Category *',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _parentId,
                        style: GoogleFonts.outfit(fontSize: 10, color: AppColors.foreground),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- Choose Parent --'),
                          ),
                          ..._categoriesList.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['id'].toString(),
                              child: Text(cat['name'] ?? 'Category'),
                            );
                          }),
                        ],
                        onChanged: (val) => setState(() => _parentId = val),
                      ),
                    ],
                  ],
                ),
              ),

              // ==================== SECTION 2: BANNERS ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.image,
                title: 'Banners',
                subtitle: 'Desktop and Mobile billboard visuals.',
                isExpanded: _isBannerExpanded,
                onToggle: () => setState(() => _isBannerExpanded = !_isBannerExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tabs selector
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('Desktop Banner', style: GoogleFonts.outfit(fontSize: 8)),
                          selected: _bannerTab == 'desktop',
                          selectedColor: AppColors.forestGreen.withOpacity(0.12),
                          onSelected: (val) => setState(() => _bannerTab = 'desktop'),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Mobile Banner', style: GoogleFonts.outfit(fontSize: 8)),
                          selected: _bannerTab == 'mobile',
                          selectedColor: AppColors.forestGreen.withOpacity(0.12),
                          onSelected: (val) => setState(() => _bannerTab = 'mobile'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (_bannerTab == 'desktop') ...[
                      Text(
                        'Desktop Banner URL',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _bannerUrlDesktopController,
                        style: GoogleFonts.outfit(fontSize: 10),
                        decoration: const InputDecoration(hintText: 'https://bannasprays.com/...'),
                      ),
                    ] else ...[
                      Text(
                        'Mobile Banner URL',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _bannerUrlMobileController,
                        style: GoogleFonts.outfit(fontSize: 10),
                        decoration: const InputDecoration(hintText: 'https://bannasprays.com/...'),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[50],
                        foregroundColor: AppColors.foreground,
                        elevation: 0,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      icon: const Icon(LucideIcons.uploadCloud, size: 14),
                      label: Text('Attach Mock Banner Photo', style: GoogleFonts.outfit(fontSize: 8)),
                      onPressed: () {
                        setState(() {
                          if (_bannerTab == 'desktop') {
                            _bannerUrlDesktopController.text = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=1200&q=80';
                          } else {
                            _bannerUrlMobileController.text = 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500&q=80';
                          }
                        });
                        _showToast('Mock Banner URL attached successfully!');
                      },
                    ),
                  ],
                ),
              ),

              // ==================== SECTION 3: DESCRIPTION ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.edit3,
                title: 'Content Description',
                subtitle: 'Rich text details and chemical metrics overview.',
                isExpanded: _isContentExpanded,
                onToggle: () => setState(() => _isContentExpanded = !_isContentExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Category Description',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      style: GoogleFonts.outfit(fontSize: 10),
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Describe details regarding coverage metrics or series sprays listed in this category...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== SECTION 4: SUBCATEGORIES ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.folder,
                title: 'Subcategories',
                subtitle: 'Nested child catalog category collections.',
                isExpanded: _isSubcategoriesExpanded,
                onToggle: () => setState(() => _isSubcategoriesExpanded = !_isSubcategoriesExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isSubcategoriesLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
                    else if (_subcategories.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'No subcategories mapped yet.',
                            style: GoogleFonts.outfit(fontSize: 9, color: AppColors.muted, fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _subcategories.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final sub = _subcategories[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: sub['image_url'] != null
                                    ? Image.network(
                                        sub['image_url'],
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(width: 32, height: 32, color: Colors.grey[100], child: const Icon(LucideIcons.folder, size: 14)),
                                      )
                                    : Container(width: 32, height: 32, color: Colors.grey[100], child: const Icon(LucideIcons.folder, size: 14)),
                              ),
                              title: Text(
                                sub['name'] ?? 'Child Category',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              subtitle: Text(
                                '/${sub['slug'] ?? ''}',
                                style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted),
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(LucideIcons.moreVertical, size: 18, color: AppColors.muted),
                                style: const ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Subcategory', style: GoogleFonts.outfit(fontSize: 9)),
                                  ),
                                  PopupMenuItem(
                                    value: 'unlink',
                                    child: Text('Unlink Subcategory', style: GoogleFonts.outfit(fontSize: 9)),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete Permanent', style: GoogleFonts.outfit(fontSize: 9, color: AppColors.errorRed, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditCategoryScreen(category: sub)),
                                    ).then((u) {
                                      if (u == true) _fetchSubcategoriesAndProducts();
                                    });
                                  } else if (val == 'unlink') {
                                    _handleUnlinkSubcategory(sub['id'].toString());
                                  } else if (val == 'delete') {
                                    _handleDeleteSubcategory(sub['id'].toString());
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(LucideIcons.plus, size: 14),
                        label: Text('Add subcategory', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF146EB4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () {
                          // Open creator sheet or route with parentId prefilled
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCategoryScreen(
                                category: {
                                  'id': null,
                                  'parent_id': widget.category['id'],
                                  'is_subcategory': true,
                                },
                              ),
                            ),
                          ).then((_) => _fetchSubcategoriesAndProducts());
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== SECTION 5: PRODUCTS ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.layers,
                title: 'Products',
                subtitle: 'Items mapped under this category tag.',
                isExpanded: _isProductsExpanded,
                onToggle: () => setState(() => _isProductsExpanded = !_isProductsExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isProductsLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
                    else if (_products.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'No products associated yet.',
                            style: GoogleFonts.outfit(fontSize: 9, color: AppColors.muted, fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _products[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: p['primary_image'] != null
                                    ? Image.network(
                                        p['primary_image'],
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(width: 32, height: 32, color: Colors.grey[100], child: const Icon(LucideIcons.image, size: 14)),
                                      )
                                    : Container(width: 32, height: 32, color: Colors.grey[100], child: const Icon(LucideIcons.image, size: 14)),
                              ),
                              title: Text(
                                p['name'] ?? 'Product Item',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                              subtitle: Text(
                                '${p['sku'] ?? 'N/A'} • \$${(p['price'] ?? 0).toString()}',
                                style: GoogleFonts.outfit(fontSize: 8, color: AppColors.muted),
                              ),
                              trailing: IconButton(
                                icon: const Icon(LucideIcons.xCircle, size: 18, color: AppColors.errorRed),
                                onPressed: () => _handleUnlinkProduct(p['id'].toString()),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(LucideIcons.checkSquare, size: 14),
                        label: Text('Select products', style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF146EB4),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _showProductSelector,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== SECTION 6: SEO METADATA ====================
              _buildCollapsibleSection(
                mainIcon: LucideIcons.search,
                title: 'Dukaan SEO',
                subtitle: 'Google Search tags optimization details.',
                isExpanded: _isSeoExpanded,
                onToggle: () => setState(() => _isSeoExpanded = !_isSeoExpanded),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // SEO Title
                    Text(
                      'Title Tag',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _seoTitleController,
                      style: GoogleFonts.outfit(fontSize: 10),
                      decoration: const InputDecoration(hintText: 'Enter title tag'),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        if (_nameController.text.trim().isEmpty) {
                          _showToast('Please enter category name first!');
                          return;
                        }
                        setState(() {
                          _seoTitleController.text = '${_nameController.text.trim()} | Premium Aerosols Spray Series';
                        });
                        _showToast('SEO Title generated!');
                      },
                      child: Text(
                        'Generate Title Suggestion',
                        style: GoogleFonts.outfit(color: const Color(0xFF146EB4), fontWeight: FontWeight.bold, fontSize: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // SEO Description
                    Text(
                      'Meta Description Tag',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _seoMetaDescriptionController,
                      style: GoogleFonts.outfit(fontSize: 10),
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Enter meta description tag'),
                      onChanged: (val) => setState(() {}),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        if (_nameController.text.trim().isEmpty) {
                          _showToast('Please enter category name first!');
                          return;
                        }
                        setState(() {
                          _seoMetaDescriptionController.text = 'Explore elite ${_nameController.text.trim()} aerosol spray cans by Banna. Highly pigmented, excellent coverage, quick-drying formulas for professional street art and DIY coatings.';
                        });
                        _showToast('SEO Meta Description generated!');
                      },
                      child: Text(
                        'Generate Meta Description Suggestion',
                        style: GoogleFonts.outfit(color: const Color(0xFF146EB4), fontWeight: FontWeight.bold, fontSize: 8),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Realtime Google Preview Snippet
                    Text(
                      'Search sharing snippet preview',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 9, color: AppColors.muted),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _seoTitleController.text.isNotEmpty
                                ? _seoTitleController.text
                                : (_nameController.text.isNotEmpty ? _nameController.text : 'Category Page Title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: const Color(0xFF146EB4),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'https://bannasprays.com/categories/${_nameController.text.trim().toLowerCase().replaceAll(' ', '-')}/',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 7,
                              color: const Color(0xFF3FAE5A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _seoMetaDescriptionController.text.isNotEmpty
                                ? _seoMetaDescriptionController.text
                                : 'Enter page description metadata tags to visualize live layout indexing previews on Google search results.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 7.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
