import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/video_model.dart';
import '../../data/services/firebase_service.dart';
import '../widgets/video_card.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.lock_shield),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ebeveyn Kilidi yakında...")),
              );
            },
          ),
        ],
      ),
            _buildVideoList(_firebaseService.getVideosByCategory("Evdeki Laboratuvar")),
             SizedBox(height: 24),

            // C. Veli Seçimi
            Container(
              color: Colors.orange[50], // Highlight parent section
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionHeader("Veli Seçimi 👩‍👧‍👦", "Özel seçilen içerikler"),
                  _buildVideoList(_firebaseService.getParentChoices()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MiniDehaColors.primaryLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.smiley, color: MiniDehaColors.primaryDark, size: 32),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.welcomeMessage,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: MiniDehaColors.primaryDark,
                      ),
                ),
                Text(
                  AppStrings.discoverTitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildVideoList(Stream<List<VideoModel>> streamVideos) {
    return SizedBox(
      height: 240, // Increased to prevent RenderFlex overflow
      child: StreamBuilder<List<VideoModel>>(
        stream: streamVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Hata oluştu"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Video bulunamadı"));
          }

          final videos = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return VideoCard(
                video: videos[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        videoId: videos[index].youtubeId,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
