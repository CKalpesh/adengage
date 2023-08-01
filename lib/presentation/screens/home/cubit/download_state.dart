// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'download_cubit.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadFailed extends DownloadState {}

class DownloadSuccess extends DownloadState {
  final String path;
  const DownloadSuccess({
    required this.path,
  });
  @override
  List<Object> get props => [path];
}
