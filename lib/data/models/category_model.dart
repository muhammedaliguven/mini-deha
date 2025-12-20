import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String title;
  final IconData icon; // Placeholder for asset path or IconData
  final Color color;
  final String description;

  CategoryModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}
