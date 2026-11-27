/// The overall state of a post, derived from its targets by
/// `derivePostStatus`.
enum PostStatus {
  draft,
  scheduled,
  publishing,
  published,
  partiallyFailed,
  failed,
}
