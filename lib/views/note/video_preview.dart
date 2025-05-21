import 'package:flutter/material.dart';
import 'package:mi_estudio/utils/custom_widgets/custom_loading.dart';
import 'package:mi_estudio/utils/function/function_dowload_file.dart';
import 'package:provider/provider.dart';
import 'package:mi_estudio/utils/provider/video_player_provider.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatelessWidget {
  const VideoPreview({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoPlayerProvider()..init(url),
      child: Consumer<VideoPlayerProvider>(
        builder: (context, videoProvider, _) {
          if (!videoProvider.initialized) {
            return const CustomLoading(size: 50);
          }
          return GestureDetector(
            onTap: videoProvider.playPause,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: videoProvider.controller.value.aspectRatio,
                  child: VideoPlayer(videoProvider.controller),
                ),
                if (!videoProvider.isPlaying)
                  const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(Icons.download, color: Theme.of(context).primaryColor, size: 28),
                    tooltip: 'Descargar video',
                    onPressed: () => downloadFile(context, url, url.split('/').last),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}