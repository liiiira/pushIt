import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

final class FakeReferralRepository implements ReferralRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Future<Referral> referral() => _database.act(() => _database.referral);
}
