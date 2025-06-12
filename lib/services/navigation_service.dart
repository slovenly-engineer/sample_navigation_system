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
  
  void pushAndRemoveUntil(AppRoute route, bool Function(GoRoute) predicate) {
    _router.pushReplacement(route.buildPath(), extra: route.extra);
  }
  
  Future<T?> showDialogWidget<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = false,
    RouteSettings? routeSettings,
    Offset? anchorPoint,
    TraversalEdgeBehavior? traversalEdgeBehavior,
  }) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('No context available for showDialog');
    }
    
    return showDialog<T>(
      context: context,
      builder: (_) => child,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      anchorPoint: anchorPoint,
      traversalEdgeBehavior: traversalEdgeBehavior,
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
    bool barrierDismissible = true,
  }) {
    return showDialogWidget<bool>(
      barrierDismissible: barrierDismissible,
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
  
  Future<T?> showBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    BoxConstraints? constraints,
    Color? barrierColor,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = false,
    bool useSafeArea = false,
    RouteSettings? routeSettings,
    AnimationController? transitionAnimationController,
    Offset? anchorPoint,
  }) {
    final context = _router.routerDelegate.navigatorKey.currentContext;
    if (context == null) {
      throw Exception('No context available for showBottomSheet');
    }
    
    return showModalBottomSheet<T>(
      context: context,
      builder: builder,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showDragHandle: showDragHandle,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      transitionAnimationController: transitionAnimationController,
      anchorPoint: anchorPoint,
    );
  }
}