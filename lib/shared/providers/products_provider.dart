import 'package:flutter_riverpod/flutter_riverpod.dart';

// Product Model
class Product {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewsCount;
  final String weight; // Serves as "Size/Weight"
  final String description;
  final String category;
  final bool isPopular;
  final bool isRecommended;
  final bool isTrending;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
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

  CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
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
    Product(
      id: 'p1',
      title: 'Urban Leather Biker Jacket',
      imageUrl: 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=500',
      price: 129.99,
      originalPrice: 159.99,
      rating: 4.8,
      reviewsCount: 142,
      weight: 'L',
      description: 'Crafted from premium full-grain genuine leather. Features an asymmetrical front zipper closure, zippered cuffs, and a quilted polyester lining. Built for durability and timeless urban style.',
      category: 'Jackets',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p2',
      title: 'Classic Cotton Essentials Hoodie',
      imageUrl: 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=500',
      price: 49.99,
      originalPrice: 59.99,
      rating: 4.6,
      reviewsCount: 280,
      weight: 'M',
      description: 'Super soft fleece fabric with a double-lined hood and adjustable drawstring. Front kangaroo pocket. Ribbed cuffs and waistband prevent draft. Perfect for everyday lounging or casual wear.',
      category: 'Hoodies',
      isPopular: true,
      isTrending: true,
    ),
    Product(
      id: 'p3',
      title: 'Retro Streetwear Running Sneakers',
      imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
      price: 89.99,
      rating: 4.9,
      reviewsCount: 312,
      weight: 'US 10',
      description: 'Features lightweight responsive cushioning and breathable mesh panels. Rubber outsole provides maximum traction on wet and dry surfaces. Finished with iconic retro detailing.',
      category: 'Footwear',
      isRecommended: true,
      isTrending: true,
    ),
    Product(
      id: 'p4',
      title: 'Slim Fit Distressed Denim Jeans',
      imageUrl: 'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500',
      price: 69.99,
      originalPrice: 79.99,
      rating: 4.5,
      reviewsCount: 98,
      weight: '32/32',
      description: 'Slim-fit denim crafted from cotton with a hint of stretch for active mobility. Classic 5-pocket styling with hand-distressed detailing around the knees. Built to last.',
      category: 'Jeans',
      isPopular: true,
      isRecommended: true,
    ),
    Product(
      id: 'p5',
      title: 'Floral Print Summer Midi Dress',
      imageUrl: 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500',
      price: 59.99,
      rating: 4.7,
      reviewsCount: 85,
      weight: 'S',
      description: 'Flowy, lightweight fabric with an elasticated waist and adjustable straps. Features a sweet floral print pattern and side slit for elegance. Perfect for casual dates or beach walks.',
      category: 'Dresses',
      isTrending: true,
    ),
    Product(
      id: 'p6',
      title: 'Classic Aviator Polarized Sunglasses',
      imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500',
      price: 29.99,
      originalPrice: 39.99,
      rating: 4.4,
      reviewsCount: 167,
      weight: 'One Size',
      description: 'Timeless aviator design featuring polarized lenses with 100% UV400 protection. Durable metal frame with soft nose pads for comfortable all-day wear. Includes a protective leather case.',
      category: 'Accessories',
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
  CartNotifier() : super([]);

  void addToCart(Product product, {int qty = 1}) {
    final existingIndex = state.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final item = state[existingIndex];
      state = [
        ...state.sublist(0, existingIndex),
        item.copyWith(quantity: item.quantity + qty),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      state = [...state, CartItem(product: product, quantity: qty)];
    }
  }

  void updateQuantity(String productId, int quantity) {
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
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

  double get subtotal => state.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  double get tax => subtotal * 0.05; // 5% VAT
  double get shipping => subtotal > 50 ? 0.0 : 9.99; // Free shipping above $50
  double get total => subtotal + tax + shipping;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Selected Address Provider
final selectedAddressProvider = StateProvider<Address?>((ref) {
  return Address(
    id: 'a1',
    name: 'Saif Al-Islam',
    addressLine: '128 High Street, Flat 4B',
    city: 'New York, NY 10001',
    phone: '+1 234-567-8910',
    isDefault: true,
  );
});

// Address List Provider
class AddressListNotifier extends StateNotifier<List<Address>> {
  AddressListNotifier() : super([
    Address(
      id: 'a1',
      name: 'Saif Al-Islam',
      addressLine: '128 High Street, Flat 4B',
      city: 'New York, NY 10001',
      phone: '+1 234-567-8910',
      isDefault: true,
    ),
    Address(
      id: 'a2',
      name: 'John Doe Office',
      addressLine: 'Penthouse Floor, Tech Hub Tower',
      city: 'Brooklyn, NY 11201',
      phone: '+1 987-654-3210',
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
