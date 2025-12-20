import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../data/models/category_model.dart';
import '../widgets/category_card.dart';
import 'video_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  // Mock Data
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: '1',
      title: AppStrings.catPainters,
      icon: CupertinoIcons.paintbrush,
      color: Colors.pinkAccent,
      description: 'Resim ve çizim videoları',
    ),
    CategoryModel(
      id: '2',
      title: AppStrings.catLab,
      icon: CupertinoIcons.lab_flask,
      color: Colors.blueAccent,
      description: 'Bilimsel deneyler',
    ),
    CategoryModel(
      id: '3',
      title: AppStrings.catRhythm,
      icon: CupertinoIcons.music_note_2,
      color: Colors.purpleAccent,
      description: 'Çocuk şarkıları ve dans',
    ),
    CategoryModel(
      id: '4',
      title: AppStrings.catLogic,
      icon: CupertinoIcons.lightbulb,
      color: Colors.orangeAccent,
      description: 'Zeka oyunları',
    ),
    CategoryModel(
      id: '5',
      title: AppStrings.catExplore,
      icon: CupertinoIcons.globe,
      color: Colors.green,
      description: 'Doğa ve hayvanlar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.lock_shield),
            onPressed: () {
              // TODO: Implement Parent Gate
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Ebeveyn Kilidi yakında...")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
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
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryCard(
                  category: categories[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoListScreen(category: categories[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
