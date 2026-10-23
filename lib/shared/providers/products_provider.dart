import 'package:flutter_riverpod/flutter_riverpod.dart';

// Product Model
class Product {
  final String id;
  final String title;
  final String? brand;
  final String? badgeText;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double? bankOfferPrice;
  final double rating;
  final int reviewsCount;
  final String weight; // Serves as "Size/Weight"
  final String description;
  final String category;
  final bool isPopular;
  final bool isRecommended;
  final bool isTrending;

  const Product({
    required this.id,
    required this.title,
    this.brand,
    this.badgeText,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.bankOfferPrice,
    required this.rating,
    required this.reviewsCount,
    required this.weight,
    required this.description,
    required this.category,
    this.isPopular = false,
    this.isRecommended = false,
    this.isTrending = false,
  });
}

// Cart Item Model
class CartItem {
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  const CartItem({
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}

// Address Model
class Address {
  final String id;
  final String name;
  final String addressLine;
  final String city;
  final String phone;
  final bool isDefault;

  Address({
    required this.id,
    required this.name,
    required this.addressLine,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? name,
    String? addressLine,
    String? city,
    String? phone,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// Order Model
class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime date;
  final String status; // 'Pending', 'Processing', 'Shipped', 'Delivered'

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
  });
}

// Global Products List (Fashion Store Items)
final productsProvider = Provider<List<Product>>((ref) {
  return [
    // Image-matching products from screenshot
    Product(
      id: 'feed_p1',
      brand: 'Jammy & Kammo',
      title: 'Men Casual Winter Biker Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600',
      price: 763.0,
      originalPrice: 3600.0,
      rating: 4.5,
      reviewsCount: 340,
      weight: 'L',
      description: 'Jammy & Kammo Men Black Solid Biker Jacket with shearling fur trim, heavy duty front zipper, and windproof thermal inner lining.',
      category: 'Jackets',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'feed_p2',
      brand: 'VELLOSTA',
      title: 'Men Regular Fit Textured High Neck Shirt',
      imageUrl: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=600',
      price: 340.0,
      originalPrice: 1499.0,
      rating: 4.3,
      reviewsCount: 890,
      weight: 'M',
      description: 'VELLOSTA stylish powder-blue textured waffle-knit high-neck casual shirt with diagonal button closure.',
      category: 'Topwear',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'feed_p3',
      brand: 'aadi',
      title: "Men's Comfortable Lightweight Sneakers",
      badgeText: 'Lowest price live',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600',
      price: 383.0,
      originalPrice: 1999.0,
      rating: 4.4,
      reviewsCount: 1240,
      weight: 'UK 8',
      description: "aadi ultra-comfortable lightweight retro casual sneakers for men with cushioned insole and non-slip sole.",
      category: 'Footwear',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'feed_p4',
      title: 'Apple Macbook Neo A18 (16GB, 512GB SSD)',
      imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600',
      price: 79900.0,
      bankOfferPrice: 74900.0,
      rating: 4.7,
      reviewsCount: 1600,
      weight: '1.24 kg',
      description: 'Apple MacBook Neo with A18 chip, Liquid Retina display, all-day battery life, and unified high-speed memory.',
      category: 'Laptops',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'feed_p5',
      brand: 'Highlander',
      title: 'Men Slim Fit Solid Bomber Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=600',
      price: 599.0,
      originalPrice: 2499.0,
      rating: 4.4,
      reviewsCount: 520,
      weight: 'M',
      description: 'Highlander Men Solid Bomber Casual Jacket with rib knit collar and cuffs.',
      category: 'Jackets',
      isPopular: true,
    ),
    Product(
      id: 'feed_p6',
      brand: 'Boult Audio',
      title: 'AirBass True Wireless Earbuds with ENC',
      imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600',
      price: 1299.0,
      originalPrice: 3999.0,
      bankOfferPrice: 1099.0,
      rating: 4.6,
      reviewsCount: 2400,
      weight: '45g',
      description: 'Boult Audio AirBass Earbuds with 40H playtime, ENC environmental noise cancellation, and fast charging.',
      category: 'Gadgets',
      isPopular: true,
    ),
    Product(
      id: 'p1',
      title: 'EyeBogler Men Solid Bomber Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1548883354-7622d03aca27?w=500',
      price: 449.0,
      originalPrice: 2499.0,
      rating: 4.8,
      reviewsCount: 142,
      weight: 'L',
      description: 'EyeBogler men solid lightweight zipper bomber jacket. Crafted from high quality polyester blend with ribbed cuffs and hem.',
      category: 'Jackets',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p2',
      title: 'FUTSE PENO Men Bomber Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500',
      price: 700.0,
      originalPrice: 3000.0,
      rating: 4.6,
      reviewsCount: 280,
      weight: 'M',
      description: 'FUTSE PENO winter casual jacket with fleece lining and turn-down collar. Premium warmth and urban aesthetics.',
      category: 'Jackets',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p3',
      title: 'Blaq Ash Men Solid Hooded Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1544441893-675973e31985?w=500',
      price: 1999.0,
      originalPrice: 4999.0,
      bankOfferPrice: 1799.0,
      rating: 4.9,
      reviewsCount: 312,
      weight: 'XL',
      description: 'Blaq Ash heavy-duty padded hooded jacket with multi-pocket utility and faux fur insulation.',
      category: 'Jackets',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p4',
      title: 'Blaq Ash Men Leather Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=500',
      price: 1835.0,
      originalPrice: 4999.0,
      bankOfferPrice: 1651.0,
      rating: 4.5,
      reviewsCount: 98,
      weight: 'L',
      description: 'Blaq Ash classic brown faux leather moto biker jacket with removable thermal hood.',
      category: 'Jackets',
      isTrending: true,
      isRecommended: true,
    ),
    Product(
      id: 'p5',
      title: 'FUTSE PENO Men Windcheater',
      imageUrl: 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=500',
      price: 700.0,
      originalPrice: 3000.0,
      rating: 4.7,
      reviewsCount: 85,
      weight: 'M',
      description: 'FUTSE PENO colorblock windbreaker casual jacket designed for daily outdoor styling.',
      category: 'Jackets',
      isTrending: true,
      isRecommended: true,
    ),
    Product(
      id: 'p6',
      title: 'EyeBogler Men Solid Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1509539662397-116cb90542f1?w=500',
      price: 428.0,
      originalPrice: 2499.0,
      rating: 4.4,
      reviewsCount: 167,
      weight: 'M',
      description: 'EyeBogler olive green stylish casual front-zip windcheater jacket.',
      category: 'Jackets',
      isTrending: true,
      isRecommended: true,
    ),
    Product(
      id: 'p7',
      title: 'Minimalist Leather Backpack',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500',
      price: 99.99,
      rating: 4.8,
      reviewsCount: 76,
      weight: 'Standard',
      description: 'Crafted from water-resistant vegan leather. Features a dedicated 15-inch padded laptop compartment, concealed anti-theft pockets, and padded shoulder straps for maximum comfort.',
      category: 'Accessories',
      isPopular: true,
    ),
    Product(
      id: 'p8',
      title: 'Crewneck Cotton Classic T-Shirt',
      imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=500',
      price: 19.99,
      rating: 4.3,
      reviewsCount: 420,
      weight: 'XL',
      description: '100% combed ring-spun cotton. Ultra-breathable, pre-shrunk, and double-stitched at the hems for extra durability. An essential foundation for any wardrobe.',
      category: 'T-Shirts',
      isTrending: true,
    ),
    Product(
      id: 'p9',
      title: 'Embroidered Banarasi Silk Saree',
      imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500',
      price: 1499.0,
      originalPrice: 4999.0,
      bankOfferPrice: 1349.0,
      rating: 4.8,
      reviewsCount: 382,
      weight: 'Free Size',
      description: 'Stunning woven zari border Banarasi art silk saree with unstitched blouse piece. Perfect for festive ceremonies and weddings.',
      category: 'Sarees',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p10',
      title: 'Women Floral Anarkali Kurta Set',
      imageUrl: 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=500',
      price: 999.0,
      originalPrice: 2999.0,
      bankOfferPrice: 899.0,
      rating: 4.7,
      reviewsCount: 215,
      weight: 'M',
      description: 'Pure cotton printed Anarkali kurta with matching pant and chiffon dupatta set for women.',
      category: 'Kurtas & Sets',
      isTrending: true,
      isPopular: true,
    ),
    Product(
      id: 'p11',
      title: 'Women Elegant Floral Summer Dress',
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500',
      price: 799.0,
      originalPrice: 2199.0,
      rating: 4.6,
      reviewsCount: 144,
      weight: 'S',
      description: 'Chic fit and flare printed midi dress crafted from breathable georgette fabric with waist tie-up.',
      category: 'Dresses',
      isRecommended: true,
    ),
    Product(
      id: 'p12',
      title: 'Boys Printed Pure Cotton T-Shirt',
      imageUrl: 'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=500',
      price: 349.0,
      originalPrice: 999.0,
      rating: 4.5,
      reviewsCount: 92,
      weight: '4-5Y',
      description: 'Super soft 100% bio-washed cotton round neck graphic printed casual t-shirt for boys.',
      category: 'Kids',
      isPopular: true,
    ),
    Product(
      id: 'p13',
      title: 'Girls Layered Party Frock Dress',
      imageUrl: 'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8?w=500',
      price: 699.0,
      originalPrice: 1999.0,
      rating: 4.9,
      reviewsCount: 178,
      weight: '5-6Y',
      description: 'Embellished net party dress with soft inner lining and back zipper for girls.',
      category: 'Kids',
      isTrending: true,
      isRecommended: true,
    ),
    Product(
      id: 'p14',
      title: 'Infant Cotton Romper & Sleepsuit',
      imageUrl: 'https://images.unsplash.com/photo-1522771930-78848d9293e8?w=500',
      price: 399.0,
      originalPrice: 899.0,
      rating: 4.8,
      reviewsCount: 110,
      weight: '6-12M',
      description: 'Ultra-gentle organic cotton snap-button baby romper designed for all-day comfort.',
      category: 'Kids',
      isPopular: true,
    ),
  ];
});

// Wishlist State Notifier
class WishlistNotifier extends StateNotifier<Set<String>> {
  WishlistNotifier() : super({});

  void toggleWishlist(String productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
  }

  void remove(String productId) {
    state = {...state}..remove(productId);
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier();
});

// Cart State Notifier
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier()
      : super([
          const CartItem(
            product: Product(
              id: 'c1',
              brand: 'JCOSTA',
              title: 'Men Solid Casual Black Shirt',
              imageUrl: 'assets/images/cart_item_black_shirt.png',
              price: 699.0,
              originalPrice: 999.0,
              rating: 4.8,
              reviewsCount: 320,
              weight: 'M',
              description: 'Men Solid Casual Black Shirt with breathable cotton fabric.',
              category: 'Shirts',
            ),
            quantity: 1,
            selectedSize: 'M',
            selectedColor: 'Black',
          ),
          const CartItem(
            product: Product(
              id: 'c2',
              brand: "Levi's",
              title: 'Men Slim Fit Jeans',
              imageUrl: 'assets/images/cart_item_levis_jeans.png',
              price: 1499.0,
              originalPrice: 2299.0,
              rating: 4.7,
              reviewsCount: 450,
              weight: '32',
              description: 'Classic durable slim fit denim jeans for men.',
              category: 'Jeans',
            ),
            quantity: 1,
            selectedSize: '32',
            selectedColor: 'Blue',
          ),
          const CartItem(
            product: Product(
              id: 'c3',
              brand: 'Roadster',
              title: 'Men Regular Fit T-Shirt',
              imageUrl: 'assets/images/cart_item_roadster_tshirt.png',
              price: 499.0,
              originalPrice: 799.0,
              rating: 4.6,
              reviewsCount: 280,
              weight: 'L',
              description: 'Pure cotton round neck regular fit casual t-shirt.',
              category: 'T-Shirts',
            ),
            quantity: 1,
            selectedSize: 'L',
            selectedColor: 'White',
          ),
        ]);

  void addToCart(Product product, {int qty = 1, String? size, String? color}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + qty),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [
        ...state,
        CartItem(
          product: product,
          quantity: qty,
          selectedSize: size ?? product.weight,
          selectedColor: color ?? 'Black',
        ),
      ];
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  void updateSize(String productId, String size) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(selectedSize: size);
      }
      return item;
    }).toList();
  }

  void updateColor(String productId, String color) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(selectedColor: color);
      }
      return item;
    }).toList();
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalMrp => state.fold(0.0, (sum, item) => sum + ((item.product.originalPrice ?? item.product.price) * item.quantity));
  double get subtotal => state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  double get itemDiscount => totalMrp - subtotal;
  double get deliveryFee => state.isEmpty ? 0.0 : 30.0;
  double get shipping => deliveryFee;
  double get tax => 0.0;
  double get total => subtotal + deliveryFee;
  double get savings => itemDiscount;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Selected Address Provider
final selectedAddressProvider = StateProvider<Address?>((ref) {
  return Address(
    id: 'a1',
    name: 'Home',
    addressLine: 'Indira Nagar, House No. 123,',
    city: 'Lucknow, Uttar Pradesh - 226016',
    phone: '+91 98765 43210',
    isDefault: true,
  );
});

// Address List Provider
class AddressListNotifier extends StateNotifier<List<Address>> {
  AddressListNotifier() : super([
    Address(
      id: 'a1',
      name: 'Home',
      addressLine: 'Indira Nagar, House No. 123,',
      city: 'Lucknow, Uttar Pradesh - 226016',
      phone: '+91 98765 43210',
      isDefault: true,
    ),
    Address(
      id: 'a2',
      name: 'Office',
      addressLine: 'Hazratganj, Commercial Tower, 4th Floor',
      city: 'Lucknow, Uttar Pradesh - 226001',
      phone: '+91 98765 43210',
      isDefault: false,
    ),
  ]);

  void addAddress(Address address) {
    if (address.isDefault) {
      state = state.map((a) => a.copyWith(isDefault: false)).toList();
    }
    state = [...state, address];
  }

  void editAddress(Address address) {
    if (address.isDefault) {
      state = state.map((a) {
        if (a.id == address.id) return address;
        return a.copyWith(isDefault: false);
      }).toList();
    } else {
      state = state.map((a) => a.id == address.id ? address : a).toList();
    }
  }

  void deleteAddress(String addressId) {
    state = state.where((a) => a.id != addressId).toList();
  }
}

final addressListProvider = StateNotifierProvider<AddressListNotifier, List<Address>>((ref) {
  return AddressListNotifier();
});

// Orders Provider
class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier() : super([
    Order(
      id: 'ORD-87123',
      items: [
        CartItem(
          product: Product(
            id: 'p3',
            title: 'Retro Streetwear Running Sneakers',
            imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
            price: 89.99,
            rating: 4.9,
            reviewsCount: 312,
            weight: 'US 10',
            description: 'Features lightweight responsive cushioning and breathable mesh panels.',
            category: 'Footwear',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 89.99,
      date: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Delivered',
    ),
  ]);

  void placeOrder(List<CartItem> items, double totalAmount) {
    final newOrder = Order(
      id: 'ORD-${10000 + state.length * 7 + (items.length * 13)}',
      items: items,
      totalAmount: totalAmount,
      date: DateTime.now(),
      status: 'Processing',
    );
    state = [newOrder, ...state];
  }
}

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  return OrdersNotifier();
});
