import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_routes.dart';
import '../services/navigation_service.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialLocation: '/',
    routes: $appRoutes,
  );
});

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref);
});