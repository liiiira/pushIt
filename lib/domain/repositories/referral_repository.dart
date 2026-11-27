import 'package:pushit/domain/entities/referral.dart';

/// Methods throw `AppFailure`.
abstract interface class ReferralRepository {
  Future<Referral> referral();
}
