/// The status every page state carries.
///
/// - [loading] shows `SkeletonList` (I2).
/// - [empty] shows the page's `EmptyStateView`.
/// - [failure] shows `ErrorStateView` (I3) with retry.
enum ViewStatus { initial, loading, ready, empty, failure }
