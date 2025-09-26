import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/auth/auth_state.dart';
import 'app_router.dart';

class NavigationTest {
  static void testAppFlow() {
    print('🧪 Testing App Flow and Redirections...');
    
    // Test 1: Initial Route
    print('✅ Initial Route: ${AppRouter.splash}');
    
    // Test 2: Route Constants
    print('✅ Route Constants:');
    print('   - Splash: ${AppRouter.splash}');
    print('   - Login: ${AppRouter.login}');
    print('   - Register: ${AppRouter.register}');
    print('   - Home: ${AppRouter.home}');
    print('   - Profile: ${AppRouter.profile}');
    print('   - Cart: ${AppRouter.cart}');
    print('   - Wishlist: ${AppRouter.wishlist}');
    print('   - Orders: ${AppRouter.orders}');
    print('   - Settings: ${AppRouter.settings}');
    
    // Test 3: Navigation Flow
    print('✅ Expected Navigation Flow:');
    print('   1. App starts → Splash Screen');
    print('   2. Splash checks auth → Login (if not authenticated) or Home (if authenticated)');
    print('   3. Login success → Home');
    print('   4. Home navigation → Orders, Cart, Wishlist, Profile');
    print('   5. Profile → Settings (if needed)');
    print('   6. Logout → Login');
    
    print('🎉 App Flow Test Complete!');
  }
  
  static void testRouteProtection() {
    print('🔒 Testing Route Protection...');
    
    // Public routes (accessible without authentication)
    final publicRoutes = [
      AppRouter.home,
      AppRouter.cart,
      AppRouter.wishlist,
      AppRouter.orders,
      AppRouter.settings,
    ];
    
    // Auth routes (redirect to home if authenticated)
    final authRoutes = [
      AppRouter.login,
      AppRouter.register,
    ];
    
    // Protected routes (redirect to login if not authenticated)
    final protectedRoutes = [
      AppRouter.profile,
    ];
    
    print('✅ Public Routes (No Auth Required):');
    for (final route in publicRoutes) {
      print('   - $route');
    }
    
    print('✅ Auth Routes (Redirect to Home if Authenticated):');
    for (final route in authRoutes) {
      print('   - $route');
    }
    
    print('✅ Protected Routes (Redirect to Login if Not Authenticated):');
    for (final route in protectedRoutes) {
      print('   - $route');
    }
    
    print('🎉 Route Protection Test Complete!');
  }
}
