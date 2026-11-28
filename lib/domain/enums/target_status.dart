/// The state of one post on one platform.
enum TargetStatus {
  scheduled,
  uploading,
  processing,
  published,
  failed,
  awaitingUser,
  removed,
}
