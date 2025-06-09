# Flutter GoRouter + Riverpod ナビゲーションシステム

## 目次

- [概要](#概要)
- [機能](#機能)
- [前提条件](#前提条件)
- [インストール](#インストール)
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

このドキュメントでは、GoRouterとRiverpodを使用したFlutterアプリケーション向けの型安全で保守しやすいナビゲーションシステムの実装方法を説明します。このシステムは、自動的なBuildContext検証とHot Reload対応を備えた一元的なナビゲーション管理を提供します。

## 機能

- ✅ **型安全性**: go_router_builderによる完全な型安全なナビゲーション
- ✅ **シンプルさ**: GoRouteDataを直接使用する直感的なAPI
- ✅ **安全性**: 自動的なBuildContext検証とHot Reload対応
- ✅ **一元管理**: すべてのナビゲーションとダイアログ操作の統一インターフェース
- ✅ **保守性**: Riverpodによる依存性管理と簡単なテスト

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

## クイックスタート

### 1. ルート定義

```dart
// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:go_router_builder/go_router_builder.dart';
import 'package:flutter/material.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

@TypedGoRoute<ProfileRoute>(path: '/profile')
class ProfileRoute extends GoRouteData {
  const ProfileRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}
```

### 2. プロバイダーの設定

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

### 3. NavigationServiceの追加

```dart
// lib/services/navigation_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  final Ref ref;
  
  NavigationService(this.ref);
  
  // 基本的な使用例のため簡略化
  GoRouter get _router => ref.read(goRouterProvider);
  
  Future<bool> go<T extends GoRouteData>(T routeData) async {
    // 実装は後述の完全版を参照
    return true;
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
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

class NavigationService {
  final Ref ref;
  
  NavigationService(this.ref);
  
  /// 最新のGoRouterインスタンスを取得（Hot Reload対応）
  GoRouter get _router => ref.read(goRouterProvider);
  
  /// 現在のBuildContextを取得
  BuildContext? get _context => _router.routerDelegate.navigatorKey.currentContext;
  
  /// Context待機処理（Hot Reload対応）
  Future<BuildContext?> _waitForContext() async {
    var context = _context;
    if (_isValid(context)) return context;
    
    // Hot Reload直後はContextがnullになるため短時間待機
    await Future.delayed(const Duration(milliseconds: 100));
    
    context = _context;
    return _isValid(context) ? context : null;
  }
  
  /// Contextの有効性チェック
  bool _isValid(BuildContext? context) => context != null && context.mounted;
  
  /// 安全な非同期実行ラッパー
  Future<T> _run<T>(Future<T> Function(BuildContext) action, T fallback) async {
    final context = await _waitForContext();
    if (!_isValid(context)) return fallback;
    
    try {
      return await action(context!);
    } catch (e) {
      debugPrint('Navigation error: $e');
      return fallback;
    }
  }
  
  // === ナビゲーションメソッド ===
  
  /// 画面遷移（スタック置き換え）
  /// 戻り値: true=成功, false=失敗
  Future<bool> go<T extends GoRouteData>(T routeData) => 
    _run((ctx) async { routeData.go(ctx); return true; }, false);
  
  /// 画面プッシュ（スタック追加）
  /// 戻り値: 画面からの戻り値, null=失敗・キャンセル
  Future<T?> push<T extends Object?, R extends GoRouteData>(R routeData) => 
    _run((ctx) => routeData.push<T>(ctx), null);
  
  /// 画面置き換え
  /// 戻り値: 画面からの戻り値, null=失敗
  Future<T?> pushReplacement<T extends Object?, R extends GoRouteData>(
    R routeData, {Object? result}
  ) => _run((ctx) => routeData.pushReplacement<T>(ctx, result), null);
  
  /// 現在画面をポップ
  /// 戻り値: true=成功, false=失敗・ポップ不可
  bool pop<T extends Object?>([T? result]) {
    final context = _context;
    if (!_isValid(context) || !_router.canPop()) return false;
    
    try {
      _router.pop(result);
      return true;
    } catch (e) {
      debugPrint('Pop error: $e');
      return false;
    }
  }
  
  /// ポップ可能かチェック
  bool canPop() => _router.canPop();
  
  // === ダイアログ・モーダル系メソッド ===
  
  /// 汎用ダイアログ表示
  /// 戻り値: ダイアログからの戻り値, null=失敗・キャンセル
  Future<T?> showDialog<T>({required Widget dialog, bool barrierDismissible = true}) => 
    _run((ctx) => showDialog<T>(
      context: ctx, 
      barrierDismissible: barrierDismissible, 
      builder: (_) => dialog
    ), null);
  
  /// アラートダイアログ表示
  /// 戻り値: true=OK押下, false=失敗
  Future<bool> showAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    final result = await showDialog<bool>(
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
  
  /// 確認ダイアログ表示
  /// 戻り値: true=確認, false=キャンセル, null=失敗
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = '確認',
    String cancelText = 'キャンセル',
  }) async {
    return await showDialog<bool>(
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
  
  /// ボトムシート表示
  /// 戻り値: シートからの戻り値, null=失敗・キャンセル
  Future<T?> showBottomSheet<T>({
    required Widget content,
    bool isScrollControlled = false,
  }) => _run((ctx) => showModalBottomSheet<T>(
      context: ctx,
      isScrollControlled: isScrollControlled,
      builder: (_) => content,
    ), null);
  
  /// スナックバー表示
  /// 戻り値: true=表示成功, false=失敗
  Future<bool> showSnackBar({
    required String message, 
    Duration? duration, 
    SnackBarAction? action
  }) => _run((ctx) async {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message), 
          duration: duration ?? Duration(seconds: 3), 
          action: action
        )
      );
      return true;
    }, false);
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});
```

### ルート定義の詳細例

```dart
// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import 'package:go_router_builder/go_router_builder.dart';
import 'package:flutter/material.dart';

part 'app_routes.g.dart';

// ホーム画面
@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

// パラメータ付き詳細画面
@TypedGoRoute<DetailRoute>(path: '/detail/:id')
class DetailRoute extends GoRouteData {
  final String id;
  final String? tab; // クエリパラメータ
  
  const DetailRoute({required this.id, this.tab});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return DetailPage(id: id, initialTab: tab);
  }
}

// extraデータ付き設定画面
@TypedGoRoute<SettingsRoute>(path: '/settings')
class SettingsRoute extends GoRouteData {
  final SettingsData? $extra;
  
  const SettingsRoute({this.$extra});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return SettingsPage(initialData: $extra);
  }
}

// ネストしたルート例
@TypedGoRoute<UserRoute>(
  path: '/user/:userId',
  routes: [
    TypedGoRoute<UserProfileRoute>(path: '/profile'),
    TypedGoRoute<UserSettingsRoute>(path: '/settings'),
  ],
)
class UserRoute extends GoRouteData {
  final String userId;
  
  const UserRoute({required this.userId});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserPage(userId: userId);
  }
}

class UserProfileRoute extends GoRouteData {
  final String userId;
  
  const UserProfileRoute({required this.userId});
  
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return UserProfilePage(userId: userId);
  }
}
```

## 使用例

### Widget内での基本的な使用方法

```dart
// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 基本的なナビゲーション
            ElevatedButton(
              onPressed: () => nav.go(const ProfileRoute()),
              child: const Text('プロフィールへ'),
            ),
            
            // パラメータ付きナビゲーション
            ElevatedButton(
              onPressed: () => nav.go(const DetailRoute(id: '123', tab: 'info')),
              child: const Text('詳細画面へ'),
            ),
            
            // プッシュナビゲーション
            ElevatedButton(
              onPressed: () => nav.push(const ProfileRoute()),
              child: const Text('プロフィールをプッシュ'),
            ),
            
            // 確認ダイアログ
            ElevatedButton(
              onPressed: () async {
                final confirmed = await nav.showConfirmDialog(
                  title: '確認',
                  message: '実行しますか？',
                );
                
                if (confirmed == true) {
                  nav.showSnackBar(message: '実行しました');
                }
              },
              child: const Text('確認ダイアログ'),
            ),
          ],
        ),
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
import '../routes/app_routes.dart';

class UserController extends StateNotifier<AsyncValue<User?>> {
  final NavigationService _nav;
  
  UserController(this._nav) : super(const AsyncValue.loading());
  
  /// ユーザーログイン
  Future<void> loginUser(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
      
      // ログイン成功時の画面遷移
      final success = await _nav.go(const HomeRoute());
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
    final result = await _nav.push<ProfileEditResult>(const ProfileEditRoute());
    
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
      await _nav.go(const LoginRoute());
    }
  }
}

final userControllerProvider = StateNotifierProvider<UserController, AsyncValue<User?>>((ref) {
  final nav = ref.read(navigationServiceProvider);
  return UserController(nav);
});
```

## 高度な使用方法

### 条件分岐ナビゲーション

```dart
// lib/services/conditional_navigation_service.dart
class ConditionalNavigationService {
  final NavigationService _nav;
  
  ConditionalNavigationService(this._nav);
  
  /// ユーザーロールに応じた画面遷移
  Future<void> navigateByUserRole(UserRole role) async {
    final route = switch (role) {
      UserRole.admin => const AdminDashboardRoute(),
      UserRole.moderator => const ModeratorDashboardRoute(),
      UserRole.user => const UserDashboardRoute(),
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
    GoRouteData route,
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
class OnboardingFlowService {
  final NavigationService _nav;
  
  OnboardingFlowService(this._nav);
  
  /// オンボーディングフロー実行
  Future<void> startOnboardingFlow() async {
    // Step 1: ウェルカム画面
    final shouldContinue = await _nav.push<bool>(const WelcomeRoute());
    if (shouldContinue != true) return;
    
    // Step 2: プロフィール設定
    final profile = await _nav.push<UserProfile>(const ProfileSetupRoute());
    if (profile == null) return;
    
    // Step 3: 通知設定
    final notificationSettings = await _nav.push<NotificationSettings>(
      const NotificationSetupRoute()
    );
    if (notificationSettings == null) return;
    
    // 完了
    await _nav.go(const HomeRoute());
    _nav.showSnackBar(message: 'セットアップが完了しました！');
  }
}
```

## テスト

### NavigationServiceのモック作成

```dart
// test/mocks/mock_navigation_service.dart
import 'package:mockito/mockito.dart';
import 'package:your_app/services/navigation_service.dart';

class MockNavigationService extends Mock implements NavigationService {
  @override
  Future<bool> go<T extends GoRouteData>(T routeData) async {
    return super.noSuchMethod(
      Invocation.method(#go, [routeData]),
      returnValue: Future.value(true),
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
    late UserController controller;
    
    setUp(() {
      mockNav = MockNavigationService();
      controller = UserController(mockNav);
    });
    
    test('ログイン成功時にホーム画面に遷移する', () async {
      // Arrange
      when(mockNav.go(const HomeRoute())).thenAnswer((_) async => true);
      when(mockNav.showSnackBar(message: anyNamed('message')))
          .thenAnswer((_) async => true);
      
      // Act
      await controller.loginUser('test@example.com', 'password');
      
      // Assert
      verify(mockNav.go(const HomeRoute())).called(1);
      verify(mockNav.showSnackBar(message: 'ログインしました')).called(1);
    });
    
    test('ログイン失敗時にエラーダイアログを表示する', () async {
      // Arrange
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
    });
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

## トラブルシューティング

### よくある問題と解決策

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

#### ルート未定義エラー

```bash
# 問題: Route not found
# 原因: go_router_builderの生成ファイルが古い
# 解決: 以下のコマンドを実行

dart run build_runner build --delete-conflicting-outputs
```

#### 型エラー

```dart
// 問題: 型が合わない
// 原因: GoRouteDataのパラメータ型不一致
// 解決: ルート定義でパラメータ型を確認

@TypedGoRoute<DetailRoute>(path: '/detail/:id')
class DetailRoute extends GoRouteData {
  final String id; // String型であることを確認
  
  const DetailRoute({required this.id});
}
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

1. **Phase 1**: NavigationServiceを導入し、新機能から使用開始
2. **Phase 2**: 既存の画面遷移を段階的にNavigationServiceに置き換え
3. **Phase 3**: すべての Navigator.pushNamed を削除
4. **Phase 4**: go_router_builderによる型安全なルート定義に移行

## API リファレンス

### NavigationService

#### ナビゲーションメソッド

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `go<T>(T routeData)` | `Future<bool>` | 画面遷移（スタック置き換え） |
| `push<T, R>(R routeData)` | `Future<T?>` | 画面プッシュ（スタック追加） |
| `pushReplacement<T, R>(R routeData, {Object? result})` | `Future<T?>` | 画面置き換え |
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

### GoRouteData 拡張

すべてのルートクラスは `GoRouteData` を継承し、以下のメソッドが使用可能：

- `go(BuildContext context)`: 画面遷移
- `push<T>(BuildContext context)`: 画面プッシュ
- `pushReplacement<T>(BuildContext context, [Object? result])`: 画面置き換え

---

このナビゲーションシステムを使用することで、Flutterアプリケーションの画面遷移を型安全で保守しやすい形で統一管理できます。プロジェクトの規模に応じて段階的に導入し、開発効率と品質の向上を実現してください。