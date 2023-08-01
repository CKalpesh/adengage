import 'dart:async';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

part 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  DownloadCubit() : super(DownloadInitial());

  FutureOr<void> downloadImage(String imageUrl, String imageId) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      final dir = await getTemporaryDirectory();

      var filename = '${dir.path}/pexels-image$imageId.png';

      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);

      final params = SaveFileDialogParams(sourceFilePath: file.path);
      final finalPath = await FlutterFileDialog.saveFile(params: params);

      if (finalPath != null) {
        emit(DownloadSuccess(path: finalPath));
      }
    } catch (e) {
      emit(DownloadFailed());
    }
  }
}
