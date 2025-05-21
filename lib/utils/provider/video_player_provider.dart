import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerProvider extends ChangeNotifier {
  late VideoPlayerController controller;
  bool initialized = false;
  bool isPlaying = false;

  Future<void> init(String url) async {
    controller = VideoPlayerController.network(url);
    await controller.initialize();
    controller.setLooping(true);
    initialized = true;
    isPlaying = controller.value.isPlaying;
    notifyListeners();
  }

  void playPause() {
    if (controller.value.isPlaying) {
      controller.pause();
      isPlaying = false;
    } else {
      controller.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}