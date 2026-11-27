import 'package:equatable/equatable.dart';

/// What the creator used this billing month.
final class Usage extends Equatable {
  const new({
    required this.postsThisMonth,
    required this.connectedAccounts,
    required this.resetsOn,
  });

  final int postsThisMonth;
  final int connectedAccounts;
  final DateTime resetsOn;

  Usage copyWith({
    int? postsThisMonth,
    int? connectedAccounts,
    DateTime? resetsOn,
  }) => Usage(
    postsThisMonth: postsThisMonth ?? this.postsThisMonth,
    connectedAccounts: connectedAccounts ?? this.connectedAccounts,
    resetsOn: resetsOn ?? this.resetsOn,
  );

  @override
  List<Object?> get props => [postsThisMonth, connectedAccounts, resetsOn];
}
