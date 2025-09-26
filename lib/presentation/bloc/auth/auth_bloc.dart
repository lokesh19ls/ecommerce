import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthUserChanged>(_onUserChanged);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.login(event.username, event.password);
      emit(AuthAuthenticated(user: user));
    } on Failure catch (failure) {
      emit(AuthError(message: failure.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.register(
        event.username,
        event.email,
        event.password,
        event.firstName,
        event.lastName,
      );
      emit(AuthAuthenticated(user: user));
    } on Failure catch (failure) {
      emit(AuthError(message: failure.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } on Failure catch (failure) {
      emit(AuthError(message: failure.message));
    } catch (e) {
      emit(const AuthError(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authRepository.getCachedUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } on Failure catch (failure) {
      emit(AuthError(message: failure.message));
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getCachedUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on Failure catch (failure) {
      emit(AuthError(message: failure.message));
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}
