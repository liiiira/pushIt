import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  group('capabilityOf', () {
    test('matches the spec table for every platform', () {
      const expected = {
        PlatformId.youtube: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          {EditableField.title, EditableField.caption},
        ),
        PlatformId.instagram: (
          AccountMode.assisted,
          DeleteMethod.assisted,
          <EditableField>{},
        ),
        PlatformId.facebook: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          {EditableField.caption},
        ),
        PlatformId.tiktok: (
          AccountMode.assisted,
          DeleteMethod.assisted,
          <EditableField>{},
        ),
        PlatformId.threads: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          <EditableField>{},
        ),
        PlatformId.linkedin: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          {EditableField.caption},
        ),
        PlatformId.bluesky: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          <EditableField>{},
        ),
        PlatformId.x: (
          AccountMode.automatic,
          DeleteMethod.automatic,
          <EditableField>{},
        ),
      };

      for (final platform in PlatformId.values) {
        final capability = capabilityOf(platform);
        final (publish, delete, editable) = expected[platform]!;
        expect(capability.platform, platform);
        expect(capability.publishMethod, publish, reason: '$platform publish');
        expect(capability.deleteMethod, delete, reason: '$platform delete');
        expect(capability.editableFields, editable, reason: '$platform edit');
        expect(
          capability.canEditAfterPosting,
          editable.isNotEmpty,
          reason: '$platform canEdit',
        );
      }
    });

    test('only X requires a paid plan', () {
      for (final platform in PlatformId.values) {
        expect(
          capabilityOf(platform).requiresPaidPlan,
          platform == PlatformId.x,
          reason: '$platform',
        );
      }
    });

    test('the four core platforms are not optional', () {
      expect(corePlatforms, {
        PlatformId.youtube,
        PlatformId.instagram,
        PlatformId.tiktok,
        PlatformId.facebook,
      });
    });
  });
}
