import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adengage_task/models/image_data_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc({ImageRepository? imageRepository})
      : _imageRepository = imageRepository ?? ImageRepository(),
        super(const ImageInitial()) {
    on<ImageEvent>((event, emit) {});
    on<FetchImages>(_fetchImages);
    on<ChangeImage>(_changeImage);
  }

  FutureOr<void> _fetchImages(
    FetchImages event,
    Emitter<ImageState> emit,
  ) async {
    try {
      emit(const ImagesLoading());
      final images = await _imageRepository.getCuratedImages();
      if (images.photos != null && images.photos!.isNotEmpty) {
        emit(
          ImagesLoaded(
            images: images,
            currentPhoto: images.photos!.first,
          ),
        );
      } else {
        emit(const ImageLoadError(errorMessage: 'Could not fetch images'));
      }
    } catch (e) {
      emit(const ImageLoadError(errorMessage: 'Could not fetch images'));
    }
  }

  FutureOr<void> _changeImage(
    ChangeImage event,
    Emitter<ImageState> emit,
  ) async {
    debugPrint('CHANGING IMAGE');
    final loadedState = state as ImagesLoaded;
    emit(loadedState.copyWith(
      currentPhoto: event.photo,
    ));
    debugPrint('CHANGING IMAGE2');
  }

  final ImageRepository _imageRepository;
}

class ImageRepository {
  ImageRepository({ImageDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? ImageDataProvider();

  Future<ImageDataModel> getCuratedImages() async {
    final response =
        await _dataProvider.getCuratedImage() as Map<String, dynamic>;
    final images = ImageDataModel.fromJson(response);
    return images;
  }

  final ImageDataProvider _dataProvider;
}

class ImageDataProvider {
  Future<dynamic> getCuratedImage() async {
    const url = 'https://api.pexels.com/v1/curated';
    final uri = Uri.parse(url);
    final response = await http.get(
      uri,
      headers: {
        // API Key for Authorization
        'Authorization':
            'zPEHHok0A1xwCMP6uBlj0rRkFS9DXuc67KArTWnEyuO1MRMlRN0xOduU',
      },
    );
    debugPrint('IMAGE : ${response.body}');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    }
  }
}
