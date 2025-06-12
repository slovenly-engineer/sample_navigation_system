import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';
import '../models/settings_data.dart';
import '../models/shipping_address.dart';
import '../screens/checkout_page.dart';
import '../screens/home_page.dart';
import '../screens/post_detail_page.dart';
import '../screens/product_page.dart';
import '../screens/profile_page.dart';
import '../screens/settings_page.dart';
import '../screens/user_page.dart';
import '../screens/user_posts_page.dart';
import '../screens/user_profile_page.dart';
import '../services/navigation_service.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final routerProvider = Provider<GoRouter>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          final tabString = state.uri.queryParameters['tab'];
          SettingsTab? initialTab;
          if (tabString != null) {
            final tabIndex = int.tryParse(tabString);
            if (tabIndex != null && tabIndex >= 0 && tabIndex < SettingsTab.values.length) {
              initialTab = SettingsTab.values[tabIndex];
            }
          }
          return SettingsPage(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserPage(userId: userId);
        },
        routes: [
          GoRoute(
            path: 'profile',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserProfilePage(userId: userId);
            },
          ),
          GoRoute(
            path: 'posts',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return UserPostsPage(userId: userId);
            },
            routes: [
              GoRoute(
                path: ':postId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  final postId = state.pathParameters['postId']!;
                  return PostDetailPage(userId: userId, postId: postId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            throw Exception('Checkout requires extra data');
          }
          
          final items = extra['items'] as List<CartItem>;
          final address = extra['address'] as ShippingAddress;
          final paymentMethod = extra['paymentMethod'] as PaymentMethod;
          
          return CheckoutPage(
            items: items,
            address: address,
            paymentMethod: paymentMethod,
          );
        },
      ),
    ],
  );
});

final navigationServiceProvider = Provider<NavigationService>((ref) {
  final router = ref.watch(routerProvider);
  return NavigationService(router);
});