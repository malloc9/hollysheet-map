import 'package:flutter/material.dart';
import '../services/gravatar_service.dart';

class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String? email;
  final double size;

  const Avatar({super.key, this.avatarUrl, this.email, this.size = 48.0});

  @override
  Widget build(BuildContext context) {
    String? displayUrl = avatarUrl;
    if (displayUrl == null && email != null) {
      displayUrl = GravatarService.generateUrl(email!);
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: Colors.grey[300],
        child: displayUrl != null
            ? Image.network(
                displayUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]);
                },
              )
            : Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]),
      ),
    );
  }
}
