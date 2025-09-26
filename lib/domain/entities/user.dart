import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? gender;
  final String? image;
  final String? token;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.image,
    this.token,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        gender,
        image,
        token,
      ];

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      token: token ?? this.token,
    );
  }
}
