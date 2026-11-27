import 'package:pushit/domain/entities/gallery_item.dart';
import 'package:pushit/domain/entities/upload_progress.dart';

/// The device gallery and the one upload in progress. Methods throw
/// `AppFailure`.
abstract interface class MediaRepository {
  Future<List<GalleryItem>> gallery();

  /// Uploads a gallery video. The stream ends after `Uploaded` or
  /// `UploadFailed`, or when [cancel] is called.
  Stream<UploadProgress> upload(String galleryItemId);

  Future<void> pause();

  Future<void> resume();

  Future<void> cancel();
}
