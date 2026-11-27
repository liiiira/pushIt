import 'package:equatable/equatable.dart';

final class Referral extends Equatable {
  const new({
    required this.code,
    required this.joinedCount,
    required this.monthsEarned,
  });

  final String code;
  final int joinedCount;
  final int monthsEarned;

  Referral copyWith({String? code, int? joinedCount, int? monthsEarned}) =>
      Referral(
        code: code ?? this.code,
        joinedCount: joinedCount ?? this.joinedCount,
        monthsEarned: monthsEarned ?? this.monthsEarned,
      );

  @override
  List<Object?> get props => [code, joinedCount, monthsEarned];
}
