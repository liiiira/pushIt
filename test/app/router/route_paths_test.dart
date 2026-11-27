import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/router/route_paths.dart';

void main() {
  group('RoutePaths', () {
    test('nested paths are built from their parent and segment', () {
      expect(RoutePaths.activity, '/home/activity');
      expect(RoutePaths.addAccount, '/accounts/add');
      expect(RoutePaths.composePostCaptions, '/compose/post/captions');
      expect(
        RoutePaths.libraryPostDeleteResult,
        '/library/:postId/delete/result',
      );
      expect(RoutePaths.assistedDelete, '/assisted/:postId/:platform/delete');
      expect(RoutePaths.plans, '/settings/plans');
      expect(RoutePaths.developer, '/settings/developer');
    });

    test('helpers fill in path parameters', () {
      expect(RoutePaths.accountDetailFor('a1'), '/accounts/a1');
      expect(RoutePaths.libraryPostFor('p1'), '/library/p1');
      expect(RoutePaths.libraryPostEditFor('p1'), '/library/p1/edit');
      expect(RoutePaths.libraryPostDeleteFor('p1'), '/library/p1/delete');
      expect(
        RoutePaths.libraryPostDeleteResultFor('p1'),
        '/library/p1/delete/result',
      );
      expect(RoutePaths.assistedFor('p1', 'tiktok'), '/assisted/p1/tiktok');
      expect(
        RoutePaths.assistedDeleteFor('p1', 'tiktok'),
        '/assisted/p1/tiktok/delete',
      );
    });

    test('helpers encode parameters', () {
      expect(RoutePaths.libraryPostFor('a b/c'), '/library/a%20b%2Fc');
    });
  });
}
