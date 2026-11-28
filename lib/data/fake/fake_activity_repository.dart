import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

final class FakeActivityRepository implements ActivityRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Stream<List<ActivityItem>> watchActivity() =>
      _database.watchLoad(_database.activity);
}
