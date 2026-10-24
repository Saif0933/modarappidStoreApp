import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/address/presentation/pages/add_address_page.dart';
import '../../features/address/presentation/pages/address_list_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_page.dart';
import '../../features/cart/presentation/pages/order_success_page.dart';
import '../../features/category/presentation/pages/category_page.dart';
import '../../features/category/presentation/pages/product_categories_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_layout.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/order_history_page.dart';
import '../../features/orders/presentation/pages/order_tracking_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
// Import pages (we will create these files shortly)
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/wishlist/presentation/pages/wishlist_page.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: RouteNames.onboarding,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      name: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/otp',
      name: RouteNames.otp,
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpPage(phoneNumber: phone);
      },
    ),

    // ShellRoute for tabs
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/categories',
          name: RouteNames.categories,
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) => const OrderHistoryPage(),
        ),
        GoRoute(
          path: '/wishlist',
          name: RouteNames.wishlist,
          builder: (context, state) => const WishlistPage(),
        ),
        GoRoute(
          path: '/profile',
          name: RouteNames.profile,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // Sub pages that should slide from right and cover bottom bar
    GoRoute(
      path: '/cart',
      name: RouteNames.cart,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/search',
      name: RouteNames.search,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra;
        final initialQuery = extra is Map
            ? extra['query'] as String?
            : (extra is String ? extra : null);
        return SearchPage(initialQuery: initialQuery);
      },
    ),
    GoRoute(
      path: '/notifications',
      name: RouteNames.notifications,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const NotificationPage(),
    ),
    GoRoute(
      path: '/product-details',
      name: RouteNames.productDetails,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        // Safe cast extra
        final productMap = state.extra as Map<String, dynamic>? ?? {};
        return ProductDetailsPage(productData: productMap);
      },
    ),
    GoRoute(
      path: '/product-categories',
      name: RouteNames.productCategories,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final categoryName = extra['category'] as String? ?? "Men's Fashion";
        return ProductCategoriesPage(categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/checkout',
      name: RouteNames.checkout,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: '/order-success',
      name: RouteNames.orderSuccess,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.extra as String? ?? 'ORD-98231';
        return OrderSuccessPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-history',
      name: RouteNames.orderHistory,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const OrderHistoryPage(),
    ),
    GoRoute(
      path: '/order-tracking',
      name: RouteNames.orderTracking,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final orderId = state.extra as String? ?? 'MRP12345678';
        return OrderTrackingPage(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/order-details',
      name: RouteNames.orderDetails,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final statusParam = state.uri.queryParameters['status'];
        OrderDetailStatus status = OrderDetailStatus.delivered;
        if (statusParam != null) {
          switch (statusParam.toLowerCase()) {
            case 'cancelled':
              status = OrderDetailStatus.cancelled;
              break;
            case 'refunded':
              status = OrderDetailStatus.refunded;
              break;
            case 'returnrequested':
            case 'return_requested':
              status = OrderDetailStatus.returnRequested;
              break;
            case 'returning':
              status = OrderDetailStatus.returning;
              break;
            case 'returnrefunded':
            case 'return_refunded':
              status = OrderDetailStatus.returnRefunded;
              break;
            default:
              status = OrderDetailStatus.delivered;
          }
        }
        final extraStatus = state.extra is OrderDetailStatus
            ? state.extra as OrderDetailStatus
            : null;
        final orderId =
            state.uri.queryParameters['orderId'] ?? 'OD438063137903616100';
        return OrderDetailsPage(
          initialStatus: extraStatus ?? status,
          orderId: orderId,
        );
      },
    ),
    GoRoute(
      path: '/address-list',
      name: RouteNames.addressList,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddressListPage(),
    ),
    GoRoute(
      path: '/addresses',
      name: 'addresses',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddressListPage(),
    ),
    GoRoute(
      path: '/add-address',
      name: RouteNames.addAddress,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AddAddressPage(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: RouteNames.editProfile,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/settings',
      name: RouteNames.settings,
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
