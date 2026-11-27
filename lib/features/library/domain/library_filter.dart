import 'package:pushit/domain/domain.dart';

/// The Library tabs (F1).
enum LibraryFilter { all, scheduled, published, failed }

/// The posts [filter] shows, in their original order. Drafts never show.
List<Post> filterLibrary(List<Post> posts, LibraryFilter filter) =>
    List.unmodifiable(
      posts.where((post) {
        if (post.isDraft) return false;
        return switch (filter) {
          LibraryFilter.all => true,
          LibraryFilter.scheduled =>
            post.status == PostStatus.scheduled ||
                post.status == PostStatus.publishing,
          LibraryFilter.published => post.status == PostStatus.published,
          LibraryFilter.failed =>
            post.status == PostStatus.failed ||
                post.status == PostStatus.partiallyFailed,
        };
      }),
    );
