// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'image_bloc.dart';

@immutable
abstract class ImageEvent extends Equatable {}

class FetchImages extends ImageEvent {
  @override
  List<Object?> get props => [];
}

class DownloadImage extends ImageEvent {
  final String imageUrl;
  final String imageId;
  DownloadImage({
    required this.imageUrl,
    required this.imageId,
  });
  @override
  List<Object?> get props => [imageUrl];
}

class ChangeImage extends ImageEvent {
  final Photos photo;
  ChangeImage({
    required this.photo,
  });
  @override
  List<Object?> get props => [photo];
}
