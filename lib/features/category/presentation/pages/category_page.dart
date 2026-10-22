import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/network_image_widget.dart';
import '../../../../shared/providers/products_provider.dart';

/// Model representing a main parent category on the left sidebar
class ParentCategoryItem {
  final String id;
  final String title;
  final String imageUrl;

  const ParentCategoryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });
}

/// Model representing an individual subcategory item in the right grid
class SubcategoryGridItem {
  final String name;
  final String? imageUrl;
  final bool isViewAll;

  const SubcategoryGridItem({
    required this.name,
    this.imageUrl,
    this.isViewAll = false,
  });
}

/// Model representing a grouped section of subcategories (e.g. "Men's Clothing")
class SubcategorySection {
  final String title;
  final List<SubcategoryGridItem> items;

  const SubcategorySection({
    required this.title,
    required this.items,
  });
}

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  // Selected Sidebar Category ID (defaults to 'fashion' matching the screenshot)
  String _selectedParentId = 'fashion';

  // 1. Parent Categories matching the left sidebar in the reference image
  static const List<ParentCategoryItem> _parentCategories = [
    ParentCategoryItem(
      id: 'fashion',
      title: 'Fashion',
      imageUrl:
          'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=200',
    ),
    ParentCategoryItem(
      id: 'mobiles',
      title: 'Mobiles',
      imageUrl:
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200',
    ),
    ParentCategoryItem(
      id: 'appliances',
      title: 'Appliances',
      imageUrl:
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=200',
    ),
    ParentCategoryItem(
      id: 'electronics',
      title: 'Electronics',
      imageUrl:
          'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=200',
    ),
    ParentCategoryItem(
      id: 'gadgets',
      title: 'Smart Gadgets',
      imageUrl:
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=200',
    ),
    ParentCategoryItem(
      id: 'home',
      title: 'Home',
      imageUrl:
          'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=200',
    ),
    ParentCategoryItem(
      id: 'beauty',
      title: 'Beauty &\nPersonal Care',
      imageUrl:
          'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=200',
    ),
    ParentCategoryItem(
      id: 'toys',
      title: 'Toys & Baby\nCare',
      imageUrl:
          'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=200',
    ),
  ];

  // Selected Gender / Subcategory Filter inside Fashion ('All', 'Women', 'Men', 'Kids')
  String _selectedFashionFilter = 'All';

  // 2. Curated Subcategory Sections for Fashion
  // Women's Clothing Section
  static const SubcategorySection _womensClothingSection = SubcategorySection(
    title: "Women's Clothing",
    items: [
      SubcategoryGridItem(
        name: 'Sarees',
        imageUrl:
            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=300',
      ),
      SubcategoryGridItem(
        name: 'Kurtas & Sets',
        imageUrl:
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=300',
      ),
      SubcategoryGridItem(
        name: 'Western\nDresses',
        imageUrl:
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=300',
      ),
      SubcategoryGridItem(
        name: 'Tops & Tees',
        imageUrl:
            'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=300',
      ),
      SubcategoryGridItem(
        name: 'Jeans &\nJeggings',
        imageUrl:
            'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=300',
      ),
      SubcategoryGridItem(
        name: 'Ethnic Wear',
        imageUrl:
            'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=300',
      ),
      SubcategoryGridItem(
        name: 'Nightwear',
        imageUrl:
            'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Women's Footwear & Bags Section
  static const SubcategorySection _womensFootwearSection = SubcategorySection(
    title: "Women's Footwear & Bags",
    items: [
      SubcategoryGridItem(
        name: 'Flats &\nSandals',
        imageUrl:
            'https://images.unsplash.com/photo-1562273138-f46be4ebdf33?w=300',
      ),
      SubcategoryGridItem(
        name: 'Heels &\nWedges',
        imageUrl:
            'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=300',
      ),
      SubcategoryGridItem(
        name: 'Handbags',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=300',
      ),
      SubcategoryGridItem(
        name: 'Jewellery',
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=300',
      ),
      SubcategoryGridItem(
        name: 'Sneakers',
        imageUrl:
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Kids' Clothing Section
  static const SubcategorySection _kidsClothingSection = SubcategorySection(
    title: "Kids' Clothing",
    items: [
      SubcategoryGridItem(
        name: 'Boys\nT-Shirts',
        imageUrl:
            'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=300',
      ),
      SubcategoryGridItem(
        name: 'Girls\nDresses',
        imageUrl:
            'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=300',
      ),
      SubcategoryGridItem(
        name: 'Boys Jeans\n& Shorts',
        imageUrl:
            'https://images.unsplash.com/photo-1503944583220-79d8926ad5e2?w=300',
      ),
      SubcategoryGridItem(
        name: 'Girls Tops\n& Skirts',
        imageUrl:
            'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=300',
      ),
      SubcategoryGridItem(
        name: 'Kids\nEthnic',
        imageUrl:
            'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=300',
      ),
      SubcategoryGridItem(
        name: 'Infant &\nRompers',
        imageUrl:
            'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=300',
      ),
      SubcategoryGridItem(
        name: 'Sleepwear',
        imageUrl:
            'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Kids' Footwear & Essentials Section
  static const SubcategorySection _kidsFootwearSection = SubcategorySection(
    title: "Kids' Footwear & Accessories",
    items: [
      SubcategoryGridItem(
        name: 'Kids\nSneakers',
        imageUrl:
            'https://images.unsplash.com/photo-1514989940723-e8e51635b782?w=300',
      ),
      SubcategoryGridItem(
        name: 'School\nShoes',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
      ),
      SubcategoryGridItem(
        name: 'School\nBags',
        imageUrl:
            'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300',
      ),
      SubcategoryGridItem(
        name: 'Kids\nWatches',
        imageUrl:
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Men's Clothing Section
  static const SubcategorySection _mensClothingSection = SubcategorySection(
    title: "Men's Clothing",
    items: [
      SubcategoryGridItem(
        name: 'Jackets',
        imageUrl:
            'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=300',
      ),
      SubcategoryGridItem(
        name: 'Bottomwear',
        imageUrl:
            'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=300',
      ),
      SubcategoryGridItem(
        name: 'Topwear',
        imageUrl:
            'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=300',
      ),
      SubcategoryGridItem(
        name: 'Ethnic Wear',
        imageUrl:
            'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=300',
      ),
      SubcategoryGridItem(
        name: 'Budget buys',
        imageUrl:
            'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?w=300',
      ),
      SubcategoryGridItem(
        name: 'Blazers &\nSuits',
        imageUrl:
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=300',
      ),
      SubcategoryGridItem(
        name: 'Formal Wear',
        imageUrl:
            'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Men's Footwear & Accessories Section
  static const SubcategorySection _mensFootwearSection = SubcategorySection(
    title: "Men's Footwear & Accessories",
    items: [
      SubcategoryGridItem(
        name: 'Sports Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
      ),
      SubcategoryGridItem(
        name: 'Sneakers',
        imageUrl:
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=300',
      ),
      SubcategoryGridItem(
        name: 'Watches',
        imageUrl:
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=300',
      ),
      SubcategoryGridItem(
        name: 'Luggage...',
        imageUrl:
            'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=300',
      ),
      SubcategoryGridItem(
        name: 'sunglasses',
        imageUrl:
            'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=300',
      ),
      SubcategoryGridItem(
        name: "Men's\nJewellery",
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=300',
      ),
      SubcategoryGridItem(
        name: 'Casual Shoes',
        imageUrl:
            'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=300',
      ),
      SubcategoryGridItem(
        name: 'View All',
        isViewAll: true,
      ),
    ],
  );

  // Filter helper returning active sections based on chip filter
  List<SubcategorySection> _getFashionSections() {
    switch (_selectedFashionFilter) {
      case 'Women':
        return [_womensClothingSection, _womensFootwearSection];
      case 'Kids':
        return [_kidsClothingSection, _kidsFootwearSection];
      case 'Men':
        return [_mensClothingSection, _mensFootwearSection];
      case 'All':
      default:
        return [
          _womensClothingSection,
          _mensClothingSection,
          _kidsClothingSection,
          _womensFootwearSection,
          _mensFootwearSection,
          _kidsFootwearSection,
        ];
    }
  }

  // 3. Fallback Subcategory Sections for other categories
  static const Map<String, List<SubcategorySection>> _otherCategorySections = {
    'mobiles': [
      SubcategorySection(
        title: 'Smartphones',
        items: [
          SubcategoryGridItem(
            name: 'Apple iPhones',
            imageUrl:
                'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300',
          ),
          SubcategoryGridItem(
            name: 'Samsung Galaxy',
            imageUrl:
                'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=300',
          ),
          SubcategoryGridItem(
            name: 'Budget 5G Phones',
            imageUrl:
                'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=300',
          ),
          SubcategoryGridItem(
            name: 'View All',
            isViewAll: true,
          ),
        ],
      ),
      SubcategorySection(
        title: 'Mobile Accessories',
        items: [
          SubcategoryGridItem(
            name: 'Cases & Covers',
            imageUrl:
                'https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=300',
          ),
          SubcategoryGridItem(
            name: 'Fast Chargers',
            imageUrl:
                'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=300',
          ),
          SubcategoryGridItem(
            name: 'Power Banks',
            imageUrl:
                'https://images.unsplash.com/photo-1609592424364-75ce86071066?w=300',
          ),
        ],
      ),
    ],
    'appliances': [
      SubcategorySection(
        title: 'Televisions & Large Appliances',
        items: [
          SubcategoryGridItem(
            name: 'Smart TVs',
            imageUrl:
                'https://images.unsplash.com/photo-1593784991095-a205069470b6?w=300',
          ),
          SubcategoryGridItem(
            name: 'Washing Machines',
            imageUrl:
                'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?w=300',
          ),
          SubcategoryGridItem(
            name: 'Refrigerators',
            imageUrl:
                'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?w=300',
          ),
        ],
      ),
    ],
    'electronics': [
      SubcategorySection(
        title: 'Laptops & Computers',
        items: [
          SubcategoryGridItem(
            name: 'Gaming Laptops',
            imageUrl:
                'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=300',
          ),
          SubcategoryGridItem(
            name: 'Thin & Light',
            imageUrl:
                'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=300',
          ),
          SubcategoryGridItem(
            name: 'Computer Moniors',
            imageUrl:
                'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=300',
          ),
        ],
      ),
    ],
    'gadgets': [
      SubcategorySection(
        title: 'Smart Wearables & Audio',
        items: [
          SubcategoryGridItem(
            name: 'Smart Watches',
            imageUrl:
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300',
          ),
          SubcategoryGridItem(
            name: 'Fitness Bands',
            imageUrl:
                'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=300',
          ),
          SubcategoryGridItem(
            name: 'Wireless Earbuds',
            imageUrl:
                'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300',
          ),
        ],
      ),
    ],
    'home': [
      SubcategorySection(
        title: 'Home & Kitchen Essentials',
        items: [
          SubcategoryGridItem(
            name: 'Cookware',
            imageUrl:
                'https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=300',
          ),
          SubcategoryGridItem(
            name: 'Bedding & Linen',
            imageUrl:
                'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=300',
          ),
          SubcategoryGridItem(
            name: 'Home Decor',
            imageUrl:
                'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=300',
          ),
        ],
      ),
    ],
    'beauty': [
      SubcategorySection(
        title: 'Beauty, Skincare & Grooming',
        items: [
          SubcategoryGridItem(
            name: 'Fragrances',
            imageUrl:
                'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=300',
          ),
          SubcategoryGridItem(
            name: 'Skincare',
            imageUrl:
                'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=300',
          ),
          SubcategoryGridItem(
            name: 'Hair Care',
            imageUrl:
                'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=300',
          ),
        ],
      ),
    ],
    'toys': [
      SubcategorySection(
        title: 'Kids & Baby Clothing',
        items: [
          SubcategoryGridItem(
            name: 'Rompers &\nBodysuits',
            imageUrl:
                'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=300',
          ),
          SubcategoryGridItem(
            name: 'Girls Frocks',
            imageUrl:
                'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=300',
          ),
          SubcategoryGridItem(
            name: 'Boys Tees',
            imageUrl:
                'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=300',
          ),
          SubcategoryGridItem(
            name: 'View All',
            isViewAll: true,
          ),
        ],
      ),
      SubcategorySection(
        title: 'Toys & Baby Care',
        items: [
          SubcategoryGridItem(
            name: 'Soft Toys',
            imageUrl:
                'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=300',
          ),
          SubcategoryGridItem(
            name: 'Action Figures',
            imageUrl:
                'https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=300',
          ),
          SubcategoryGridItem(
            name: 'Baby Diapers',
            imageUrl:
                'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?w=300',
          ),
        ],
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get current active sections for the selected sidebar category
    final sections = _selectedParentId == 'fashion'
        ? _getFashionSections()
        : (_otherCategorySections[_selectedParentId] ?? _getFashionSections());

    // Watch cart items for dynamic badge
    final cartItems = ref.watch(cartProvider);
    final cartCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar matching screenshot ("All Categories", Search, Cart with "15" badge)
            _buildTopBar(isDark: isDark, cartCount: cartCount),

            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

            // 2. Main Content Split View (Left Sidebar + Right Subcategories Grid)
            Expanded(
              child: Row(
                children: [
                  // Left Sidebar (~86px width)
                  Container(
                    width: 86,
                    color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _parentCategories.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 0.8,
                        color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      ),
                      itemBuilder: (context, index) {
                        final cat = _parentCategories[index];
                        final isSelected = cat.id == _selectedParentId;
                        return _buildSidebarItem(
                          item: cat,
                          isSelected: isSelected,
                          isDark: isDark,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _selectedParentId = cat.id;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  // Subtle Vertical Divider between Sidebar and Content
                  Container(
                    width: 1,
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),

                  // Right Subcategories Content Panel
                  Expanded(
                    child: Container(
                      color: isDark ? AppColors.bgDark : Colors.white,
                      child: Column(
                        children: [
                          if (_selectedParentId == 'fashion')
                            _buildFashionFilterChips(isDark: isDark),
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: sections.length,
                              itemBuilder: (context, sectionIndex) {
                                final section = sections[sectionIndex];
                                return _buildSubcategorySection(
                                  section: section,
                                  isDark: isDark,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Top App Bar matching screenshot
  Widget _buildTopBar({required bool isDark, required int cartCount}) {
    return Container(
      color: isDark ? AppColors.surfaceDark : Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "All Categories" Title
          Text(
            'All Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500, // Matching exact clean text in screenshot
              color: isDark ? Colors.white : const Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
          ),

          // Search & Cart Icons Row
          Row(
            children: [
              // Search Icon
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  size: 24,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/search');
                },
              ),

              // Cart Icon with Red "15" Badge from Screenshot
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 24,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          cartCount > 0 ? '$cartCount' : '15',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/cart');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fashion Quick Filter Chips ('All', 'Women', 'Kids', 'Men')
  Widget _buildFashionFilterChips({required bool isDark}) {
    const filters = ['All', 'Women', 'Kids', 'Men'];
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
            width: 0.8,
          ),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == _selectedFashionFilter;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedFashionFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : (isDark ? AppColors.surfaceDark : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (isDark ? AppColors.borderDark : const Color(0xFFCBD5E1)),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.textSecondaryDark : const Color(0xFF475569)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 2. Individual Left Sidebar Item
  Widget _buildSidebarItem({
    required ParentCategoryItem item,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 88,
        color: isSelected
            ? (isDark ? AppColors.bgDark : Colors.white)
            : Colors.transparent,
        child: Stack(
          children: [
            // Left blue accent indicator strip for selected item
            if (isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB), // Primary Blue
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(3)),
                  ),
                ),
              ),

            // Category Thumbnail & Label
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: isDark
                            ? AppColors.surfaceDark
                            : const Color(0xFFF1F5F9),
                        child: NetworkImageWidget(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Category Title Label
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFF2563EB) // Blue for selected
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : const Color(0xFF64748B)), // Slate for unselected
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Subcategory Section (Header + 3-Column Grid)
  Widget _buildSubcategorySection({
    required SubcategorySection section,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (e.g. "Men's Clothing", "Men's Footwear & Accessories")
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
          child: Text(
            section.title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ),

        // 3-Column Grid of Subcategories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: section.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final item = section.items[index];
              return _buildSubcategoryCard(
                item: item,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (item.isViewAll) {
                    // Navigate to all products in search
                    context.push('/search', extra: {'query': section.title});
                  } else {
                    // Navigate to specific subcategory
                    context.push('/search', extra: {'query': item.name.replaceAll('\n', ' ')});
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. Subcategory Card (Soft rounded square with image & label)
  Widget _buildSubcategoryCard({
    required SubcategoryGridItem item,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          // Soft rounded container with image or "View All" arrow
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : const Color(0xFFF0F6FF), // Soft sky-blue/grey tint from screenshot
              borderRadius: BorderRadius.circular(item.isViewAll ? 38 : 16),
            ),
            child: item.isViewAll
                ? Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Color(0xFF2563EB),
                        size: 28,
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: NetworkImageWidget(
                        imageUrl: item.imageUrl ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),

          // Subcategory Name Label
          Expanded(
            child: Text(
              item.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
