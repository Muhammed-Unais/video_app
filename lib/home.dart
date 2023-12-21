import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:video_app/constants.dart';
import 'package:video_player/video_player.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late VideoPlayerController _controllers;

  @override
  void initState() {
    intializeVideo();
    super.initState();
  }

  void intializeVideo() {
    _controllers = VideoPlayerController.networkUrl(Uri.parse(videoPath));

    _controllers.initialize().then((_) {
      _controllers.addListener(() => setState(() {}));
      _controllers.play();
      _controllers.setLooping(true);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controllers.pause();
    _controllers.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video App"),
      ),
      body: Container(
        padding: const EdgeInsets.all(4),
        height: _controllers.value.size.height - 118,
        child: Stack(
          children: [
            VideoPlayerWidget(
              controller: _controllers,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                "assets/images/TS02.jpeg",
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {},
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> combineVideoAndImage(
      String videoPath, String imagePath, String outputVideoPath) async {
    await FFmpegKit.execute("-i $videoPath -vf fps=30 frame%04d.png");

    for (int i = 1; i <= 30; i++) {
      final String inputFramePath = 'frame${i.toString().padLeft(4, '0')}.png';
      await FFmpegKit.execute(
          "-i $inputFramePath -i $imagePath -filter_complex overlay=0:0 $outputVideoPath");
    }

    await FFmpegKit.execute(
        "-framerate 30 -i frame%04d.png -c:v libx264 -pix_fmt yuv420p $outputVideoPath");

    for (int i = 1; i <= 30; i++) {
      final String inputFramePath = 'frame${i.toString().padLeft(4, '0')}.png';
      await FFmpegKit.execute("rm $inputFramePath");
    }
  }
}

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key, this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) => controller!.value.isInitialized
      ? buildVideo()
      : const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
  Widget buildVideo() => AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: VideoPlayer(
          controller!,
        ),
      );
}
