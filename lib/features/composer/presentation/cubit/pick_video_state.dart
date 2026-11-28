part of 'pick_video_cubit.dart';

enum PickVideoTab { gallery, drafts }

final class PickVideoState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.gallery = const [],
    this.selectedId,
    this.tab = PickVideoTab.gallery,
    this.failure,
  });

  final ViewStatus status;
  final List<GalleryItem> gallery;
  final String? selectedId;
  final PickVideoTab tab;
  final AppFailure? failure;

  GalleryItem? get selected =>
      gallery.where((item) => item.id == selectedId).firstOrNull;

  PickVideoState copyWith({
    ViewStatus? status,
    List<GalleryItem>? gallery,
    String? Function()? selectedId,
    PickVideoTab? tab,
    AppFailure? Function()? failure,
  }) => PickVideoState(
    status: status ?? this.status,
    gallery: gallery != null ? List.unmodifiable(gallery) : this.gallery,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
    tab: tab ?? this.tab,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, gallery, selectedId, tab, failure];
}
