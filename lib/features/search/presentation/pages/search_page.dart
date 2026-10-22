import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../shared/providers/products_provider.dart';

// State Provider to store search history
final searchHistoryProvider = StateProvider<List<String>>((ref) {
  return ['Sneakers', 'Jackets', 'Distressed Jeans'];
});

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<String> _popularSearches = [
    'Sarees',
    'Kurtas & Sets',
    'Girls Dresses',
    'Boys T-Shirts',
    'Leather Jacket',
    'Running Shoes',
    'Summer Dress',
    'Denim Jeans',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _query = widget.initialQuery!.trim();
      _searchController.text = _query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    final history = ref.read(searchHistoryProvider);
    if (!history.contains(query)) {
      ref.read(searchHistoryProvider.notifier).state = [query, ...history].take(5).toList();
    }
    setState(() {
      _query = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final history = ref.watch(searchHistoryProvider);
    final allProducts = ref.watch(productsProvider);
    final wishlist = ref.watch(wishlistProvider);

    // Filtered Suggested Products based on search query
    final searchResults = allProducts.where((p) {
      return p.title.toLowerCase().contains(_query.toLowerCase()) ||
          p.category.toLowerCase().contains(_query.toLowerCase()) ||
          p.description.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Custom Search Header
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceM),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: CustomSearchBar(
                          controller: _searchController,
                          hintText: 'Search products...',
                          onChanged: (val) {
                            setState(() {
                              _query = val;
                            });
                          },
                          onSubmitted: _onSearchSubmit,
                        ),
                      ),
                      if (_query.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clearSearch,
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content Area
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: ResponsiveBreakpoints.maxContentWidth),
                  child: _query.isEmpty
                      ? SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Recent Searches Section
                              if (history.isNotEmpty) ...[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Recent Searches',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(searchHistoryProvider.notifier).state = [];
                                      },
                                      child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: history.map((term) {
                                    return ActionChip(
                                      label: Text(term),
                                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                        side: BorderSide(
                                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                        ),
                                      ),
                                      onPressed: () {
                                        _searchController.text = term;
                                        _onSearchSubmit(term);
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // 2. Popular Searches Section
                              Text(
                                'Popular Searches',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _popularSearches.map((term) {
                                  return ActionChip(
                                    label: Text(term),
                                    backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      side: BorderSide(
                                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                      ),
                                    ),
                                    onPressed: () {
                                      _searchController.text = term;
                                      _onSearchSubmit(term);
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                      : searchResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textSecondaryLight),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No Results Found for "$_query"',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Try checking your spelling or searching for another term.'),
                                ],
                              ),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final cols = Responsive.adaptiveProductColumns(constraints.maxWidth);
                                final aspectRatio = cols >= 4 ? 0.74 : (cols == 3 ? 0.72 : 0.68);
                                return GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    childAspectRatio: aspectRatio,
                                    crossAxisSpacing: AppConstants.gridSpacing,
                                    mainAxisSpacing: AppConstants.gridSpacing,
                                  ),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final product = searchResults[index];
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
                                );
                              },
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
