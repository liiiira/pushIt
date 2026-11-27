import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/account_mode.dart';
import 'package:pushit/domain/enums/delete_method.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// What can be changed on a platform after posting.
enum EditableField { title, caption }

/// What pushIt can do on a platform (spec table, docs/DOMAIN.md §2).
final class PlatformCapability extends Equatable {
  const new({
    required this.platform,
    required this.publishMethod,
    required this.deleteMethod,
    this.editableFields = const {},
    this.requiresPaidPlan = false,
  });

  final PlatformId platform;
  final AccountMode publishMethod;
  final DeleteMethod deleteMethod;
  final Set<EditableField> editableFields;
  final bool requiresPaidPlan;

  bool get canEditAfterPosting => editableFields.isNotEmpty;

  @override
  List<Object?> get props => [
    platform,
    publishMethod,
    deleteMethod,
    editableFields,
    requiresPaidPlan,
  ];
}

/// YouTube, Instagram, TikTok and Facebook; the others are optional.
const Set<PlatformId> corePlatforms = {
  PlatformId.youtube,
  PlatformId.instagram,
  PlatformId.tiktok,
  PlatformId.facebook,
};

PlatformCapability capabilityOf(PlatformId platform) => switch (platform) {
  PlatformId.youtube => const PlatformCapability(
    platform: PlatformId.youtube,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
    editableFields: {EditableField.title, EditableField.caption},
  ),
  // Automatic once Meta approves the app.
  PlatformId.instagram => const PlatformCapability(
    platform: PlatformId.instagram,
    publishMethod: AccountMode.assisted,
    deleteMethod: DeleteMethod.assisted,
  ),
  // Automatic publishing after TikTok's audit; the API has no delete.
  PlatformId.tiktok => const PlatformCapability(
    platform: PlatformId.tiktok,
    publishMethod: AccountMode.assisted,
    deleteMethod: DeleteMethod.assisted,
  ),
  PlatformId.facebook => const PlatformCapability(
    platform: PlatformId.facebook,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
    editableFields: {EditableField.caption},
  ),
  PlatformId.threads => const PlatformCapability(
    platform: PlatformId.threads,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
  ),
  PlatformId.linkedin => const PlatformCapability(
    platform: PlatformId.linkedin,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
    editableFields: {EditableField.caption},
  ),
  PlatformId.bluesky => const PlatformCapability(
    platform: PlatformId.bluesky,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
  ),
  PlatformId.x => const PlatformCapability(
    platform: PlatformId.x,
    publishMethod: AccountMode.automatic,
    deleteMethod: DeleteMethod.automatic,
    requiresPaidPlan: true,
  ),
};
