import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:flutter/services.dart';

void main() => runApp(const VideoStreamingApp());

class VideoStreamingApp extends StatelessWidget {
  const VideoStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RTSP Video Streaming',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VlcPlayerController _vlcViewController;
  bool _isPlaying = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _vlcViewController = VlcPlayerController.network(
     // 'rtsp://guardnet.selfip.com:7100',
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _vlcViewController.pause();
      } else {
        _vlcViewController.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }
      _isFullScreen = !_isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
        title: const Text('RTSP Video Streaming'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: VlcPlayer(
                    controller: _vlcViewController,
                    aspectRatio: 16 / 9,
                    placeholder: const Center(child: CircularProgressIndicator()),
                  ),
                ),
                if (!_isFullScreen)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _togglePlayPause,
                          child: Text(_isPlaying ? 'Pause' : 'Play'),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _toggleFullScreen,
                          child: const Text('Full Screen'),
                        ),
                      ],
                    ),
                  ),
                if (_isFullScreen)
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                      onPressed: _toggleFullScreen,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
