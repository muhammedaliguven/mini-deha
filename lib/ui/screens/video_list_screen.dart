import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../data/models/category_model.dart';

class VideoListScreen extends StatelessWidget {
  final CategoryModel category;

  const VideoListScreen({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: category.color,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 80,
              color: category.color.withOpacity(0.5),
            ),
            SizedBox(height: 20),
            Text(
              "${category.title} Videoları",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: MiniDehaColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Çok yakında burada olacak!",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
