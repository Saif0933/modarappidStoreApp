import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../shared/providers/products_provider.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'Popular';
  double _priceLimit = 200.0;
  double _selectedRating = 0.0;

  final List<String> _categories = [
    'All',
    'Jackets',
    'Hoodies',
    'Jeans',
    'Footwear',
    'Dresses',
    'Accessories',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allProducts = ref.watch(productsProvider);
    final wishlist = ref.watch(wishlistProvider);

    // Apply Filter & Search Logic
    List<Product> filteredProducts = allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = p.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            p.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesPrice = p.price <= _priceLimit;
      final matchesRating = p.rating >= _selectedRating;

      return matchesCategory && matchesSearch && matchesPrice && matchesRating;
    }).toList();

    // Apply Sorting Logic
    if (_sortBy == 'Price: Low to High') {
      filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Rating') {
      filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Block
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: CustomSearchBar(
                hintText: 'Search in categories...',
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
              ),
            ),

            // Horizontal Categories Scroll Bar
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        side: BorderSide(
                          color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            
            // Sort & Filter Controls Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM, vertical: AppConstants.spaceS),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredProducts.length} Items found',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      // Sort Taps
                      TextButton.icon(
                        icon: const Icon(Icons.sort_rounded, size: 18, color: AppColors.primary),
                        label: Text(_sortBy, style: const TextStyle(color: AppColors.primary)),
                        onPressed: () => _showSortBottomSheet(context),
                      ),
                      const SizedBox(width: 8),
                      // Filter Taps
                      TextButton.icon(
                        icon: const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                        label: const Text('Filter', style: TextStyle(color: AppColors.primary)),
                        onPressed: () => _showFilterBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products Grid View
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('No products matched your search/filters.'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: AppConstants.gridSpacing,
                        mainAxisSpacing: AppConstants.gridSpacing,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return ProductCard(
                          id: product.id,
                          title: product.title,
                          imageUrl: product.imageUrl,
                          price: product.price,
                          originalPrice: product.originalPrice,
                          rating: product.rating,
                          reviewsCount: product.reviewsCount,
                          weight: product.weight,
                          isWishlisted: wishlist.contains(product.id),
                          onTap: () => context.push('/product-details', extra: {
                            'id': product.id,
                            'title': product.title,
                            'imageUrl': product.imageUrl,
                            'price': product.price,
                            'originalPrice': product.originalPrice,
                            'rating': product.rating,
                            'reviewsCount': product.reviewsCount,
                            'weight': product.weight,
                            'description': product.description,
                            'category': product.category,
                          }),
                          onAddToCart: () {
                            ref.read(cartProvider.notifier).addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.title} added to cart!'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          onWishlistTap: () {
                            ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spaceL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...['Popular', 'Price: Low to High', 'Price: High to Low', 'Rating'].map((option) {
                final isSelected = _sortBy == option;
                return ListTile(
                  title: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() {
                      _sortBy = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppConstants.spaceL,
                right: AppConstants.spaceL,
                top: AppConstants.spaceL,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceL,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  
                  // Price Filter
                  Text(
                    'Max Price (\$${_priceLimit.toStringAsFixed(1)})',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: _priceLimit,
                    min: 10.0,
                    max: 200.0,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setSheetState(() {
                        _priceLimit = val;
                      });
                      setState(() {
                        _priceLimit = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rating Filter
                  Text(
                    'Minimum Rating',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      final isSelected = _selectedRating == starValue;
                      return ChoiceChip(
                        label: Row(
                          children: [
                            Text('$starValue'),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onSelected: (selected) {
                          setSheetState(() {
                            _selectedRating = selected ? starValue : 0.0;
                          });
                          setState(() {
                            _selectedRating = selected ? starValue : 0.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          child: const Text('Reset'),
                          onPressed: () {
                            setSheetState(() {
                              _priceLimit = 200.0;
                              _selectedRating = 0.0;
                            });
                            setState(() {
                              _priceLimit = 200.0;
                              _selectedRating = 0.0;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          child: const Text('Apply'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
