import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:ecommerce/domain/entities/user.dart';
import 'package:ecommerce/domain/repositories/auth_repository.dart';
import 'package:ecommerce/presentation/bloc/auth/auth_bloc.dart';
import 'package:ecommerce/presentation/bloc/auth/auth_event.dart';
import 'package:ecommerce/presentation/bloc/auth/auth_state.dart';
import 'package:ecommerce/core/errors/failures.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    const testUser = User(
      id: 1,
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      token: 'test_token',
    );

    group('AuthLoginRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login is successful',
        build: () {
          when(mockAuthRepository.login('test@example.com', 'password'))
              .thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@example.com',
            password: 'password',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(user: testUser),
        ],
        verify: (_) {
          verify(mockAuthRepository.login('test@example.com', 'password')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails',
        build: () {
          when(mockAuthRepository.login('test@example.com', 'password'))
              .thenThrow(const AuthFailure(message: 'Invalid credentials'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@example.com',
            password: 'password',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid credentials'),
        ],
        verify: (_) {
          verify(mockAuthRepository.login('test@example.com', 'password')).called(1);
        },
      );
    });

    group('AuthRegisterRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when registration is successful',
        build: () {
          when(mockAuthRepository.register(
            'test@example.com',
            'password',
            'Test',
            'User',
          )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@example.com',
            password: 'password',
            firstName: 'Test',
            lastName: 'User',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthAuthenticated(user: testUser),
        ],
        verify: (_) {
          verify(mockAuthRepository.register(
            'test@example.com',
            'password',
            'Test',
            'User',
          )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when registration fails',
        build: () {
          when(mockAuthRepository.register(
            'test@example.com',
            'password',
            'Test',
            'User',
          )).thenThrow(const AuthFailure(message: 'Email already exists'));
          return authBloc;
        },
        act: (bloc) => bloc.add(
          const AuthRegisterRequested(
            email: 'test@example.com',
            password: 'password',
            firstName: 'Test',
            lastName: 'User',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Email already exists'),
        ],
        verify: (_) {
          verify(mockAuthRepository.register(
            'test@example.com',
            'password',
            'Test',
            'User',
          )).called(1);
        },
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
        build: () {
          when(mockAuthRepository.logout()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(mockAuthRepository.logout()).called(1);
        },
      );
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when user is logged in',
        build: () {
          when(mockAuthRepository.isLoggedIn()).thenAnswer((_) async => true);
          when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthAuthenticated(user: testUser),
        ],
        verify: (_) {
          verify(mockAuthRepository.isLoggedIn()).called(1);
          verify(mockAuthRepository.getCurrentUser()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when user is not logged in',
        build: () {
          when(mockAuthRepository.isLoggedIn()).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(mockAuthRepository.isLoggedIn()).called(1);
          verifyNever(mockAuthRepository.getCurrentUser());
        },
      );
    });
  });
}
