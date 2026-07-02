import 'package:flutter/material.dart';
import 'avatar.dart';

class MapMarker extends StatelessWidget {
  final String? avatarUrl;
  final String? email;
  final String name;

  const MapMarker({super.key, this.avatarUrl, this.email, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Avatar(avatarUrl: avatarUrl, email: email, size: 40),
      ],
    );
  }
}
