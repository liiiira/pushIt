import 'package:equatable/equatable.dart';

final class User extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
  });

  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;

  User copyWith({
    String? id,
    String? name,
    String? email,
    bool? isEmailVerified,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    isEmailVerified: isEmailVerified ?? this.isEmailVerified,
  );

  @override
  List<Object?> get props => [id, name, email, isEmailVerified];
}
