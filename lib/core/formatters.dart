/// Small, locale-neutral text helpers shared by the widgets.
library;

/// A clip length as on the designs: `1:42`, `0:38`, `1:02:03`.
String formatClipDuration(Duration duration) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return hours > 0
      ? '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}'
      : '$minutes:${twoDigits(seconds)}';
}

/// Up to two upper-case initials: `Lyes B.` → `LB`.
String initialsOf(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .take(2)
    .map((word) => String.fromCharCode(word.runes.first).toUpperCase())
    .join();
