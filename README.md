# Flutter GoRouter + Riverpod ナビゲーションシステム

## 目次

- [概要](#概要)
- [機能](#機能)
- [前提条件](#前提条件)
- [インストール](#インストール)
- [アーキテクチャ](#アーキテクチャ)
- [クイックスタート](#クイックスタート)
- [コアコンポーネント](#コアコンポーネント)
- [使用例](#使用例)
- [高度な使用方法](#高度な使用方法)
- [テスト](#テスト)
- [パフォーマンス考慮事項](#パフォーマンス考慮事項)
- [トラブルシューティング](#トラブルシューティング)
- [移行ガイド](#移行ガイド)
- [API リファレンス](#api-リファレンス)

## 概要

このドキュメントでは、GoRouterとRiverpodを使用したFlutterアプリケーション向けの型安全で保守しやすいナビゲーションシステムの実装方法を説明します。Sealed Classと`routeData`プロパティを使用することで、完全な型安全性とコンパイル時のエラー検出を実現します。

### 主な特徴

本実装では、Sealed Class（`AppRoute`）を使用してすべてのルートを定義し、各ルートクラスが`routeData`プロパティで対応する`GoRouteData`インスタンスを返すことで、型安全で網羅的なナビゲーションシステムを構築します。go_router_builderによる自動コード生成と組み合わせることで、パラメータの型安全性も保証されます。

## 機能

- ✅ **完全な型安全性**: Sealed Classによる網羅的なルート定義とコンパイル時エラー検出
- ✅ **明示的な紐付け**: 各AppRouteクラスが対応するGoRouteDataを明示的に指定
- ✅ **統一API**: NavigationServiceによる一貫したナビゲーションインターフェース
- ✅ **安全性**: 自動的なBuildContext検証とHot Reload対応
- ✅ **一元管理**: すべてのナビゲーションとダイアログ操作の統一インターフェース
- ✅ **保守性**: Riverpodによる依存性管理とIDEでの追跡が容易
- ✅ **拡張性**: 新しいルート追加時はコンパイルエラーで気づける

## 前提条件

- Flutter SDK 3.16+
- Dart 3.2+
- RiverpodとGoRouterの基本的な知識

## インストール

### 1. 依存関係の追加

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  flutter_riverpod: ^2.4.0
  
dev_dependencies:
  go_router_builder: ^2.4.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### 2. パッケージのインストール

```bash
flutter pub get
```

### 3. コード生成の実行

```bash
dart run build_runner build
```

## アーキテクチャ

### システム構成図

```
┌─────────────────────────────────────────────────────────┐
│                    Widget Layer                          │
│  ConsumerWidget ─────uses────> NavigationService        │
└─────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────┐
│                 Navigation Layer                         │
│  NavigationService ─────uses────> AppRoute (Sealed)     │
│         │                              │                 │
│         │                              │ extends         │
│         │                              ▼                 │
│         │                    Home, Profile, Settings...  │
│         │                              │                 │
│         │                              │ routeData       │
│         │                              ▼                 │
│         └──────uses──────> GoRouteData + Generated Code │
└─────────────────────────────────────────────────────────┘
                              │
                              │ uses
                              ▼
┌─────────────────────────────────────────────────────────┐
│                    GoRouter Layer                        │
│              GoRouter (from go_router)                   │
└─────────────────────────────────────────────────────────┘
```

## クイックスタート

### 1. Sealed Classによるルート定義

```dart
// lib/routes/app_route.dart
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../models/models.dart';

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
  GoRouteData get routeData => const HomeRoute();
}

class Profile extends AppRoute {
  const Profile();
  
  @override
  GoRouteData get routeData => const ProfileRoute();
}

class Settings extends AppRoute {
  final SettingsTab? initialTab;
  
  const Settings({this.initialTab});
  
  @override
  GoRouteData get routeData => SettingsRoute(tab: initialTab?.name);
}

class User extends AppRoute {
  final String userId;
  
  const User({required this.userId});
  
  @override
  GoRouteData get routeData => UserRoute(userId: userId);
}

class Product extends AppRoute {
  final String productId;
  final ProductModel? initialData;
  
  const Product({
    required this.productId,
    this.initialData,
  });
  
  @override
  GoRouteData get routeData => ProductRoute(
    productId: productId,
    $extra: initialData,
  );
}
```

### 2. go_router_builderのルート定義

```dart
// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:go_router_builder/go_router_builder.dart';
import 'package:flutter/material.dart';
import '../screens/screens.dart';
import '../models/models.dart';

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
  Widget build(BuildContext context, GoRouterState state) => const ProfilePage();
}

@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData with _$SettingsRoute {
  final String? tab;
  
  const SettingsRoute({this.tab});
  
  @override
  Widget build(BuildContext context, GoRouterState state) => 
    SettingsPage(initialTab: tab != null ? SettingsTab.values.byName(tab!) : null);
}

@TypedGoRoute<UserRoute>(
  path: '/user/:userId',
  routes: [
    TypedGoRoute<UserProfileRoute>(path: 'profile'),
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

@TypedGoRoute<ProductRoute>(path: '/product/:productId')
class ProductRoute extends GoRouteData with _$ProductRoute {
  final String productId;
  final ProductModel? $extra;
  
  const ProductRoute({
    required this.productId,
    this.$extra,
  });
  
  @override
  Widget build(BuildContext context, GoRouterState state) => 
    ProductPage(
      productId: productId,
      initialData: $extra,
    );
}
```

### 3. プロバイダーの設定

```dart
// lib/providers/router_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/',
    routes: $appRoutes,
  );
});
```

### 4. NavigationServiceの実装

```dart
// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';
import '../providers/router_provider.dart';

class NavigationService {
  final Ref ref;
  
  NavigationService(this.ref);
  
  GoRouter get _router => ref.read(goRouterProvider);
  BuildContext? get _context => _router.routerDelegate.navigatorKey.currentContext;
  
  /// 画面遷移（go）
  Future<bool> go(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return false;
    
    try {
      switch (route) {
        case Home():
          route.routeData.go(context);
        case Profile():
          route.routeData.go(context);
        case Settings():
          route.routeData.go(context);
        case User():
          route.routeData.go(context);
        case UserProfile():
          route.routeData.go(context);
        case Product():
          route.routeData.go(context);
        // 他のルートも同様に追加
      }
      return true;
    } catch (e) {
      debugPrint('Navigation error: $e');
      return false;
    }
  }
  
  /// 画面プッシュ
  Future<T?> push<T extends Object?>(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return null;
    
    try {
      return switch (route) {
        Home() => route.routeData.push<T>(context),
        Profile() => route.routeData.push<T>(context),
        Settings() => route.routeData.push<T>(context),
        User() => route.routeData.push<T>(context),
        UserProfile() => route.routeData.push<T>(context),
        Product() => route.routeData.push<T>(context),
        // 他のルートも同様に追加
      };
    } catch (e) {
      debugPrint('Push error: $e');
      return null;
    }
  }
  
  /// 戻る
  bool pop<T>([T? result]) {
    if (_router.canPop()) {
      _context?.pop(result);
      return true;
    }
    return false;
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});
```

### 5. メインアプリの設定

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/router_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      title: 'Navigation App',
      routerConfig: router,
    );
  }
}
```

## コアコンポーネント

### NavigationService（完全版）

```dart
// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';
import '../providers/router_provider.dart';

class NavigationService {
  final Ref ref;
  
  NavigationService(this.ref);
  
  GoRouter get _router => ref.read(goRouterProvider);
  BuildContext? get _context => _router.routerDelegate.navigatorKey.currentContext;
  
  /// 画面遷移（go）
  Future<bool> go(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return false;
    
    try {
      switch (route) {
        case Home():
          route.routeData.go(context);
        case Profile():
          route.routeData.go(context);
        case Settings():
          route.routeData.go(context);
        case User():
          route.routeData.go(context);
        case UserProfile():
          route.routeData.go(context);
        case UserPosts():
          route.routeData.go(context);
        case PostDetail():
          route.routeData.go(context);
        case Product():
          route.routeData.go(context);
        case Checkout():
          route.routeData.go(context);
      }
      return true;
    } catch (e) {
      debugPrint('Navigation error: $e');
      return false;
    }
  }
  
  /// 画面プッシュ
  Future<T?> push<T extends Object?>(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return null;
    
    try {
      return switch (route) {
        Home() => route.routeData.push<T>(context),
        Profile() => route.routeData.push<T>(context),
        Settings() => route.routeData.push<T>(context),
        User() => route.routeData.push<T>(context),
        UserProfile() => route.routeData.push<T>(context),
        UserPosts() => route.routeData.push<T>(context),
        PostDetail() => route.routeData.push<T>(context),
        Product() => route.routeData.push<T>(context),
        Checkout() => route.routeData.push<T>(context),
      };
    } catch (e) {
      debugPrint('Push error: $e');
      return null;
    }
  }
  
  /// 画面置き換え
  Future<void> pushReplacement(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return;
    
    try {
      switch (route) {
        case Home():
          route.routeData.pushReplacement(context);
        case Profile():
          route.routeData.pushReplacement(context);
        case Settings():
          route.routeData.pushReplacement(context);
        case User():
          route.routeData.pushReplacement(context);
        case UserProfile():
          route.routeData.pushReplacement(context);
        case UserPosts():
          route.routeData.pushReplacement(context);
        case PostDetail():
          route.routeData.pushReplacement(context);
        case Product():
          route.routeData.pushReplacement(context);
        case Checkout():
          route.routeData.pushReplacement(context);
      }
    } catch (e) {
      debugPrint('Push replacement error: $e');
    }
  }
  
  /// 戻る
  bool pop<T>([T? result]) {
    if (_router.canPop()) {
      _context?.pop(result);
      return true;
    }
    return false;
  }
  
  /// 戻れるかチェック
  bool canPop() => _router.canPop();
  
  // === ダイアログ・モーダル系メソッド ===
  
  Future<T?> showDialogWidget<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return null;
    
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }
  
  Future<bool> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    final result = await showDialogWidget<bool>(
      dialog: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => pop(true),
            child: Text(buttonText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = '確認',
    String cancelText = 'キャンセル',
  }) async {
    return showDialogWidget<bool>(
      dialog: AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  Future<T?> showBottomSheet<T>({
    required Widget content,
    bool isScrollControlled = false,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return null;
    
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      builder: (_) => content,
    );
  }
  
  Future<bool> showSnackBar({
    required String message,
    Duration? duration,
    SnackBarAction? action,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return false;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 3),
        action: action,
      ),
    );
    return true;
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});
```

### ルート定義の詳細例

```dart
// lib/routes/app_route.dart
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../models/models.dart';

/// Sealed Classによるルート定義
sealed class AppRoute {
  const AppRoute();
  GoRouteData get routeData;
}

// シンプルなルート
class Home extends AppRoute {
  const Home();
  
  @override
  GoRouteData get routeData => const HomeRoute();
}

// パラメータ付きルート
class Settings extends AppRoute {
  final SettingsTab? initialTab;
  
  const Settings({this.initialTab});
  
  @override
  GoRouteData get routeData => SettingsRoute(tab: initialTab?.name);
}

// 複数パラメータとクエリパラメータ
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
  GoRouteData get routeData => PostDetailRoute(
    userId: userId,
    postId: postId,
    showComments: showComments,
  );
}

// オブジェクトを渡すルート
class Product extends AppRoute {
  final String productId;
  final ProductModel? initialData;
  
  const Product({
    required this.productId,
    this.initialData,
  });
  
  @override
  GoRouteData get routeData => ProductRoute(
    productId: productId,
    $extra: initialData,
  );
}

// 複雑なデータ構造を渡すルート
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
  GoRouteData get routeData => CheckoutRoute(
    $extra: CheckoutData(
      items: items,
      address: address,
      paymentMethod: paymentMethod,
    ),
  );
}
```

## 使用例

### Widget内での基本的な使用方法

```dart
// lib/screens/example_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_route.dart';

class ExamplePage extends ConsumerWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // シンプルなナビゲーション
          ElevatedButton(
            onPressed: () => nav.go(const Home()),
            child: const Text('ホーム'),
          ),
          
          ElevatedButton(
            onPressed: () => nav.go(const Profile()),
            child: const Text('プロフィール'),
          ),
          
          // パラメータ付きナビゲーション
          ElevatedButton(
            onPressed: () => nav.go(
              const Settings(initialTab: SettingsTab.notifications),
            ),
            child: const Text('設定（通知タブ）'),
          ),
          
          ElevatedButton(
            onPressed: () => nav.go(
              const User(userId: '123'),
            ),
            child: const Text('ユーザー詳細'),
          ),
          
          // ネストしたルート
          ElevatedButton(
            onPressed: () => nav.go(
              const UserProfile(userId: '123'),
            ),
            child: const Text('ユーザープロフィール'),
          ),
          
          // 複数パラメータ
          ElevatedButton(
            onPressed: () => nav.go(
              const PostDetail(
                userId: '123',
                postId: '456',
                showComments: true,
              ),
            ),
            child: const Text('投稿詳細（コメント表示）'),
          ),
          
          // オブジェクトを渡す
          ElevatedButton(
            onPressed: () async {
              final product = await fetchProduct('789');
              nav.go(Product(
                productId: product.id,
                initialData: product,
              ));
            },
            child: const Text('商品詳細（データ付き）'),
          ),
          
          // 複雑なデータ構造
          ElevatedButton(
            onPressed: () => nav.go(
              Checkout(
                items: cartItems,
                address: selectedAddress,
                paymentMethod: selectedPayment,
              ),
            ),
            child: const Text('チェックアウト'),
          ),
          
          const Divider(),
          
          // プッシュナビゲーション
          ElevatedButton(
            onPressed: () async {
              final result = await nav.push<ProductModel>(
                const Product(productId: '123'),
              );
              if (result != null) {
                nav.showSnackBar(
                  message: '選択された商品: ${result.name}',
                );
              }
            },
            child: const Text('商品選択（結果を受け取る）'),
          ),
          
          // 確認ダイアログ
          ElevatedButton(
            onPressed: () async {
              final confirmed = await nav.showConfirmDialog(
                title: '確認',
                message: '本当に削除しますか？',
                confirmText: '削除',
              );
              
              if (confirmed == true) {
                nav.showSnackBar(message: '削除しました');
              }
            },
            child: const Text('確認ダイアログ'),
          ),
        ],
      ),
    );
  }
}
```

### ビジネスロジック内での使用方法

```dart
// lib/controllers/user_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_route.dart';

class UserController extends StateNotifier<AsyncValue<User?>> {
  final NavigationService _nav;
  final AuthService _authService;
  
  UserController(this._nav, this._authService) : super(const AsyncValue.loading());
  
  /// ユーザーログイン
  Future<void> loginUser(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      
      // ログイン成功時の画面遷移
      final success = await _nav.go(const Home());
      if (success) {
        _nav.showSnackBar(message: 'ログインしました');
      }
      
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      
      _nav.showAlert(
        title: 'エラー',
        message: 'ログインに失敗しました: $error',
      );
    }
  }
  
  /// プロフィール編集
  Future<void> editProfile() async {
    final result = await _nav.push<ProfileEditResult>(
      const ProfileEdit()
    );
    
    if (result != null) {
      _nav.showSnackBar(message: 'プロフィールを更新しました');
      // 状態を更新
      state = AsyncValue.data(result.updatedUser);
    }
  }
  
  /// ログアウト
  Future<void> logout() async {
    final confirmed = await _nav.showConfirmDialog(
      title: '確認',
      message: 'ログアウトしますか？',
    );
    
    if (confirmed == true) {
      await _authService.logout();
      state = const AsyncValue.data(null);
      await _nav.go(const Login());
    }
  }
}

final userControllerProvider = StateNotifierProvider<UserController, AsyncValue<User?>>((ref) {
  final nav = ref.read(navigationServiceProvider);
  final auth = ref.read(authServiceProvider);
  return UserController(nav, auth);
});
```

## 高度な使用方法

### 条件分岐ナビゲーション

```dart
// lib/services/conditional_navigation_service.dart
import '../routes/app_route.dart';
import '../services/navigation_service.dart';

class ConditionalNavigationService {
  final NavigationService _nav;
  final PermissionService _permissionService;
  
  ConditionalNavigationService(this._nav, this._permissionService);
  
  /// ユーザーロールに応じた画面遷移
  Future<void> navigateByUserRole(UserRole role) async {
    final AppRoute route = switch (role) {
      UserRole.admin => const AdminDashboard(),
      UserRole.moderator => const ModeratorDashboard(),
      UserRole.user => const UserDashboard(),
    };
    
    final success = await _nav.go(route);
    
    if (!success) {
      await _nav.showAlert(
        title: 'エラー',
        message: 'ダッシュボードの表示に失敗しました',
      );
    }
  }
  
  /// 権限チェック付きナビゲーション
  Future<void> navigateWithPermissionCheck(
    AppRoute route,
    String requiredPermission,
  ) async {
    final hasPermission = await _permissionService.checkPermission(requiredPermission);
    
    if (hasPermission) {
      await _nav.go(route);
    } else {
      await _nav.showAlert(
        title: 'アクセス拒否',
        message: 'この画面にアクセスする権限がありません',
      );
    }
  }
}
```

### フロー管理

```dart
// lib/services/onboarding_flow_service.dart
import '../routes/app_route.dart';
import '../services/navigation_service.dart';

class OnboardingFlowService {
  final NavigationService _nav;
  
  OnboardingFlowService(this._nav);
  
  /// オンボーディングフロー実行
  Future<void> startOnboardingFlow() async {
    // Step 1: ウェルカム画面
    final shouldContinue = await _nav.push<bool>(const Welcome());
    if (shouldContinue != true) return;
    
    // Step 2: プロフィール設定
    final profile = await _nav.push<UserProfile>(const ProfileSetup());
    if (profile == null) return;
    
    // Step 3: 通知設定
    final notificationSettings = await _nav.push<NotificationSettings>(
      const NotificationSetup()
    );
    if (notificationSettings == null) return;
    
    // 完了
    await _nav.go(const Home());
    _nav.showSnackBar(message: 'セットアップが完了しました！');
  }
}
```

### カスタムトランジション

```dart
// lib/routes/app_routes.dart
@TypedGoRoute<CustomTransitionRoute>(path: '/custom')
class CustomTransitionRoute extends GoRouteData with _$CustomTransitionRoute {
  const CustomTransitionRoute();
  
  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: const CustomPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}

// 対応するAppRouteクラス
class CustomTransition extends AppRoute {
  const CustomTransition();
  
  @override
  GoRouteData get routeData => const CustomTransitionRoute();
}
```

## テスト

### NavigableRouteのモック作成

```dart
// test/mocks/mock_navigable_route.dart
import 'package:mockito/mockito.dart';
import 'package:your_app/core/navigation/navigable_route.dart';

class MockNavigableRoute extends Mock implements NavigableRoute {}
```

### NavigationServiceのモック作成

```dart
// test/mocks/mock_navigation_service.dart
import 'package:mockito/mockito.dart';
import 'package:your_app/services/navigation_service.dart';
import 'package:your_app/core/navigation/navigable_route.dart';

class MockNavigationService extends Mock implements NavigationService {
  @override
  Future<bool> go(NavigableRoute route) async {
    return super.noSuchMethod(
      Invocation.method(#go, [route]),
      returnValue: Future.value(true),
    );
  }
  
  @override
  Future<T?> push<T extends Object?>(NavigableRoute route) async {
    return super.noSuchMethod(
      Invocation.method(#push, [route]),
      returnValue: Future.value(null),
    );
  }
  
  @override
  Future<bool> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    return super.noSuchMethod(
      Invocation.method(#showAlert, [], {
        #title: title,
        #message: message,
        #buttonText: buttonText,
      }),
      returnValue: Future.value(true),
    );
  }
}
```

### コントローラーのテスト例

```dart
// test/controllers/user_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/controllers/user_controller.dart';
import 'package:your_app/routes/app_routes.dart';
import '../mocks/mock_navigation_service.dart';

void main() {
  group('UserController', () {
    late MockNavigationService mockNav;
    late MockAuthService mockAuth;
    late UserController controller;
    
    setUp(() {
      mockNav = MockNavigationService();
      mockAuth = MockAuthService();
      controller = UserController(mockNav, mockAuth);
    });
    
    test('ログイン成功時にホーム画面に遷移する', () async {
      // Arrange
      final user = User(id: '1', name: 'Test User');
      when(mockAuth.login('test@example.com', 'password'))
          .thenAnswer((_) async => user);
      when(mockNav.go(any)).thenAnswer((_) async => true);
      when(mockNav.showSnackBar(message: anyNamed('message')))
          .thenAnswer((_) async => true);
      
      // Act
      await controller.loginUser('test@example.com', 'password');
      
      // Assert
      verify(mockNav.go(argThat(isA<HomeRoute>()))).called(1);
      verify(mockNav.showSnackBar(message: 'ログインしました')).called(1);
      expect(controller.state.value, equals(user));
    });
    
    test('ログイン失敗時にエラーダイアログを表示する', () async {
      // Arrange
      when(mockAuth.login('invalid@email.com', 'wrong_password'))
          .thenThrow(Exception('Invalid credentials'));
      when(mockNav.showAlert(
        title: anyNamed('title'),
        message: anyNamed('message'),
      )).thenAnswer((_) async => true);
      
      // Act
      await controller.loginUser('invalid@email.com', 'wrong_password');
      
      // Assert
      verify(mockNav.showAlert(
        title: 'エラー',
        message: argThat(contains('ログインに失敗しました'), named: 'message'),
      )).called(1);
      expect(controller.state.hasError, isTrue);
    });
  });
}
```

### ルートクラスのテスト

```dart
// test/routes/route_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/routes/app_routes.dart';
import 'package:your_app/core/navigation/navigable_route.dart';

void main() {
  test('すべてのルートクラスがNavigableRouteを実装している', () {
    // Assert
    expect(const HomeRoute(), isA<NavigableRoute>());
    expect(const ProfileRoute(), isA<NavigableRoute>());
    expect(const DetailRoute(id: '123'), isA<NavigableRoute>());
  });
  
  test('ルートパラメータが正しく設定される', () {
    // Arrange
    const route = DetailRoute(id: '123', tab: 'info');
    
    // Assert
    expect(route.id, equals('123'));
    expect(route.tab, equals('info'));
  });
}
```

## パフォーマンス考慮事項

### ベストプラクティス

```dart
// ❌ 避けるべきパターン
class BadExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ビルド時に毎回NavigationServiceを取得するのは非効率
    final nav = ref.watch(navigationServiceProvider);
    return Container();
  }
}

// ✅ 推奨パターン
class GoodExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        // 実際に使用するタイミングでのみ取得
        final nav = ref.read(navigationServiceProvider);
        nav.go(const ProfileRoute());
      },
      child: Text('Profile'),
    );
  }
}
```

### パフォーマンス特性

- **プロバイダーアクセス**: `ref.read(goRouterProvider)`は軽量で通常のアプリ使用では問題なし
- **Context待機**: Hot Reload以外では即座にContextが取得でき、100ms待機はほとんど発生しない
- **メモリ使用量**: NavigationServiceはステートレスで軽量
- **型チェック**: NavigableRouteインターフェースによる型チェックは実行時のオーバーヘッドが最小限

## トラブルシューティング

### よくある問題と解決策

#### NavigableRouteMixinの追加忘れ

```dart
// 問題: The method 'navigate' isn't defined for the type 'NewRoute'
// 原因: NavigableRouteMixinを追加し忘れている

// ❌ 間違い
@TypedGoRoute<NewRoute>(path: '/new')
class NewRoute extends GoRouteData {
  // ...
}

// ✅ 正しい
@TypedGoRoute<NewRoute>(path: '/new')
class NewRoute extends GoRouteData with NavigableRouteMixin {
  // ...
}
```

#### Context取得失敗

```dart
// 問題: Context is null
// 原因: アプリ起動直後やHot Reload直後
// 解決: NavigationServiceが自動的に待機処理を実行

// デバッグ用のContext状態確認
void debugNavigationIssue(WidgetRef ref) {
  final router = ref.read(goRouterProvider);
  final context = router.routerDelegate.navigatorKey.currentContext;
  
  debugPrint('Router: ${router.hashCode}');
  debugPrint('NavigatorKey: ${router.routerDelegate.navigatorKey.hashCode}');
  debugPrint('Context: ${context?.hashCode ?? 'null'}');
  debugPrint('Context mounted: ${context?.mounted ?? 'N/A'}');
}
```

#### ルート生成エラー

```bash
# 問題: Route not found / 生成されたコードが見つからない
# 原因: go_router_builderの生成ファイルが古いまたは存在しない
# 解決: 以下のコマンドを実行

dart run build_runner build --delete-conflicting-outputs
```

#### 型エラー

```dart
// 問題: 型が合わない
// 原因: NavigableRoute型を期待している場所でGoRouteDataを使用
// 解決: すべてのルートクラスにNavigableRouteMixinを追加

// NavigationServiceメソッドの引数はNavigableRoute型
Future<bool> go(NavigableRoute route)  // GoRouteDataではない
```

#### Hot Reload後のナビゲーション失敗

```dart
// 問題: Hot Reload後にナビゲーションが動作しない
// 原因: 古いGoRouterインスタンスを参照している
// 解決: NavigationServiceが`ref.read(goRouterProvider)`で常に最新を取得するため、
//       通常は自動的に解決される
```

## 移行ガイド

### 既存のNavigator.pushNamedからの移行

```dart
// Before: 従来のNavigator.pushNamed
Navigator.pushNamed(context, '/profile');

// After: NavigationService
final nav = ref.read(navigationServiceProvider);
nav.go(const ProfileRoute());
```

### 既存のGoRouterからの移行

```dart
// Before: GoRouterを直接使用
context.go('/detail/123?tab=info');

// After: 型安全なNavigationService
final nav = ref.read(navigationServiceProvider);
nav.go(const DetailRoute(id: '123', tab: 'info'));
```

### 既存のshowDialogからの移行

```dart
// Before: 従来のshowDialog
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('確認'),
    content: Text('削除しますか？'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text('キャンセル'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text('削除'),
      ),
    ],
  ),
);

// After: NavigationService
final nav = ref.read(navigationServiceProvider);
final confirmed = await nav.showConfirmDialog(
  title: '確認',
  message: '削除しますか？',
  confirmText: '削除',
);
```

### 段階的移行のアプローチ

1. **Phase 1**: NavigableRouteとNavigationServiceを導入
   - core/navigationディレクトリを作成
   - NavigableRouteインターフェースとMixinを追加
   - NavigationServiceを実装

2. **Phase 2**: 既存のルートクラスを更新
   - すべてのGoRouteDataサブクラスに`with NavigableRouteMixin`を追加
   - build_runnerを実行して生成コードを更新

3. **Phase 3**: 画面遷移を段階的に置き換え
   - 新機能からNavigationServiceを使用開始
   - 既存の画面遷移を段階的にNavigationServiceに置き換え

4. **Phase 4**: 完全移行
   - すべての直接的なGoRouter使用を削除
   - Navigator.pushNamedなどの古いAPIを削除

## API リファレンス

### NavigableRoute

```dart
abstract interface class NavigableRoute {
  void navigate(BuildContext context);
  Future<T?> navigatePush<T extends Object?>(BuildContext context);
  Future<T?> navigatePushReplacement<T extends Object?>(
    BuildContext context, 
    [Object? result]
  );
  void navigateReplace(BuildContext context);
}
```

### NavigationService

#### ナビゲーションメソッド

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `go(NavigableRoute route)` | `Future<bool>` | 画面遷移（スタック置き換え） |
| `push<T>(NavigableRoute route)` | `Future<T?>` | 画面プッシュ（スタック追加） |
| `pushReplacement<T>(NavigableRoute route, {Object? result})` | `Future<T?>` | 画面置き換え |
| `replace(NavigableRoute route)` | `Future<bool>` | 画面置き換え（アニメーションなし） |
| `pop<T>([T? result])` | `bool` | 現在画面をポップ |
| `canPop()` | `bool` | ポップ可能かチェック |

#### ダイアログ・モーダルメソッド

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `showDialog<T>({required Widget dialog, bool barrierDismissible})` | `Future<T?>` | 汎用ダイアログ表示 |
| `showAlert({required String title, required String message, String buttonText})` | `Future<bool>` | アラートダイアログ表示 |
| `showConfirmDialog({required String title, required String message, String confirmText, String cancelText})` | `Future<bool?>` | 確認ダイアログ表示 |
| `showBottomSheet<T>({required Widget content, bool isScrollControlled})` | `Future<T?>` | ボトムシート表示 |
| `showSnackBar({required String message, Duration? duration, SnackBarAction? action})` | `Future<bool>` | スナックバー表示 |

#### 戻り値の意味

- **bool型**: `true`=成功, `false`=失敗（Context無効・エラー）
- **nullable型**: 実際の戻り値=成功, `null`=失敗・キャンセル・Context無効
- **bool?型（確認ダイアログ）**: `true`=確認, `false`=キャンセル, `null`=失敗・Context無効

### ルートクラスの実装要件

すべてのルートクラスは以下の要件を満たす必要があります：

1. `GoRouteData`を継承
2. `NavigableRouteMixin`を使用
3. `@TypedGoRoute`アノテーションを付与
4. `build`または`buildPage`メソッドを実装

```dart
@TypedGoRoute<ExampleRoute>(path: '/example/:id')
class ExampleRoute extends GoRouteData with NavigableRouteMixin {
  final String id;
  
  const ExampleRoute({required this.id});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(id: id);
  }
}
```

---

このナビゲーションシステムを使用することで、Flutterアプリケーションの画面遷移を型安全で保守しやすい形で統一管理できます。NavigableRouteインターフェースとNavigableRouteMixinの組み合わせにより、go_router_builderの型安全性を活かしながら、分岐処理なしで統一的なナビゲーションAPIを提供します。