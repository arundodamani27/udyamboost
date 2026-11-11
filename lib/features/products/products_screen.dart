import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const Color primary = Color(0xFF2457E6);
  static const Color dark = Color(0xFF14213D);
  static const Color muted = Color(0xFF64748B);
  static const Color background = Color(0xFFF7F9FC);

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
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  20,
                  20,
                  20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 20,
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
                                  color: dark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: isSaving
                                  ? null
                                  : () => Navigator.of(sheetContext).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add product details and an optional product photo.',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: InkWell(
                            onTap: isSaving ? null : chooseImage,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 112,
                              height: 112,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF4FF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFD5E2FF),
                                ),
                              ),
                              child: _buildFormImage(product, selectedImage),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Tap to choose or replace image',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                          decoration: _inputDecoration('Category'),
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
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isSaving ? null : submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    product == null
                                        ? 'Add Product'
                                        : 'Save Changes',
                                    style: const TextStyle(
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
          color: primary,
          size: 32,
        ),
      );
    }
    return const Icon(
      Icons.add_photo_alternate_outlined,
      color: primary,
      size: 34,
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
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
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
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFEAEFF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 82,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.broken_image_outlined,
                      color: primary,
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    color: primary,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.category,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 7),
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
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
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 9),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    SizedBox(width: 9),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _searchQuery.isEmpty ? 'No products yet' : 'No matching products',
              style: const TextStyle(
                color: dark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _searchQuery.isEmpty
                  ? 'Start building your digital catalogue by adding your first product.'
                  : 'Try searching with another product name.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _businessId == null ? null : () => _showProductForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add your first product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Product Catalogue',
          style: TextStyle(
            color: dark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _businessId == null ? null : () => _showProductForm(),
            icon: const Icon(Icons.add_circle_outline, color: primary),
            tooltip: 'Add product',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Manage all your products in one place.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.inventory_2_outlined,
                              value: '${_products.length}',
                              label: 'Total products',
                              color: const Color(0xFFEAF0FF),
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: _summaryCard(
                              icon: Icons.currency_rupee,
                              value: '₹${_totalValue.toStringAsFixed(0)}',
                              label: 'Total listed value',
                              color: const Color(0xFFE9F9F1),
                              iconColor: const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Total listed value is the sum of product prices, not inventory value.',
                        style: TextStyle(color: muted, fontSize: 9),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search, color: muted),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(13),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: products.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
                          itemCount: products.length,
                          itemBuilder: (_, index) =>
                              _buildProductCard(products[index]),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _businessId == null
            ? null
            : () => _showProductForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    Color iconColor = primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 25),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: dark,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
