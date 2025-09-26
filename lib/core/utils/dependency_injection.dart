import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/datasources/wishlist_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/local_cart_repository_impl.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/local_cart_repository.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/product/product_bloc.dart';
import '../../presentation/bloc/cart/cart_bloc.dart';
import '../../presentation/bloc/cart/cart_api_bloc.dart';
import '../../presentation/bloc/wishlist/wishlist_bloc.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(apiClient: getIt()),
  );
  getIt.registerLazySingleton<WishlistLocalDataSource>(
    () => WishlistLocalDataSourceImpl(sharedPreferences: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton<LocalCartRepository>(
    () => LocalCartRepositoryImpl(),
  );
  getIt.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(localDataSource: getIt()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt()),
  );
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(productRepository: getIt()),
  );
  getIt.registerFactory<CartBloc>(
    () => CartBloc(cartRepository: getIt<LocalCartRepository>()),
  );
  getIt.registerFactory<CartApiBloc>(
    () => CartApiBloc(cartRepository: getIt()),
  );
  getIt.registerFactory<WishlistBloc>(
    () => WishlistBloc(wishlistRepository: getIt()),
  );
  getIt.registerFactory<ThemeBloc>(
    () => ThemeBloc(sharedPreferences: getIt()),
  );
}
