import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../models/settings_data.dart';
import '../models/product_model.dart';
import '../models/cart_item.dart';
import '../models/shipping_address.dart';
import '../models/payment_method.dart';

/// アプリケーションの全ルートを定義するSealed Class
sealed class AppRoute {
  const AppRoute();
  
  /// 対応するGoRouteDataインスタンスを返す
  GoRouteData get routeData;
}

// ===== 各ルートの実装 =====

class Home extends AppRoute {
  const Home();
  
  @override
  HomeRoute get routeData => const HomeRoute();
}

class Profile extends AppRoute {
  const Profile();
  
  @override
  ProfileRoute get routeData => const ProfileRoute();
}

class Settings extends AppRoute {
  final SettingsTab? initialTab;
  
  const Settings({this.initialTab});
  
  @override
  SettingsRoute get routeData => SettingsRoute(tab: initialTab?.name);
}

class User extends AppRoute {
  final String userId;
  
  const User({required this.userId});
  
  @override
  UserRoute get routeData => UserRoute(userId: userId);
}

class UserProfile extends AppRoute {
  final String userId;
  
  const UserProfile({required this.userId});
  
  @override
  UserProfileRoute get routeData => UserProfileRoute(userId: userId);
}

class UserPosts extends AppRoute {
  final String userId;
  
  const UserPosts({required this.userId});
  
  @override
  UserPostsRoute get routeData => UserPostsRoute(userId: userId);
}

class PostDetail extends AppRoute {
  final String userId;
  final String postId;
  final bool showComments;
  
  const PostDetail({
    required this.userId,
    required this.postId,
    this.showComments = false,
  });
  
  @override
  PostDetailRoute get routeData => PostDetailRoute(
    userId: userId,
    postId: postId,
    showComments: showComments,
  );
}

class Product extends AppRoute {
  final String productId;
  final ProductModel? initialData;
  
  const Product({
    required this.productId,
    this.initialData,
  });
  
  @override
  ProductRoute get routeData => ProductRoute(
    productId: productId,
    $extra: initialData,
  );
}

class Checkout extends AppRoute {
  final List<CartItem> items;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;
  
  const Checkout({
    required this.items,
    required this.address,
    required this.paymentMethod,
  });
  
  @override
  CheckoutRoute get routeData => CheckoutRoute(
    $extra: CheckoutData(
      items: items,
      address: address,
      paymentMethod: paymentMethod,
    ),
  );
}