import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/nationality_analyzer.dart';

/// Displays a ranked list of nationalities by how many users share them.
///
/// Users without a nationality are grouped under "Not specified".
/// Data comes from the real-time [UserProvider.approvedUsers] stream —
/// no additional Firestore queries are needed.
class RankingsPage extends StatelessWidget {
  const RankingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nationality Rankings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/map'),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final users = userProvider.approvedUsers;

          if (users.isEmpty) {
            return const Center(child: Text('No users to display yet.'));
          }

          final rankings = groupByNationality(users);
          final totalUsers = users.length;

          return ListView.separated(
            itemCount: rankings.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final rank = rankings[index];
              final percentage =
                  (rank.count / totalUsers * 100).toStringAsFixed(1);
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(rank.nationality),
                subtitle: Text('$percentage% of users'),
                trailing: Chip(
                  label: Text(
                    '${rank.count}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: _rankColor(index),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _rankColor(int index) {
    return switch (index) {
      0 => Colors.amber,
      1 => Colors.grey,
      2 => Colors.orange,
      _ => Colors.blue,
    };
  }
}
