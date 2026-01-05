import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/video_model.dart';
import '../../data/services/firebase_service.dart';
import '../widgets/video_card.dart';
import 'video_player_screen.dart';
import 'report_card_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Color _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return Colors.black87;
    try {
      return Color(int.parse(hexString));
    } catch (e) {
      return Colors.black87;
    }
  }

  IconData _getIconByName(String? iconName) {
    switch (iconName) {
      case 'palette': return Icons.palette;
      case 'science': return Icons.science;
      case 'music_note': return Icons.music_note;
      case 'psychology': return Icons.psychology;
      case 'public': return Icons.public;
      default: return Icons.category;
    }
  }

  Widget _buildVideoListFromData(List<VideoModel> videos) {
    return SizedBox(
      height: 240, 
      child: ListView.builder(
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
                    skillTag: videos[index].skillTag,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.chart_bar_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportCardScreen()),
              );
            },
            tooltip: "Yetenek Karnesi",
          ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildWelcomeHeader(),
            
            // 1. Günün Keşfi (Dynamic - Smart Feed)
            _buildSectionHeader("Günün Keşfi 🌟", "Sizin için seçtiklerimiz"),
            _buildVideoList(_firebaseService.getDailyDiscovery()),
            SizedBox(height: 24),

            // 2. Dynamic Categories Loop
            StreamBuilder<QuerySnapshot>(
              stream: _firebaseService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                
                var categories = snapshot.data!.docs;

                return Column(
                  children: categories.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String name = data['name'] ?? 'Kategori';
                    String colorHex = data['color'] as String? ?? '';
                    String iconName = data['icon'] as String? ?? '';
                    
                    Color categoryColor = _parseColor(colorHex);
                    IconData categoryIcon = _getIconByName(iconName);

                    // STREAMBUILDER MOVED HERE to hide empty categories
                    return StreamBuilder<List<VideoModel>>(
                      stream: _firebaseService.getVideosByCategory(name),
                      builder: (context, videoSnapshot) {
                        if (!videoSnapshot.hasData || videoSnapshot.data!.isEmpty) {
                          return SizedBox.shrink(); // HIDES THE SECTION IF EMPTY
                        }

                        return Column(
                          children: [
                             _buildSectionHeader(name, "", icon: categoryIcon, color: categoryColor),
                            _buildVideoListFromData(videoSnapshot.data!), 
                            SizedBox(height: 24),
                          ],
                        );
                      }
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 24),
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

  Widget _buildSectionHeader(String title, String subtitle, {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( 
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color ?? Colors.black87, size: 24),
                  SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color ?? Colors.black87,
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
              ],
            ),
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
                        skillTag: videos[index].skillTag,
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
