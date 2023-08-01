import 'package:adengage_task/models/image_data_model.dart';
import 'package:adengage_task/presentation/extensions/context_extensions.dart';
import 'package:adengage_task/presentation/screens/home/bloc/image_bloc.dart';
import 'package:adengage_task/presentation/screens/home/cubit/download_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:rive/rive.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ImageBloc(),
        ),
        BlocProvider(
          create: (context) => DownloadCubit(),
        ),
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PageController _pageController;
  late RiveAnimationController _controller;

  @override
  void initState() {
    context.read<ImageBloc>().add(FetchImages());
    _pageController = PageController(viewportFraction: 0.8);
    _controller = SimpleAnimation('idel');
    super.initState();
  }

  // Color currentColor = Colors.white;
  // String currentPhotographer = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('AdEngage'),
      //   backgroundColor: currentColor,
      // ),
      body: BlocListener<DownloadCubit, DownloadState>(
        listener: (context, state) {
          if (state is DownloadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                showCloseIcon: true,
                content: Text(
                  'Image Saved',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.purpleAccent,
              ),
            );
            _controller.isActive = false;
          } else if (state is DownloadFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Download Failed',
                ),
                backgroundColor: Colors.red,
              ),
            );
            _controller.isActive = false;
          }
        },
        child: BlocBuilder<ImageBloc, ImageState>(
          builder: (context, state) {
            if (state is ImagesLoaded) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: double.maxFinite,
                width: double.maxFinite,
                color: HexColor(state.currentPhoto.avgColor!),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            onPageChanged: (value) {
                              context.read<ImageBloc>().add(
                                    ChangeImage(
                                        photo: state.images!.photos!
                                            .elementAt(value)),
                                  );
                            },
                            controller: _pageController,
                            itemCount: state.images!.photos!.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final image =
                                  state.images!.photos!.elementAt(index);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return ScaleTransition(
                                          scale: animation,
                                          child: child,
                                        );
                                      },
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return EnlargeImageScreen(
                                          image: image,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Hero(
                                  tag: '${image.id}',
                                  child: AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double value = 1;
                                      if (_pageController
                                          .position.haveDimensions) {
                                        value = _pageController.page! - index;
                                        value = (1 - (value.abs() * 0.1))
                                            .clamp(0.0, 1.0);
                                        return Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            height:
                                                Curves.easeIn.transform(value) *
                                                    context.screenHeight(0.4),
                                            width: context.screenWidth(0.7),
                                            child: child,
                                          ),
                                        );
                                      } else {
                                        return Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            height: Curves.easeIn.transform(
                                                    index == 0
                                                        ? value
                                                        : value * 0.5) *
                                                context.screenHeight(0.4),
                                            width: context.screenWidth(0.7),
                                            child: child,
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                            image.src!.portrait!,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: context.screenHeight(0.2),
                      child: SizedBox(
                        width: context.screenWidth(1),
                        child: Center(
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 2000),
                                child: Text(
                                  state.currentPhoto.photographer!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      context
                                          .read<DownloadCubit>()
                                          .downloadImage(
                                            state.currentPhoto.src!.portrait!,
                                            state.currentPhoto.id.toString(),
                                          );
                                    },
                                    child: const Icon(Icons.download),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is ImageLoadError) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            } else if (state is ImagesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class EnlargeImageScreen extends StatelessWidget {
  const EnlargeImageScreen({
    super.key,
    required this.image,
  });

  final Photos image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor(image.avgColor!),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: HexColor(image.avgColor!),
      body: Hero(
        tag: '${image.id}',
        child: CachedNetworkImage(
          imageUrl: image.src!.portrait!,
          height: double.maxFinite,
        ),
      ),
    );
  }
}
