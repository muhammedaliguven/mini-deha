
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String id;
  final String title;
  final String youtubeId;
  final String category;
  final bool isPremium;
  final String thumbnail;
  final String skillTag;
  final String duration;
  final String ageRange;

  VideoModel({
    required this.id,
    required this.title,
    required this.youtubeId,
    required this.category,
    required this.isPremium,
    required this.thumbnail,
    required this.skillTag,
    required this.duration,
    required this.ageRange,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled Video',
      youtubeId: json['youtube_id'] as String? ?? '',
      category: json['category'] as String? ?? json['category_id'] as String? ?? 'Unknown',
      isPremium: json['is_premium'] as bool? ?? false,
      thumbnail: json['thumbnail'] as String? ?? '',
      skillTag: json['skill_tag'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      ageRange: json['age_range'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'youtube_id': youtubeId,
      'category': category,
      'is_premium': isPremium,
      'thumbnail': thumbnail,
      'skill_tag': skillTag,
      'duration': duration,
      'age_range': ageRange,
    };
  }

  // Factory for Firestore DocumentSnapshot
  factory VideoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VideoModel.fromJson(data..['id'] = doc.id);
  }
}
