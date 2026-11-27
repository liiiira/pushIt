import 'package:pushit/domain/domain.dart';

const int _mb = 1024 * 1024;

/// The device gallery of D1, in the order shown.
const List<GalleryItem> fixtureGallery = [
  GalleryItem(
    id: 'gallery-studio-tour',
    fileName: 'studio_tour_p2.mp4',
    duration: Duration(minutes: 1, seconds: 42),
    sizeBytes: 300 * _mb,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'gallery-broll',
    fileName: 'morning_broll.mp4',
    duration: Duration(seconds: 38),
    sizeBytes: 74 * _mb,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'gallery-unboxing',
    fileName: 'unboxing_lav_mic.mp4',
    duration: Duration(seconds: 59),
    sizeBytes: 118 * _mb,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'gallery-qa',
    fileName: 'qa_short_cut.mp4',
    duration: Duration(minutes: 2, seconds: 10),
    sizeBytes: 246 * _mb,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'gallery-mic-test',
    fileName: 'mic_test.mp4',
    duration: Duration(seconds: 21),
    sizeBytes: 38 * _mb,
    width: 1080,
    height: 1920,
  ),
  GalleryItem(
    id: 'gallery-desk-cable',
    fileName: 'desk_cable_fix.mp4',
    duration: Duration(minutes: 1, seconds: 5),
    sizeBytes: 131 * _mb,
    width: 1080,
    height: 1920,
  ),
];

/// The uploaded video made from [item].
VideoAsset fixtureVideoFrom(GalleryItem item) => VideoAsset(
  id: 'video-${item.id}',
  fileName: item.fileName,
  duration: item.duration,
  sizeBytes: item.sizeBytes,
  width: item.width,
  height: item.height,
);

VideoAsset fixtureVideo(String galleryId) =>
    fixtureVideoFrom(fixtureGallery.firstWhere((i) => i.id == galleryId));

/// "Behind the desk" (G2) was filmed on another device.
const VideoAsset fixtureBehindTheDeskVideo = VideoAsset(
  id: 'video-behind-the-desk',
  fileName: 'behind_the_desk.mp4',
  duration: Duration(seconds: 52),
  sizeBytes: 96 * _mb,
  width: 1080,
  height: 1920,
);

/// "Lighting test" was filmed on another device.
const VideoAsset fixtureLightingTestVideo = VideoAsset(
  id: 'video-lighting-test',
  fileName: 'lighting_test.mp4',
  duration: Duration(seconds: 45),
  sizeBytes: 88 * _mb,
  width: 1080,
  height: 1920,
);
