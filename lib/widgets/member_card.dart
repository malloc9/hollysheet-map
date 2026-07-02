import 'package:flutter/material.dart';
import '../models/user.dart';
import 'avatar.dart';

class MemberCard extends StatelessWidget {
  final User user;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;
  final VoidCallback? onPromote;

  const MemberCard({
    super.key,
    required this.user,
    this.onApprove,
    this.onReject,
    this.onRemove,
    this.onPromote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
              Avatar(avatarUrl: user.avatarUrl, email: user.email),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (user.country != null)
                    Text(
                    '${user.city != null ? '${user.city!}, ' : ''}${user.country!}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (user.nationality != null)
                    Text(
                    'Nationality: ${user.nationality!}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (user.bio != null)
                    Text(
                    user.bio!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                ),
              ),
            ],
            ),
            const SizedBox(height: 12),
            if (onApprove != null || onReject != null || onRemove != null || onPromote != null)
              Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onApprove != null)
                  ElevatedButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                if (onReject != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                ],
                if (onRemove != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onRemove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Remove'),
                  ),
                ],
                if (onPromote != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onPromote,
                    child: const Text('Make Admin'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
