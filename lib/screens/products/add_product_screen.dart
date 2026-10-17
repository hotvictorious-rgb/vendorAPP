import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/vendor_image_picker_service.dart';
import '../../models/vendor_product_model.dart';
import '../../providers/vendor_products_provider.dart';

class AddProductScreen extends StatefulWidget {
  final VendorProductModel? productToEdit;

  const AddProductScreen({super.key, this.productToEdit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _slashPriceController = TextEditingController();
  final _quantityController = TextEditingController(text: '10');
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _pickedImage;
  final List<File> _galleryFiles = [];
  int _selectedCategoryId = 1;
  String _condition = 'brand_new';
  String _packageTier = 'bike';
  String _warrantyType = 'in_store_testing';

  bool get isEditing => widget.productToEdit != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProductsProvider>().fetchCategories();
    });

    if (widget.productToEdit != null) {
      final p = widget.productToEdit!;
      _nameController.text = p.name;
      _priceController.text = p.unitPrice;
      _slashPriceController.text = p.slashPrice ?? '';
      _quantityController.text = p.inventoryQuantity.toString();
      _descriptionController.text = p.description ?? '';
      _videoUrlController.text = p.videoUrl ?? '';
      _imageUrlController.text = p.imagePath ?? '';
      _selectedCategoryId = p.categoryId ?? 1;
      _condition = p.condition;
      _packageTier = p.packageTier;
      _warrantyType = p.warrantyType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _slashPriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    final slashPrice = double.tryParse(_slashPriceController.text.trim());
    final qty = int.tryParse(_quantityController.text.trim());

    if (name.isEmpty || price == null || price <= 0 || qty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields with valid values.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (slashPrice != null && slashPrice <= price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Original Slash Price must be higher than Selling Price.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final provider = context.read<VendorProductsProvider>();
    bool ok;

    if (isEditing) {
      ok = await provider.updateProduct(
        productId: widget.productToEdit!.id,
        name: name,
        price: price,
        slashPrice: slashPrice,
        quantity: qty,
        categoryId: _selectedCategoryId,
        condition: _condition,
        packageTier: _packageTier,
        warrantyType: _warrantyType,
        description: _descriptionController.text.trim(),
        videoUrl: _videoUrlController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
        imageFile: _pickedImage,
        galleryFiles: _galleryFiles.isNotEmpty ? _galleryFiles : null,
      );
    } else {
      ok = await provider.createProduct(
        name: name,
        price: price,
        slashPrice: slashPrice,
        quantity: qty,
        categoryId: _selectedCategoryId,
        condition: _condition,
        packageTier: _packageTier,
        warrantyType: _warrantyType,
        description: _descriptionController.text.trim(),
        videoUrl: _videoUrlController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
        imageFile: _pickedImage,
        galleryFiles: _galleryFiles.isNotEmpty ? _galleryFiles : null,
      );
    }

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? "Product '$name' updated successfully!"
              : "Product '$name' published with 7-day freshness active!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? (isEditing ? 'Failed to update product.' : 'Failed to publish product.')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProductsProvider>();

    final categories = provider.categories
        .map((c) => DropdownMenuItem<int>(
              value: c.id,
              child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product Catalog Item' : 'Add Product to Catalog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRODUCT TITLE *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Hisense 43" Smart TV or Uyo Bell Peppers',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pricing: Selling Price & Original Slash Price
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SELLING PRICE (₦) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _priceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixText: '₦ ',
                                hintText: '25,000',
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ORIGINAL SLASH PRICE (₦)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _slashPriceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixText: '₦ ',
                                hintText: '30,000 (Optional)',
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Inventory Quantity & Category
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STOCK QUANTITY *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'e.g. 10',
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CATEGORY *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: categories.any((c) => c.value == _selectedCategoryId) ? _selectedCategoryId : (categories.isNotEmpty ? categories.first.value : null),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                              items: categories,
                              onChanged: (v) => setState(() => _selectedCategoryId = v ?? 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Retail Condition Selector
                  const Text('ITEM CONDITION (NIGERIAN MARKETPLACE STANDARD) *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: '✨ Brand New',
                          sub: 'Factory Sealed Pack',
                          selected: _condition == 'brand_new',
                          onTap: () => setState(() => _condition = 'brand_new'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          label: '🇬🇧 UK Used',
                          sub: 'Clean Grade A Pre-owned',
                          selected: _condition == 'uk_used',
                          onTap: () => setState(() => _condition = 'uk_used'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logistics Fleet Tier (Bike vs Keke Cargo)
                  const Text('DELIVERY LOGISTICS FLEET TIER *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Select Keke Cargo for heavy appliances, TV screens, bulk food bags, or generators.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: '🏍️ Bike Dispatch',
                          sub: 'Standard Parcel Box',
                          selected: _packageTier == 'bike',
                          onTap: () => setState(() => _packageTier = 'bike'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          label: '🛺 Keke Cargo',
                          sub: 'Heavy / Bulky Surcharge',
                          selected: _packageTier == 'keke',
                          onTap: () => setState(() => _packageTier = 'keke'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Warranty Guarantee Dropdown
                  const Text('WARRANTY & BUYER PROTECTION *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _warrantyType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'in_store_testing', child: Text('Doorstep / In-Store Testing on Arrival')),
                      DropdownMenuItem(value: '7_days_replacement', child: Text('7-Day Return / Replacement Warranty')),
                      DropdownMenuItem(value: 'brand_warranty', child: Text('Official Manufacturer Brand Warranty')),
                      DropdownMenuItem(value: 'as_is', child: Text('Sold As-Is (No Warranty After Testing)')),
                    ],
                    onChanged: (v) => setState(() => _warrantyType = v ?? 'in_store_testing'),
                  ),
                  const SizedBox(height: 16),

                  // Primary Product Photo (Camera or Gallery)
                  const Text('PRIMARY PRODUCT PHOTO (CAMERA / GALLERY)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),

                  if (_pickedImage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _pickedImage!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Primary Photo Selected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Will be optimized for mobile catalog view', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => setState(() => _pickedImage = null),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: AppColors.primaryPurple),
                            ),
                            icon: const Icon(Icons.camera_alt, size: 18, color: AppColors.primaryPurple),
                            label: const Text('Take Photo', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                            onPressed: () async {
                              final photo = await VendorImagePickerService.pickFromCamera();
                              if (photo != null) {
                                setState(() => _pickedImage = photo);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            icon: const Icon(Icons.photo_library, size: 18, color: AppColors.textSecondary),
                            label: const Text('From Gallery', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                            onPressed: () async {
                              final photo = await VendorImagePickerService.pickFromGallery();
                              if (photo != null) {
                                setState(() => _pickedImage = photo);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Multi-photo Gallery Photos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GALLERY PHOTOS (UP TO 10 PHOTOS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      TextButton.icon(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                        icon: const Icon(Icons.add_photo_alternate, size: 16, color: AppColors.primaryPurple),
                        label: const Text('Add Gallery Photos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.primaryPurple)),
                        onPressed: () async {
                          final photos = await VendorImagePickerService.pickMultiImage();
                          if (photos.isNotEmpty) {
                            setState(() {
                              _galleryFiles.addAll(photos);
                              if (_galleryFiles.length > 10) {
                                _galleryFiles.removeRange(10, _galleryFiles.length);
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (_galleryFiles.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galleryFiles.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_galleryFiles[i], width: 72, height: 72, fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(() => _galleryFiles.removeAt(i)),
                                  child: Container(
                                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Optional Image URL Fallback
                  if (_pickedImage == null && _galleryFiles.isEmpty) ...[
                    const Text('OR PASTE IMAGE URL (CDN / HOSTED)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://images.unsplash.com/... or https://res.cloudinary.com/...',
                        prefixIcon: const Icon(Icons.link, size: 18),
                        filled: true,
                        fillColor: AppColors.scaffoldBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Optional YouTube Video
                  const Text('YOUTUBE UNBOXING / DEMO VIDEO (OPTIONAL)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _videoUrlController,
                    decoration: InputDecoration(
                      hintText: 'https://youtube.com/watch?v=... or https://youtu.be/...',
                      prefixIcon: const Icon(Icons.video_library_outlined, size: 18),
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Product specifications, origin, quality guarantees...',
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: provider.isLoading ? null : _submit,
                child: provider.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEditing ? 'Save & Update Product' : 'Publish Product', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required String sub,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple.withOpacity(0.08) : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : AppColors.border,
            width: selected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: selected ? AppColors.primaryPurple : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primaryPurple.withOpacity(0.8) : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}