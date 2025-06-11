import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart_item.dart';
import '../models/payment_method.dart';
import '../models/product_model.dart';
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

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData with _$HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomePage();
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData with _$ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfilePage();
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with _$SettingsRoute {
  final String? tab;

  const SettingsRoute({this.tab});

  @override
  Widget build(BuildContext context, GoRouterState state) => SettingsPage(
      initialTab: tab != null ? SettingsTab.values.byName(tab!) : null);
}

@TypedGoRoute<UserRoute>(
  path: '/user/:userId',
  routes: [
    TypedGoRoute<UserProfileRoute>(path: 'profile'),
    TypedGoRoute<UserPostsRoute>(
      path: 'posts',
      routes: [
        TypedGoRoute<PostDetailRoute>(path: ':postId'),
      ],
    ),
  ],
)
class UserRoute extends GoRouteData with _$UserRoute {
  final String userId;

  const UserRoute({required this.userId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UserPage(userId: userId);
}

class UserProfileRoute extends GoRouteData with _$UserProfileRoute {
  final String userId;

  const UserProfileRoute({required this.userId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UserProfilePage(userId: userId);
}

class UserPostsRoute extends GoRouteData with _$UserPostsRoute {
  final String userId;

  const UserPostsRoute({required this.userId});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      UserPostsPage(userId: userId);
}

class PostDetailRoute extends GoRouteData with _$PostDetailRoute {
  final String userId;
  final String postId;
  final bool showComments;

  const PostDetailRoute({
    required this.userId,
    required this.postId,
    this.showComments = false,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => PostDetailPage(
        userId: userId,
        postId: postId,
        showComments: showComments,
      );
}

@TypedGoRoute<ProductRoute>(path: '/product/:productId')
class ProductRoute extends GoRouteData with _$ProductRoute {
  final String productId;
  final ProductModel? $extra;

  const ProductRoute({
    required this.productId,
    this.$extra,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) => ProductPage(
        productId: productId,
        initialData: $extra,
      );
}

@TypedGoRoute<CheckoutRoute>(path: '/checkout')
class CheckoutRoute extends GoRouteData with _$CheckoutRoute {
  final CheckoutData $extra;

  const CheckoutRoute({required this.$extra});

  @override
  Widget build(BuildContext context, GoRouterState state) => CheckoutPage(
        items: $extra.items,
        address: $extra.address,
        paymentMethod: $extra.paymentMethod,
      );
}

// Extra data wrapper
class CheckoutData {
  final List<CartItem> items;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;

  const CheckoutData({
    required this.items,
    required this.address,
    required this.paymentMethod,
  });
}
