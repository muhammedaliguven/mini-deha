import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for "Daily Discovery" (Filtered: !isPremium && pedagogueApproved)
  Stream<List<VideoModel>> getDailyDiscovery() {
    return _firestore
        .collection('videos')
        .where('is_premium', isEqualTo: false) // Free content only
        .where('pedagogue_approved', isEqualTo: true) // Approved content only
        .limit(10)
        .snapshots()
        .map((snapshot) {
      final allVideos = snapshot.docs.map((doc) {
        try {
          return VideoModel.fromFirestore(doc);
        } catch (e) {
          debugPrint("Error parsing video ${doc.id}: $e");
          return null;
        }
      }).whereType<VideoModel>().toList();
      
      // Shuffle and take 5 for variety
      allVideos.shuffle();
      return allVideos.take(5).toList();
    });
  }

  // Stream for Categories
  Stream<List<VideoModel>> getVideosByCategory(String categoryTitle) {
    // Note: We are querying by 'category' field. 
    // If you have mismatching category names/ids, this might return empty.
    return _firestore
        .collection('videos')
        .where('category', isEqualTo: categoryTitle)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return VideoModel.fromFirestore(doc);
        } catch (e) {
          debugPrint("Error parsing video in category $categoryTitle: $e");
          return null;
        }
      }).whereType<VideoModel>().toList();
    });
  }

  // Stream for Categories
  Stream<QuerySnapshot> getCategories() {
    return _firestore.collection('categories').snapshots();
  }

  // Stream for Parent Choices (Premium content)
  Stream<List<VideoModel>> getParentChoices() {
    return _firestore
        .collection('videos')
        .where('is_premium', isEqualTo: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return VideoModel.fromFirestore(doc);
        } catch (e) {
          debugPrint("Error parsing premium video: $e");
          return null;
        }
      }).whereType<VideoModel>().toList();
    });
  }

  // DATA MIGRATION HELPER
  Future<void> migrateCategories() async {
    final snapshot = await _firestore.collection('videos').get();
    final batch = _firestore.batch();
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final currentCategory = data['category'] as String? ?? '';
      final title = (data['title'] as String? ?? '').toLowerCase();
      
      String? newCategory;

      if (currentCategory == 'Günün Keşfi') {
        if (title.contains('güneş') || title.contains('uzay') || title.contains('gezegen')) {
          newCategory = 'Evreni Keşfet 🌌';
        } else if (title.contains('hayvan') || title.contains('kedi') || title.contains('köpek') || title.contains('aslan')) {
          newCategory = 'Doğa Dostları 🐾';
        } else {
          newCategory = 'Eğlenceli Bilim 🧪';
        }
      } else if (currentCategory == 'Veli Seçimi') {
        if (title.contains('ingilizce') || title.contains('english')) {
          newCategory = 'Dil Dünyası 🌍';
        } else {
          newCategory = 'Gelişim Atölyesi 🧠';
        }
      }
      
      if (newCategory != null) {
        batch.update(doc.reference, {'category': newCategory});
        debugPrint("Migrating '${data['title']}' from '$currentCategory' to '$newCategory'");
      }
    }
    
    await batch.commit();
    debugPrint("Migration Completed!");
  }

}
