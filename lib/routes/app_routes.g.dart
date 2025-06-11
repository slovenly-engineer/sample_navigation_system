// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
      $profileRoute,
      $settingsRoute,
      $userRoute,
      $productRoute,
      $checkoutRoute,
    ];

RouteBase get $homeRoute => GoRouteData.$route(
      path: '/',
      factory: _$HomeRoute._fromState,
    );

mixin _$HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $profileRoute => GoRouteData.$route(
      path: '/profile',
      factory: _$ProfileRoute._fromState,
    );

mixin _$ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location(
        '/profile',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $settingsRoute => GoRouteData.$route(
      path: '/settings',
      factory: _$SettingsRoute._fromState,
    );

mixin _$SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => SettingsRoute(
        tab: state.uri.queryParameters['tab'],
      );

  SettingsRoute get _self => this as SettingsRoute;

  @override
  String get location => GoRouteData.$location(
        '/settings',
        queryParams: {
          if (_self.tab != null) 'tab': _self.tab,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $userRoute => GoRouteData.$route(
      path: '/user/:userId',
      factory: _$UserRoute._fromState,
      routes: [
        GoRouteData.$route(
          path: 'profile',
          factory: _$UserProfileRoute._fromState,
        ),
        GoRouteData.$route(
          path: 'posts',
          factory: _$UserPostsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: ':postId',
              factory: _$PostDetailRoute._fromState,
            ),
          ],
        ),
      ],
    );

mixin _$UserRoute on GoRouteData {
  static UserRoute _fromState(GoRouterState state) => UserRoute(
        userId: state.pathParameters['userId']!,
      );

  UserRoute get _self => this as UserRoute;

  @override
  String get location => GoRouteData.$location(
        '/user/${Uri.encodeComponent(_self.userId)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UserProfileRoute on GoRouteData {
  static UserProfileRoute _fromState(GoRouterState state) => UserProfileRoute(
        userId: state.pathParameters['userId']!,
      );

  UserProfileRoute get _self => this as UserProfileRoute;

  @override
  String get location => GoRouteData.$location(
        '/user/${Uri.encodeComponent(_self.userId)}/profile',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$UserPostsRoute on GoRouteData {
  static UserPostsRoute _fromState(GoRouterState state) => UserPostsRoute(
        userId: state.pathParameters['userId']!,
      );

  UserPostsRoute get _self => this as UserPostsRoute;

  @override
  String get location => GoRouteData.$location(
        '/user/${Uri.encodeComponent(_self.userId)}/posts',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin _$PostDetailRoute on GoRouteData {
  static PostDetailRoute _fromState(GoRouterState state) => PostDetailRoute(
        userId: state.pathParameters['userId']!,
        postId: state.pathParameters['postId']!,
        showComments: _$convertMapValue(
                'show-comments', state.uri.queryParameters, _$boolConverter) ??
            false,
      );

  PostDetailRoute get _self => this as PostDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/user/${Uri.encodeComponent(_self.userId)}/posts/${Uri.encodeComponent(_self.postId)}',
        queryParams: {
          if (_self.showComments != false)
            'show-comments': _self.showComments.toString(),
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $productRoute => GoRouteData.$route(
      path: '/product/:productId',
      factory: _$ProductRoute._fromState,
    );

mixin _$ProductRoute on GoRouteData {
  static ProductRoute _fromState(GoRouterState state) => ProductRoute(
        productId: state.pathParameters['productId']!,
        $extra: state.extra as ProductModel?,
      );

  ProductRoute get _self => this as ProductRoute;

  @override
  String get location => GoRouteData.$location(
        '/product/${Uri.encodeComponent(_self.productId)}',
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $checkoutRoute => GoRouteData.$route(
      path: '/checkout',
      factory: _$CheckoutRoute._fromState,
    );

mixin _$CheckoutRoute on GoRouteData {
  static CheckoutRoute _fromState(GoRouterState state) => CheckoutRoute(
        $extra: state.extra as CheckoutData,
      );

  CheckoutRoute get _self => this as CheckoutRoute;

  @override
  String get location => GoRouteData.$location(
        '/checkout',
      );

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}
