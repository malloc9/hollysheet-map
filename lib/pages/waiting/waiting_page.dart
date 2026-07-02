import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  @override
  void initState() {
    super.initState();
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      Provider.of<UserProvider>(context, listen: false).loadUser(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    if (userProvider.currentUser != null) {
      if (userProvider.currentUser!.approved) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/map');
        });
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your account is awaiting approval.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please contact a clan leader.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
