import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/router_provider.dart';
import '../routes/app_route.dart';

class NavigationService {
  final Ref ref;

  NavigationService(this.ref);

  GoRouter get _router => ref.read(goRouterProvider);
  BuildContext? get _context =>
      _router.routerDelegate.navigatorKey.currentContext;

  /// 画面遷移（go）
  Future<bool> go(AppRoute route) async {
    final context = _context;
    if (context == null || !context.mounted) return false;

    try {
      switch (route) {
        case Home():
          route.routeData.go(context);
        case Profile():
          (route.routeData).go(context);
        case Settings():
          (route.routeData).go(context);
        case User():
          (route.routeData).go(context);
        case UserProfile():
          (route.routeData).go(context);
        case UserPosts():
          (route.routeData).go(context);
        case PostDetail():
          (route.routeData).go(context);
        case Product():
          (route.routeData).go(context);
        case Checkout():
          (route.routeData).go(context);
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
          (route.routeData).pushReplacement(context);
        case Profile():
          (route.routeData).pushReplacement(context);
        case Settings():
          (route.routeData).pushReplacement(context);
        case User():
          (route.routeData).pushReplacement(context);
        case UserProfile():
          (route.routeData).pushReplacement(context);
        case UserPosts():
          (route.routeData).pushReplacement(context);
        case PostDetail():
          (route.routeData).pushReplacement(context);
        case Product():
          (route.routeData).pushReplacement(context);
        case Checkout():
          (route.routeData).pushReplacement(context);
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

  Future<T?> showBottomSheet<T>({
    required Widget sheet,
    bool isDismissible = true,
    bool enableDrag = true,
  }) async {
    final context = _context;
    if (context == null || !context.mounted) return null;
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (_) => sheet,
    );
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});
