import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/product/product_detail_page.dart';
import '../../presentation/pages/cart/cart_page.dart';
import '../../presentation/pages/cart/cart_api_page.dart';
import '../../presentation/pages/wishlist/wishlist_page.dart';
import '../../presentation/pages/profile/profile_page.dart';
import '../../presentation/pages/orders/orders_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/search/search_results_page.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String cartApi = '/cart-api';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String orders = '/orders';
  static const String settings = '/settings';
  static const String searchResults = '/search/:query';

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final isAuthRoute = state.uri.path == login || state.uri.path == register;
        final isSplashRoute = state.uri.path == splash;
        final isPublicRoute = state.uri.path == home || state.uri.path == productDetail ||
                             state.uri.path == cart || state.uri.path == wishlist ||
                             state.uri.path == orders || state.uri.path == settings ||
                             state.uri.path.startsWith('/search/');

        // Allow splash screen to handle its own navigation
        if (isSplashRoute) {
          return null;
        }

        // If not logged in and trying to access protected routes
        if (!isLoggedIn && !isAuthRoute && !isPublicRoute) {
          return login;
        }

        // If logged in and trying to access auth routes, redirect to home
        if (isLoggedIn && isAuthRoute) {
          return home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: productDetail,
          name: 'product-detail',
          builder: (context, state) {
            final productId = int.parse(state.pathParameters['id']!);
            return ProductDetailPage(productId: productId);
          },
        ),
        GoRoute(
          path: cart,
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: cartApi,
          name: 'cart-api',
          builder: (context, state) => const CartApiPage(),
        ),
        GoRoute(
          path: wishlist,
          name: 'wishlist',
          builder: (context, state) => const WishlistPage(),
        ),
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: orders,
          name: 'orders',
          builder: (context, state) => const OrdersPage(),
        ),
        GoRoute(
          path: settings,
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: searchResults,
          name: 'search-results',
          builder: (context, state) {
            final query = state.pathParameters['query']!;
            return SearchResultsPage(query: query);
          },
        ),
        // Fallback route for any unmatched paths
        GoRoute(
          path: '/:path(.*)',
          name: 'fallback',
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
  }
}
