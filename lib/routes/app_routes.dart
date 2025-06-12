abstract class AppRoute {
  String get path;
  Map<String, String> get pathParameters => {};
  Map<String, String> get queryParameters => {};
  Object? get extra => null;
  
  String buildPath() {
    var path = this.path;
    pathParameters.forEach((key, value) {
      path = path.replaceAll(':$key', value);
    });
    
    if (queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      path = '$path?$queryString';
    }
    
    return path;
  }
}

class HomeRoute extends AppRoute {
  @override
  String get path => '/';
}

class ProfileRoute extends AppRoute {
  @override
  String get path => '/profile';
}

class SettingsRoute extends AppRoute {
  final int? initialTab;
  
  SettingsRoute({this.initialTab});
  
  @override
  String get path => '/settings';
  
  @override
  Map<String, String> get queryParameters => 
    initialTab != null ? {'tab': initialTab.toString()} : {};
}

class UserRoute extends AppRoute {
  final String userId;
  
  UserRoute({required this.userId});
  
  @override
  String get path => '/user/:userId';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

class UserProfileRoute extends AppRoute {
  final String userId;
  
  UserProfileRoute({required this.userId});
  
  @override
  String get path => '/user/:userId/profile';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

class UserPostsRoute extends AppRoute {
  final String userId;
  
  UserPostsRoute({required this.userId});
  
  @override
  String get path => '/user/:userId/posts';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

class PostDetailRoute extends AppRoute {
  final String userId;
  final String postId;
  
  PostDetailRoute({required this.userId, required this.postId});
  
  @override
  String get path => '/user/:userId/posts/:postId';
  
  @override
  Map<String, String> get pathParameters => {
    'userId': userId,
    'postId': postId,
  };
}

class ProductRoute extends AppRoute {
  final String productId;
  
  ProductRoute({required this.productId});
  
  @override
  String get path => '/product/:productId';
  
  @override
  Map<String, String> get pathParameters => {'productId': productId};
}

class CheckoutRoute extends AppRoute {
  final List<dynamic> items;
  final dynamic address;
  final dynamic paymentMethod;
  
  CheckoutRoute({
    required this.items,
    required this.address,
    required this.paymentMethod,
  });
  
  @override
  String get path => '/checkout';
  
  @override
  Object get extra => {
    'items': items,
    'address': address,
    'paymentMethod': paymentMethod,
  };
}