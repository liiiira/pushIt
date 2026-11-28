import 'package:pushit/domain/domain.dart';

/// What "edit everywhere" changes on one platform (F5).
enum EditScope {
  /// Title and description (YouTube).
  titleAndCaption,

  /// The caption only.
  caption,

  /// Not posted yet: the whole edit applies before it goes out.
  beforePosting,

  /// The platform's API cannot edit a posted video.
  notEditable,
}

typedef EditPlanRow = ({PlatformId platform, EditScope scope});

/// One row per platform the post is still on, in target order.
List<EditPlanRow> editPlanFor(Post post) => List.unmodifiable([
  for (final target in post.targets)
    if (target.status != TargetStatus.removed)
      (platform: target.platform, scope: _scopeOf(target)),
]);

/// How many platforms the edit reaches.
int applicableCount(List<EditPlanRow> plan) =>
    plan.where((row) => row.scope != EditScope.notEditable).length;

EditScope _scopeOf(PostTarget target) {
  if (target.status != TargetStatus.published) return EditScope.beforePosting;
  final fields = capabilityOf(target.platform).editableFields;
  if (fields.contains(EditableField.title)) return EditScope.titleAndCaption;
  if (fields.contains(EditableField.caption)) return EditScope.caption;
  return EditScope.notEditable;
}
