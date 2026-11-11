import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Importaciones de vistas (se irán creando en cada sprint)
import '../../presentation/views/splash/splash_screen.dart';
import '../../presentation/views/auth/login_screen.dart';
import '../../presentation/views/auth/register_screen.dart';
import '../../presentation/views/auth/forgot_password_screen.dart';
import '../../presentation/views/home/home_screen.dart';
import '../../presentation/views/profile/edit_profile_screen.dart';

// ── Nombres de rutas (constantes) ─────────────────────────
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String categoryDetail = '/menu/:categoriaId';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String admin = '/admin';
  static const String adminMenu = '/admin/menu';
  static const String adminMenuProduct = '/admin/menu/product';
  static const String adminOrders = '/admin/orders';
}

// ── Provider del router ───────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
        // Sub-rutas del Home (bottom nav tabs)
        routes: [
          GoRoute(
            path: 'menu',
            builder: (context, state) => const Placeholder(), // MenuScreen
          ),
          GoRoute(
            path: 'cart',
            builder: (context, state) => const Placeholder(), // CartScreen
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const Placeholder(), // OrdersScreen
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const Placeholder(), // ProfileScreen
          ),
        ],
      ),
    ],
    // Ruta de error 404
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Ruta no encontrada: ${state.error}'),
      ),
    ),
  );
});
