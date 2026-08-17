import 'package:flutter/material.dart';
import 'avatar.dart';

class MapMarker extends StatelessWidget {
  final String? avatarUrl;
  final String? email;
  final String name;

  /// Optional ring color around the avatar to highlight this marker.
  /// Pass [Colors.green] for "nearest" or [Colors.red] for "furthest".
  /// When null, no ring is drawn.
  final Color? highlightColor;

  const MapMarker({
    super.key,
    this.avatarUrl,
    this.email,
    required this.name,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Avatar(avatarUrl: avatarUrl, email: email, size: 40);

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
        if (highlightColor != null)
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: highlightColor,
            ),
            child: avatar,
          )
        else
          avatar,
      ],
    );
  }
}
