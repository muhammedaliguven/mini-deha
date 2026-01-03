import 'package:flutter/material.dart';

class SafeYoutubeThumbnail extends StatefulWidget {
  final String youtubeId;

  const SafeYoutubeThumbnail({
    Key? key,
    required this.youtubeId,
  }) : super(key: key);

  @override
  State<SafeYoutubeThumbnail> createState() => _SafeYoutubeThumbnailState();
}

class _SafeYoutubeThumbnailState extends State<SafeYoutubeThumbnail> {
  late String _currentUrl;
  bool _isMaxResFailed = false;

  @override
  void initState() {
    super.initState();
    // Start with the highest quality
    _currentUrl = 'https://img.youtube.com/vi/${widget.youtubeId}/maxresdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _currentUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 120, // Match the height in VideoCard
      errorBuilder: (context, error, stackTrace) {
        // If maxres failed, try hqdefault
        if (!_isMaxResFailed) {
          // We need to schedule the state update to avoid building during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isMaxResFailed = true;
                _currentUrl = 'https://img.youtube.com/vi/${widget.youtubeId}/hqdefault.jpg';
              });
            }
          });
          // Return a temporary placeholder while it reloads
          return Container(color: Colors.grey[200]);
        }

        // If both failed, show the final placeholder
        return Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey[500], size: 30),
              SizedBox(height: 4),
              Text(
                "Mini Deha",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
