import 'package:flutter/material.dart';

class FeatureModel {
  final String featureId;
  final IconData icon;
  final String title;
  final String description;

  FeatureModel({
    required this.featureId,
    required this.icon,
    required this.title,
    required this.description,
  });
}
