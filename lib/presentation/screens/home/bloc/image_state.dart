// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'image_bloc.dart';

@immutable
abstract class ImageState extends Equatable {
  final ImageDataModel? images;
  const ImageState({
    this.images,
  });

  @override
  List<Object?> get props => [images];
}

class ImageInitial extends ImageState {
  const ImageInitial({super.images});

  @override
  List<Object?> get props => [images];
}

class ImagesLoading extends ImageState {
  const ImagesLoading() : super();
  @override
  List<Object?> get props => [];
}

class ImagesLoaded extends ImageState {
  const ImagesLoaded({
    required super.images,
    required this.currentPhoto,
  });
  final Photos currentPhoto;

  @override
  List<Object?> get props => [
        currentPhoto,
      ];

  ImagesLoaded copyWith({
    Photos? currentPhoto,
    ImageDataModel? images,
  }) {
    return ImagesLoaded(
      currentPhoto: currentPhoto ?? this.currentPhoto,
      images: images ?? this.images,
    );
  }
}

class ImageLoadError extends ImageState {
  const ImageLoadError({
    required this.errorMessage,
  });
  final String errorMessage;

  @override
  List<Object?> get props => [
        errorMessage,
      ];
}
