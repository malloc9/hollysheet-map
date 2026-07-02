import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../providers/map_provider.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;
  bool _error = false;

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCVtHE2Eeed5luH9ZK_bINkU2GoVeLGW70',
          authDomain: 'hollysheet-map.firebaseapp.com',
          projectId: 'hollysheet-map',
          messagingSenderId: '636548357021',
          appId: '1:636548357021:web:223287659c9b2b2784ad74',
        ),
      );
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Failed to initialize Firebase',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Please follow these steps to set up Firebase:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. Create a Firebase project at https://console.firebase.google.com/'),
                        Text('2. Enable Email/Password authentication in Firebase Console'),
                        Text('3. Enable Firestore Database'),
                        Text('4. Add a web app to your Firebase project'),
                        Text('5. Copy the Firebase config and replace the values in lib/app/app.dart'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (context) => AuthProvider(context.read<AuthService>())),
        ChangeNotifierProvider(create: (context) => UserProvider(context.read<FirestoreService>())),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MaterialApp.router(
        title: 'HolySheet Map',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
