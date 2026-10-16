import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_product_model.dart';
import '../../providers/vendor_products_provider.dart';
import 'add_product_screen.dart';

class VendorProductsScreen extends StatefulWidget {
  const VendorProductsScreen({super.key});

  @override
  State<VendorProductsScreen> createState() => _VendorProductsScreenState();
}

class _VendorProductsScreenState extends State<VendorProductsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorProductsProvider>().fetchProducts();
    });
  }

  void _applyFilter(String filter) {
    setState(() => _selectedFilter = filter);
    final provider = context.read<VendorProductsProvider>();
    if (filter == 'brand_new' || filter == 'uk_used') {
      provider.fetchProducts(condition: filter);
    } else if (filter == 'bike' || filter == 'keke') {
      provider.fetchProducts(packageTier: filter);
    } else {
      provider.fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorProductsProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Catalog & Logistics Fleet Desk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Product',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All Items', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('✨ Brand New', 'brand_new'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🇬🇧 UK Used', 'uk_used'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🏍️ Bike', 'bike'),
                  const SizedBox(width: 8),
                  _buildFilterChip('🛺 Keke Cargo', 'keke'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Product List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : provider.products.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: () => provider.fetchProducts(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.products.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final product = provider.products[index];
                            return _buildProductCard(context, product);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      selectedColor: AppColors.primaryPurple,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.primaryPurple : AppColors.border),
      ),
      onSelected: (_) => _applyFilter(value),
    );
  }

  Widget _buildProductCard(BuildContext context, VendorProductModel product) {
    final provider = context.read<VendorProductsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Badges (Condition, Fleet Tier, Video)
          Row(
            children: [
              // Condition Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: product.isUkUsed ? const Color(0xFFEEF2FF) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  product.isUkUsed ? '🇬🇧 UK USED' : '✨ BRAND NEW',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: product.isUkUsed ? const Color(0xFF4338CA) : const Color(0xFF15803D),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Fleet Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: product.isKekeCargo ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  product.isKekeCargo ? '🛺 KEKE CARGO' : '🏍️ BIKE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: product.isKekeCargo ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                  ),
                ),
              ),

              if (product.videoUrl != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.play_circle_fill, size: 10, color: Color(0xFFDC2626)),
                      SizedBox(width: 3),
                      Text('VIDEO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Stock Switch
              Row(
                children: [
                  Text(
                    product.isInStock ? 'In Stock' : 'Out of Stock',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: product.isInStock ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: product.isInStock,
                      activeColor: AppColors.success,
                      onChanged: (val) {
                        provider.toggleStock(product.id, isInStock: val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main Product Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.inventory_2, color: AppColors.primaryPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),

                    // Price with Slash price & Discount % badge
                    Row(
                      children: [
                        Text(
                          CurrencyFormatter.format(product.unitPrice),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
                        ),
                        if (product.slashPrice != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.format(product.slashPrice!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (product.discountPercent != null && product.discountPercent! > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${product.discountPercent}% OFF',
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.categoryName} • ${product.warrantyLabel}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 7-Day Freshness Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.isFresh ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      product.isFresh ? Icons.bolt : Icons.warning_amber_rounded,
                      size: 13,
                      color: product.isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isFresh ? 'Freshness Active (${product.daysRemaining}d left)' : 'Freshness Expired (Confirm Stock)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: product.isFresh ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Stock: ${product.inventoryQuantity}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: product.inventoryQuantity <= 5 ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Freshness Refresh Action
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryPurple,
                    side: const BorderSide(color: AppColors.primaryPurple, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.refresh, size: 15),
                  label: const Text('Confirm Freshness (+7 Days)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  onPressed: () async {
                    final ok = await provider.refreshFreshness(product.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Freshness for '${product.name}' extended for 7 days."),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No products listed yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('Tap the + button below to add your first product.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
