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
- [トラブルシューティング](#トラブルシューティング)
- [移行ガイド](#移行ガイド)
- [API リファレンス](#api-リファレンス)

## 概要

このドキュメントでは、GoRouterとRiverpodを使用したFlutterアプリケーション向けのシンプルで保守しやすいナビゲーションシステムの実装方法を説明します。型安全性を維持しながら、go_router_builderへの依存を排除し、コード生成なしで動作する軽量な実装を実現しています。

### 主な特徴

本実装では、`AppRoute`という基底クラスを使用してすべてのルートを定義し、各ルートクラスがパスとパラメータを自己管理することで、シンプルで拡張性の高いナビゲーションシステムを構築します。

## 機能

- ✅ **シンプルな実装**: switch文やコード生成が不要
- ✅ **型安全性**: コンパイル時のパラメータチェック
- ✅ **統一API**: NavigationServiceによる一貫したナビゲーションインターフェース
- ✅ **軽量**: go_router_builderへの依存なし、ビルド時間の短縮
- ✅ **保守性**: 新しいルート追加が簡単で、変更箇所が最小限
- ✅ **柔軟性**: カスタムルートロジックの実装が容易
- ✅ **ダイアログ・モーダル対応**: 統一的なUI操作インターフェース

## 前提条件

- Flutter SDK 3.16+
- Dart 3.2+
- GoRouterとRiverpodの基本的な知識

## インストール

### 1. 依存関係の追加

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  flutter_riverpod: ^2.4.0
```

### 2. パッケージのインストール

```bash
flutter pub get
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
│  NavigationService ─────uses────> AppRoute (Abstract)   │
│         │                              │                 │
│         │                              │ extends         │
│         │                              ▼                 │
│         │                    HomeRoute, UserRoute...     │
│         │                              │                 │
│         │                              │ buildPath()     │
│         │                              ▼                 │
│         └──────uses──────> GoRouter                     │
└─────────────────────────────────────────────────────────┘
```

## クイックスタート

### 1. ルート定義

```dart
// lib/routes/app_routes.dart
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

// 各ルートの実装
class HomeRoute extends AppRoute {
  @override
  String get path => '/';
}

class UserRoute extends AppRoute {
  final String userId;
  
  UserRoute({required this.userId});
  
  @override
  String get path => '/user/:userId';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

class ProductRoute extends AppRoute {
  final String productId;
  
  ProductRoute({required this.productId});
  
  @override
  String get path => '/product/:productId';
  
  @override
  Map<String, String> get pathParameters => {'productId': productId};
}

// 複雑なデータを渡すルート
class CheckoutRoute extends AppRoute {
  final List<CartItem> items;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;
  
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
```

### 2. NavigationServiceの実装

```dart
// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';

class NavigationService {
  final GoRouter _router;
  
  NavigationService(this._router);
  
  void go(AppRoute route) {
    _router.go(route.buildPath(), extra: route.extra);
  }
  
  Future<T?> push<T>(AppRoute route) {
    return _router.push<T>(route.buildPath(), extra: route.extra);
  }
  
  void pushReplacement(AppRoute route) {
    _router.pushReplacement(route.buildPath(), extra: route.extra);
  }
  
  bool canPop() {
    return _router.canPop();
  }
  
  void pop<T>([T? result]) {
    if (canPop()) {
      _router.pop(result);
    }
  }
  
  // ダイアログ・モーダル系メソッド
  Future<T?> showDialogWidget<T>({
    required Widget child,
    bool barrierDismissible = true,
  }) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('No context available for showDialog');
    }
    
    return showDialog<T>(
      context: context,
      builder: (_) => child,
      barrierDismissible: barrierDismissible,
    );
  }
  
  Future<void> showAlert({
    required String title,
    String? message,
    String okButtonText = 'OK',
  }) {
    return showDialogWidget(
      child: AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => pop(),
            child: Text(okButtonText),
          ),
        ],
      ),
    );
  }
  
  Future<bool?> showConfirmDialog({
    required String title,
    String? message,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
  }) {
    return showDialogWidget<bool>(
      child: AlertDialog(
        title: Text(title),
        content: message != null ? Text(message) : null,
        actions: [
          TextButton(
            onPressed: () => pop(false),
            child: Text(cancelButtonText),
          ),
          TextButton(
            onPressed: () => pop(true),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }
  
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('No context available for showSnackBar');
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }
}
```

### 3. GoRouter設定

```dart
// lib/providers/router_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';
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
```

### 4. メインアプリの設定

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
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Navigation App',
      routerConfig: router,
    );
  }
}
```

## コアコンポーネント

### AppRoute基底クラス

```dart
abstract class AppRoute {
  // ルートのパス定義（例: '/user/:userId'）
  String get path;
  
  // パスパラメータ（例: {'userId': '123'}）
  Map<String, String> get pathParameters => {};
  
  // クエリパラメータ（例: {'tab': 'info'}）
  Map<String, String> get queryParameters => {};
  
  // 追加データ（複雑なオブジェクトを渡す場合）
  Object? get extra => null;
  
  // 実際のパスを生成
  String buildPath() {
    var path = this.path;
    
    // パスパラメータを置換
    pathParameters.forEach((key, value) {
      path = path.replaceAll(':$key', value);
    });
    
    // クエリパラメータを追加
    if (queryParameters.isNotEmpty) {
      final queryString = queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      path = '$path?$queryString';
    }
    
    return path;
  }
}
```

### ルートの種類別実装例

```dart
// シンプルなルート
class HomeRoute extends AppRoute {
  @override
  String get path => '/';
}

// 単一パラメータのルート
class UserRoute extends AppRoute {
  final String userId;
  
  UserRoute({required this.userId});
  
  @override
  String get path => '/user/:userId';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

// クエリパラメータ付きルート
class SettingsRoute extends AppRoute {
  final int? initialTab;
  
  SettingsRoute({this.initialTab});
  
  @override
  String get path => '/settings';
  
  @override
  Map<String, String> get queryParameters => 
    initialTab != null ? {'tab': initialTab.toString()} : {};
}

// ネストされたルート
class UserProfileRoute extends AppRoute {
  final String userId;
  
  UserProfileRoute({required this.userId});
  
  @override
  String get path => '/user/:userId/profile';
  
  @override
  Map<String, String> get pathParameters => {'userId': userId};
}

// 複数パラメータのルート
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

// 複雑なオブジェクトを渡すルート
class CheckoutRoute extends AppRoute {
  final List<CartItem> items;
  final ShippingAddress address;
  final PaymentMethod paymentMethod;
  
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
```

## 使用例

### Widget内での基本的な使用方法

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_routes.dart';

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
            onPressed: () => nav.go(HomeRoute()),
            child: const Text('ホーム'),
          ),
          
          // パラメータ付きナビゲーション
          ElevatedButton(
            onPressed: () => nav.go(UserRoute(userId: '123')),
            child: const Text('ユーザー詳細'),
          ),
          
          // クエリパラメータ付き
          ElevatedButton(
            onPressed: () => nav.go(SettingsRoute(initialTab: 2)),
            child: const Text('設定（通知タブ）'),
          ),
          
          // 複数パラメータ
          ElevatedButton(
            onPressed: () => nav.go(
              PostDetailRoute(userId: '123', postId: '456'),
            ),
            child: const Text('投稿詳細'),
          ),
          
          // プッシュで結果を受け取る
          ElevatedButton(
            onPressed: () async {
              final result = await nav.push<String>(
                ProductRoute(productId: '789'),
              );
              if (result != null) {
                nav.showSnackBar('選択された商品: $result');
              }
            },
            child: const Text('商品選択'),
          ),
          
          // 確認ダイアログ
          ElevatedButton(
            onPressed: () async {
              final confirmed = await nav.showConfirmDialog(
                title: '確認',
                message: '本当に削除しますか？',
                confirmButtonText: '削除',
              );
              
              if (confirmed == true) {
                // 削除処理
                nav.showSnackBar('削除しました');
              }
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
```

### ビジネスロジック内での使用

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_routes.dart';

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final NavigationService _nav;
  
  AuthController(this._nav) : super(const AsyncValue.data(null));
  
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await authService.login(email, password);
      state = AsyncValue.data(user);
      
      // ログイン成功時の画面遷移
      _nav.go(HomeRoute());
      _nav.showSnackBar('ログインしました');
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      
      await _nav.showAlert(
        title: 'エラー',
        message: 'ログインに失敗しました: $error',
      );
    }
  }
  
  Future<void> logout() async {
    final confirmed = await _nav.showConfirmDialog(
      title: '確認',
      message: 'ログアウトしますか？',
    );
    
    if (confirmed == true) {
      await authService.logout();
      state = const AsyncValue.data(null);
      _nav.go(LoginRoute());
    }
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final nav = ref.read(navigationServiceProvider);
  return AuthController(nav);
});
```

## 高度な使用方法

### 条件分岐ナビゲーション

```dart
class ConditionalNavigationService {
  final NavigationService _nav;
  final AuthService _authService;
  
  ConditionalNavigationService(this._nav, this._authService);
  
  Future<void> navigateToProfile() async {
    final user = await _authService.getCurrentUser();
    
    if (user == null) {
      // 未ログインの場合
      final result = await _nav.push<bool>(LoginRoute());
      if (result == true) {
        // ログイン成功後にプロフィールへ
        _nav.go(ProfileRoute());
      }
    } else {
      // ログイン済みの場合
      _nav.go(ProfileRoute());
    }
  }
  
  Future<void> navigateByRole(UserRole role) async {
    final route = switch (role) {
      UserRole.admin => AdminDashboardRoute(),
      UserRole.user => UserDashboardRoute(),
      UserRole.guest => HomeRoute(),
    };
    
    _nav.go(route);
  }
}
```

### フロー管理

```dart
class OnboardingFlow {
  final NavigationService _nav;
  
  OnboardingFlow(this._nav);
  
  Future<void> start() async {
    // Step 1: ウェルカム画面
    final shouldContinue = await _nav.push<bool>(WelcomeRoute());
    if (shouldContinue != true) return;
    
    // Step 2: プロフィール設定
    final profile = await _nav.push<UserProfile>(ProfileSetupRoute());
    if (profile == null) return;
    
    // Step 3: 通知設定
    final notifications = await _nav.push<bool>(NotificationSetupRoute());
    
    // 完了
    _nav.go(HomeRoute());
    _nav.showSnackBar('セットアップが完了しました！');
  }
}
```

### カスタムトランジション

GoRouterの設定でカスタムトランジションを定義：

```dart
GoRoute(
  path: '/fade',
  pageBuilder: (context, state) {
    return CustomTransitionPage(
      child: const FadePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  },
),
```

## テスト

### NavigationServiceのモック

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([NavigationService])
void main() {
  late MockNavigationService mockNav;
  
  setUp(() {
    mockNav = MockNavigationService();
  });
  
  test('ログイン成功時にホーム画面へ遷移', () async {
    // Arrange
    when(mockNav.go(any)).thenReturn(null);
    when(mockNav.showSnackBar(any)).thenReturn(null);
    
    final controller = AuthController(mockNav);
    
    // Act
    await controller.login('test@example.com', 'password');
    
    // Assert
    verify(mockNav.go(argThat(isA<HomeRoute>()))).called(1);
    verify(mockNav.showSnackBar('ログインしました')).called(1);
  });
}
```

### ルートのテスト

```dart
test('UserRouteが正しいパスを生成する', () {
  final route = UserRoute(userId: '123');
  expect(route.buildPath(), equals('/user/123'));
});

test('SettingsRouteがクエリパラメータを含む', () {
  final route = SettingsRoute(initialTab: 2);
  expect(route.buildPath(), equals('/settings?tab=2'));
});

test('PostDetailRouteが複数パラメータを処理する', () {
  final route = PostDetailRoute(userId: '123', postId: '456');
  expect(route.buildPath(), equals('/user/123/posts/456'));
});
```

## トラブルシューティング

### よくある問題

#### 1. Context取得エラー

```dart
// 問題: No context available for showDialog
// 原因: navigatorKeyが設定されていない
// 解決: GoRouterにnavigatorKeyを必ず設定する

final router = GoRouter(
  navigatorKey: navigatorKey, // 必須
  // ...
);
```

#### 2. パラメータのエンコーディング

```dart
// 問題: 特殊文字を含むパラメータが正しく処理されない
// 解決: buildPath()内でUri.encodeComponentを使用している

// 自動的にエンコードされる
final route = SearchRoute(query: 'Flutter & Dart');
// 結果: /search?query=Flutter%20%26%20Dart
```

#### 3. ルートが見つからない

```dart
// 問題: Could not find a generator for route
// 原因: GoRouterの設定にルートが定義されていない
// 解決: router_provider.dartにルート定義を追加

GoRoute(
  path: '/newroute',
  builder: (context, state) => const NewPage(),
),
```

## 移行ガイド

### go_router_builderからの移行

1. **ルートクラスの変更**
   ```dart
   // Before: go_router_builder
   @TypedGoRoute<UserRoute>(path: '/user/:userId')
   class UserRoute extends GoRouteData {
     final String userId;
     const UserRoute({required this.userId});
   }
   
   // After: 新実装
   class UserRoute extends AppRoute {
     final String userId;
     UserRoute({required this.userId});
     
     @override
     String get path => '/user/:userId';
     
     @override
     Map<String, String> get pathParameters => {'userId': userId};
   }
   ```

2. **NavigationServiceの使用**
   ```dart
   // Before
   const UserRoute(userId: '123').go(context);
   
   // After
   nav.go(UserRoute(userId: '123'));
   ```

3. **ビルドランナーの削除**
   - `build_runner`の依存を削除
   - 生成ファイル（*.g.dart）を削除

### 段階的移行

1. 新しいルートから`AppRoute`を使用開始
2. 既存ルートを徐々に移行
3. すべての移行完了後、go_router_builderを削除

## API リファレンス

### AppRoute

| プロパティ | 型 | 説明 |
|-----------|-----|------|
| `path` | `String` | ルートのパス定義 |
| `pathParameters` | `Map<String, String>` | パスパラメータ |
| `queryParameters` | `Map<String, String>` | クエリパラメータ |
| `extra` | `Object?` | 追加データ |
| `buildPath()` | `String` | 実際のパスを生成 |

### NavigationService

#### ナビゲーションメソッド

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `go(AppRoute route)` | `void` | 画面遷移（スタック置き換え） |
| `push<T>(AppRoute route)` | `Future<T?>` | 画面プッシュ（スタック追加） |
| `pushReplacement(AppRoute route)` | `void` | 現在の画面を置き換え |
| `pop<T>([T? result])` | `void` | 前の画面に戻る |
| `canPop()` | `bool` | 戻れるかチェック |

#### ダイアログ・UI メソッド

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `showDialogWidget<T>({required Widget child})` | `Future<T?>` | カスタムダイアログ表示 |
| `showAlert({required String title})` | `Future<void>` | アラートダイアログ表示 |
| `showConfirmDialog({required String title})` | `Future<bool?>` | 確認ダイアログ表示 |
| `showSnackBar(String message)` | `void` | スナックバー表示 |
| `showBottomSheet<T>({required WidgetBuilder builder})` | `Future<T?>` | ボトムシート表示 |

---

このナビゲーションシステムは、go_router_builderの複雑さを排除し、シンプルで保守しやすい実装を提供します。型安全性を維持しながら、新しいルートの追加や既存ルートの変更が容易になり、開発効率が向上します。