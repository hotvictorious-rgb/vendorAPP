import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/vendor_image_picker_service.dart';
import '../../providers/vendor_products_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

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
  int _selectedCategoryId = 1;
  String _condition = 'brand_new';
  String _packageTier = 'bike';
  String _warrantyType = 'in_store_testing';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProductsProvider>().fetchCategories();
    });
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
    final ok = await provider.createProduct(
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
    );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product '$name' published with 7-day freshness active!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to publish product.'),
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
        title: const Text('Add Product to Catalog'),
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
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '50000',
                                prefixText: '₦ ',
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('SLASH PRICE (₦)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _slashPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '60000 (Optional)',
                                prefixText: '₦ ',
                                filled: true,
                                fillColor: AppColors.scaffoldBackground,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stock & Category
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('STOCK QUANTITY *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '10',
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
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CATEGORY *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: categories.any((item) => item.value == _selectedCategoryId)
                                  ? _selectedCategoryId
                                  : (categories.isNotEmpty ? categories.first.value : 1),
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

                  // Product Photo Picker (Camera or Gallery)
                  const Text('PRODUCT PHOTO (CAMERA / GALLERY)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
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
                                Text('Product Photo Selected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

                  const SizedBox(height: 12),

                  // Optional Image URL Fallback
                  if (_pickedImage == null) ...[
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
                    : const Text('Publish Product', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white)),
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
                color: selected ? AppColors.primaryPurple : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}