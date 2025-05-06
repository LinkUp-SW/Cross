import 'package:flutter/material.dart';

class PageTypeCard extends StatelessWidget {
  final String imagePath; // Can be asset or network URL
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isAsset;

  const PageTypeCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isAsset = true, // default to asset images
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = isAsset
        ? Image.asset(imagePath, width: 60, height: 60)
        : Image.network(imagePath, width: 60, height: 60);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 300,
          height: 210,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              imageWidget,
              const SizedBox(height: 16),
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
