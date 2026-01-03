import 'dart:ui';
import 'package:flutter/material.dart';

// SHARED GLASS CARD BUILDER
Widget buildGlassCard({required Widget child, EdgeInsets? margin}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: margin ?? const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: child,
      ),
    ),
  );
}

class ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget Function({required Widget child, EdgeInsets? margin})
  glassWrapper;

  const ToolCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glassWrapper,
  });

  @override
  Widget build(BuildContext context) {
    return glassWrapper(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent[700], size: 28),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final Widget Function({required Widget child, EdgeInsets? margin})
  glassWrapper;

  const FeaturedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.glassWrapper,
  });

  @override
  Widget build(BuildContext context) {
    return glassWrapper(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          Text(
            duration,
            style: TextStyle(
              color: Colors.blueAccent[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
