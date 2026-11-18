import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// UdyamBoost brand palette (same values as app.dart).
class _Brand {
  static const Color cream = Color(0xFFFAF3E1);
  static const Color beige = Color(0xFFF5E7C6);
  static const Color tangerine = Color(0xFFFF6D1F);
  static const Color charcoal = Color(0xFF222222);

  static const Color muted = Color(0xB3222222);
  static const Color subtle = Color(0x73222222);
  static const Color line = Color(0x24222222);

  static const Color error = Color(0xFFB83A0A);
}

/// Maximum width of the page content on large screens.
const double _contentMaxWidth = 1100;

class Product {
  final String id;
  String name;
  String description;
  String category;
  double price;
  String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'].toString(),
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['image_url'] as String?,
    );
  }
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const List<String> _categories = [
    'General',
    'Clothing',
    'Food & Beverages',
    'Electronics',
    'Beauty',
    'Home & Lifestyle',
    'Handicrafts',
    'Other',
  ];

  final SupabaseClient _supabase = Supabase.instance.client;
  final List<Product> _products = [];
  final TextEditingController _searchController = TextEditingController();

  String? _businessId;
  String _searchQuery = '';
  bool _isLoading = true;
  final bool _isSubmitting = false;

  List<Product> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _products;
    return _products
        .where((product) => product.name.toLowerCase().contains(query))
        .toList();
  }

  double get _totalValue =>
      _products.fold(0, (sum, product) => sum + product.price);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in before opening your product catalogue.');
      }

      final profile = await _supabase
          .from('business_profiles')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (profile == null) {
        throw Exception('Business profile not found. Complete onboarding first.');
      }

      final businessId = profile['id'] as String;
      final response = await _supabase
          .from('products')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      final loaded = (response as List)
          .map((row) => Product.fromMap(row as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _businessId = businessId;
        _products
          ..clear()
          ..addAll(loaded);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('Unable to load products: $error', isError: true);
    }
  }

  Future<String> _uploadProductImage(File image, String productId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Please log in again.');

    final extension = image.path.split('.').last.toLowerCase();
    const allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
    if (!allowedExtensions.contains(extension)) {
      throw Exception('Please select a JPG, PNG, or WEBP image.');
    }

    final filePath = '${user.id}/products/$productId.$extension';

    await _supabase.storage.from('business-assets').upload(
          filePath,
          image,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _supabase.storage
        .from('business-assets')
        .getPublicUrl(filePath);
  }

  Future<void> _saveProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required File? image,
    required Product? existingProduct,
  }) async {
    final businessId = _businessId;
    if (businessId == null) {
      throw Exception('Business profile not loaded. Please reopen this screen.');
    }

    final productData = <String, dynamic>{
      'business_id': businessId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
    };

    if (existingProduct == null) {
      // Create the database row first so we have a stable product ID for storage.
      final inserted = await _supabase
          .from('products')
          .insert(productData)
          .select()
          .single();

      final productId = inserted['id'].toString();
      String? imageUrl;

      try {
        if (image != null) {
          imageUrl = await _uploadProductImage(image, productId);
          await _supabase
              .from('products')
              .update({'image_url': imageUrl})
              .eq('id', productId)
              .eq('business_id', businessId);
        }
      } catch (_) {
        // Do not silently pretend the image was saved. The product row remains
        // available and the caller will show the upload error.
        rethrow;
      }

      final savedProduct = Product(
        id: productId,
        name: name,
        description: description,
        category: category,
        price: price,
        imageUrl: imageUrl,
      );

      if (!mounted) return;
      setState(() => _products.insert(0, savedProduct));
    } else {
      // Keep the previous URL if the user does not choose a replacement image.
      final imageUrl = image == null
          ? existingProduct.imageUrl
          : await _uploadProductImage(image, existingProduct.id);

      await _supabase
          .from('products')
          .update({
            ...productData,
            'image_url': imageUrl,
          })
          .eq('id', existingProduct.id)
          .eq('business_id', businessId);

      if (!mounted) return;
      setState(() {
        existingProduct
          ..name = name
          ..description = description
          ..category = category
          ..price = price
          ..imageUrl = imageUrl;
      });
    }
  }

  Future<File?> _pickImage() async {
    final selected = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (selected == null) return null;
    return File(selected.path);
  }

  Future<void> _showProductForm({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
      text: product == null ? '' : product.price.toString(),
    );
    final formKey = GlobalKey<FormState>();

    var category = _categories.contains(product?.category)
        ? product!.category
        : _categories.first;
    File? selectedImage;
    var isSaving = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: _Brand.cream,
        constraints: const BoxConstraints(maxWidth: 560),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              Future<void> chooseImage() async {
                try {
                  final file = await _pickImage();
                  if (file != null && sheetContext.mounted) {
                    setSheetState(() => selectedImage = file);
                  }
                } catch (error) {
                  if (sheetContext.mounted) {
                    _showMessage('Unable to select image: $error', isError: true);
                  }
                }
              }

              Future<void> submit() async {
                if (isSaving || !formKey.currentState!.validate()) return;
                setSheetState(() => isSaving = true);

                try {
                  await _saveProduct(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: category,
                    price: double.parse(priceController.text.trim()),
                    image: selectedImage,
                    existingProduct: product,
                  );

                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  _showMessage(
                    product == null
                        ? 'Product added successfully.'
                        : 'Product updated successfully.',
                  );
                } catch (error) {
                  if (sheetContext.mounted) {
                    setSheetState(() => isSaving = false);
                    _showMessage('Unable to save product: $error', isError: true);
                  }
                }
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product == null ? 'Add Product' : 'Edit Product',
                                style: const TextStyle(
                                  color: _Brand.charcoal,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(
                                Icons.close,
                                color: _Brand.charcoal,
                              ),
                              tooltip: 'Close',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Add product details and an optional product photo.',
                          style: TextStyle(color: _Brand.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            InkWell(
                              onTap: isSaving ? null : chooseImage,
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 104,
                                height: 104,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: _Brand.beige,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _Brand.line,
                                    width: 1.5,
                                  ),
                                ),
                                child: _buildFormImage(product, selectedImage),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Tap the image to choose or replace it.',
                                style: TextStyle(
                                  color: _Brand.muted,
                                  fontSize: 12.5,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _textField(
                          controller: nameController,
                          label: 'Product name',
                          hint: 'e.g. Cotton Kurti',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter product name'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          controller: descriptionController,
                          label: 'Description',
                          hint: 'Describe your product',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: category,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          dropdownColor: _Brand.cream,
                          decoration: _inputDecoration('Category'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            color: _Brand.charcoal,
                          ),
                          items: _categories
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: isSaving
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setSheetState(() => category = value);
                                  }
                                },
                        ),
                        const SizedBox(height: 14),
                        _textField(
                          controller: priceController,
                          label: 'Price (₹)',
                          hint: 'e.g. 499',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            final price = double.tryParse(value?.trim() ?? '');
                            if (price == null || !price.isFinite || price <= 0) {
                              return 'Enter a valid price greater than zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _Brand.tangerine,
                              foregroundColor: _Brand.charcoal,
                              disabledBackgroundColor:
                                  _Brand.tangerine.withValues(alpha: 0.6),
                              disabledForegroundColor: _Brand.charcoal,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      color: _Brand.charcoal,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    product == null
                                        ? 'Add Product'
                                        : 'Save Changes',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      // Dispose only after the modal route has completely closed.
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
    }
  }

  Widget _buildFormImage(Product? product, File? selectedImage) {
    if (selectedImage != null) {
      return Image.file(selectedImage, fit: BoxFit.cover);
    }
    if (product?.imageUrl != null && product!.imageUrl!.isNotEmpty) {
      return Image.network(
        product.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(
          Icons.broken_image_outlined,
          color: _Brand.subtle,
          size: 32,
        ),
      );
    }
    return const Icon(
      Icons.add_photo_alternate_outlined,
      color: _Brand.charcoal,
      size: 32,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _Brand.muted, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: _Brand.charcoal,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(fontSize: 13.5, color: _Brand.subtle),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.65),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      errorStyle: const TextStyle(color: _Brand.error, fontSize: 12),
      border: border(_Brand.line),
      enabledBorder: border(const Color(0x40222222)),
      focusedBorder: border(_Brand.tangerine, 2),
      errorBorder: border(_Brand.error),
      focusedErrorBorder: border(_Brand.error, 2),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _Brand.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete product?',
          style: TextStyle(
            color: _Brand.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: const TextStyle(color: _Brand.muted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(foregroundColor: _Brand.charcoal),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: _Brand.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || _businessId == null) return;

    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', product.id)
          .eq('business_id', _businessId!);

      if (!mounted) return;
      setState(() => _products.removeWhere((item) => item.id == product.id));
      _showMessage('Product deleted.');
    } catch (error) {
      _showMessage('Unable to delete product: $error', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: _Brand.cream),
        ),
        backgroundColor: isError ? _Brand.error : _Brand.charcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── PRODUCT CARD ───────────────────────────────────────────────────────────
  Widget _buildProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _Brand.line),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _Brand.beige,
              borderRadius: BorderRadius.circular(10),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: _Brand.subtle,
                      size: 28,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: _Brand.subtle,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _Brand.charcoal,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _Brand.muted, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _Brand.charcoal,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Options',
            color: _Brand.cream,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: const Icon(Icons.more_vert, color: _Brand.muted),
            onSelected: (value) {
              if (value == 'edit') {
                _showProductForm(product: product);
              } else if (value == 'delete') {
                _deleteProduct(product);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 18, color: _Brand.charcoal),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        color: _Brand.error, size: 18),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _Brand.beige,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 34,
                  color: _Brand.charcoal,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _searchQuery.isEmpty
                    ? 'No products yet'
                    : 'No matching products',
                style: const TextStyle(
                  color: _Brand.charcoal,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Start building your digital catalogue by adding your first product.'
                    : 'Try searching with another product name.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _Brand.muted,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed:
                      _businessId == null ? null : () => _showProductForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add your first product'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Brand.tangerine,
                    foregroundColor: _Brand.charcoal,
                    elevation: 0,
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── PAGE ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final bool narrow = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: _Brand.cream,
      appBar: AppBar(
        backgroundColor: _Brand.cream,
        surfaceTintColor: Colors.transparent,
        foregroundColor: _Brand.charcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Product Catalogue',
          style: TextStyle(
            color: _Brand.charcoal,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _businessId == null ? null : () => _showProductForm(),
            icon: const Icon(Icons.add_circle_outline),
            color: _Brand.charcoal,
            tooltip: 'Add product',
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: _Brand.line),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _Brand.tangerine),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                final bool wide = w >= 720;
                final double contentW = w < _contentMaxWidth
                    ? w
                    : _contentMaxWidth;
                final double side =
                    (w - contentW) / 2 + (w >= 640 ? 32 : 20);

                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(side, 28, side, 20),
                      sliver: SliverToBoxAdapter(child: _buildHeader(wide)),
                    ),
                    if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildEmptyState(),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          side,
                          0,
                          side,
                          wide ? 40 : 96,
                        ),
                        sliver: wide
                            ? SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 520,
                                  mainAxisExtent: 112,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (_, index) =>
                                      _buildProductCard(products[index]),
                                  childCount: products.length,
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (_, index) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildProductCard(products[index]),
                                  ),
                                  childCount: products.length,
                                ),
                              ),
                      ),
                  ],
                );
              },
            ),
      floatingActionButton: narrow
          ? FloatingActionButton.extended(
              onPressed: _isLoading || _businessId == null
                  ? null
                  : () => _showProductForm(),
              backgroundColor: _Brand.tangerine,
              foregroundColor: _Brand.charcoal,
              elevation: 2,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Product',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(bool wide) {
    final Widget intro = Text(
      'Manage all your products in one place.',
      style: TextStyle(
        color: _Brand.muted,
        fontSize: wide ? 16 : 14.5,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wide)
          Row(
            children: [
              Expanded(child: intro),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _businessId == null ? null : () => _showProductForm(),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Brand.tangerine,
                  foregroundColor: _Brand.charcoal,
                  elevation: 0,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          )
        else
          intro,
        const SizedBox(height: 20),

        // SUMMARY
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: _Brand.beige,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _stat(
                  value: '${_products.length}',
                  label: 'Total products',
                ),
              ),
              Container(
                height: 44,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: _Brand.line,
              ),
              Expanded(
                child: _stat(
                  value: '₹${_totalValue.toStringAsFixed(0)}',
                  label: 'Total listed value',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Total listed value is the sum of product prices, not inventory value.',
          style: TextStyle(color: _Brand.muted, fontSize: 11),
        ),
        const SizedBox(height: 20),

        // SEARCH
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 480 : double.infinity),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 14.5, color: _Brand.charcoal),
            decoration: InputDecoration(
              hintText: 'Search products...',
              hintStyle: const TextStyle(
                fontSize: 13.5,
                color: _Brand.subtle,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: _Brand.subtle,
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.65),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _Brand.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0x40222222)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: _Brand.tangerine,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat({required String value, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _Brand.charcoal,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: _Brand.muted, fontSize: 12.5),
        ),
      ],
    );
  }
}