import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const AuthRegisterRequested({
    required this.username,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [username, email, password, firstName, lastName];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged();
}
