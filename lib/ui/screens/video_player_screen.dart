import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../data/services/local_storage_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String skillTag; // Added for tracking

  const VideoPlayerScreen({
    Key? key, 
    required this.videoId,
    required this.skillTag,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _hasCountedScore = false;
  final LocalStorageService _storage = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _storage.init(); // Ensure storage is ready
    
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
        forceHD: false,
      ),
    );
  }

  void _listener() async {
    if (_controller.value.isReady && !_hasCountedScore) {
      final duration = _controller.metadata.duration.inSeconds;
      final position = _controller.value.position.inSeconds;

      // Rule: If watched > 80% (0.8)
      if (duration > 0 && (position / duration > 0.8)) {
        _hasCountedScore = true;
        
        bool success = await _storage.incrementSkillScore(widget.skillTag, widget.videoId);
        
        if (!mounted) return;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Harika! '${widget.skillTag}' puanın arttı! 🌟"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Bu video daha önce puanlandırılmış 🎬"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        progressColors: const ProgressBarColors(
          playedColor: Colors.amber,
          handleColor: Colors.amberAccent,
        ),
        onReady: () {
          _controller.addListener(_listener);
        },
      ),
      builder: (context, player) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: player,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }
}
