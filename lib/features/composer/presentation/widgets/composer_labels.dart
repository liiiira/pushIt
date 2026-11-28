import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/date_labels.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// Phrases dates and sizes for the composer screens.
extension ComposerLabels on BuildContext {
  /// "Edited 2 h ago · no time set" (D12).
  String draftLine(Post draft, {required DateTime now}) {
    final edited = l10n.composerDraftEdited(
      _editedAgo(draft.updatedAt, now: now),
    );
    final at =
        draft.nextScheduledAt ??
        draft.targets.map((t) => t.scheduledAt).nonNulls.firstOrNull;
    return l10n.composerDraftLine(
      edited,
      at == null ? l10n.composerDraftNoTime : dayAndTimeLabel(at, now: now),
    );
  }

  String _editedAgo(DateTime at, {required DateTime now}) {
    if (relativeDayOf(at, now: now) == RelativeDay.yesterday) {
      return l10n.composerEditedYesterday;
    }
    final (:unit, :count) = elapsedBetween(at, now);
    return switch (unit) {
      ElapsedUnit.justNow => l10n.composerEditedJustNow,
      ElapsedUnit.minutes => l10n.composerEditedMinutesAgo(count),
      ElapsedUnit.hours => l10n.composerEditedHoursAgo(count),
      ElapsedUnit.days => l10n.composerEditedDaysAgo(count),
    };
  }
}

/// Whole megabytes, rounded down.
int megabytesOf(int bytes) => bytes ~/ (1024 * 1024);
