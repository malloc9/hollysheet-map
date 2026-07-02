import 'package:go_router/go_router.dart';
import '../pages/login/login_page.dart';
import '../pages/waiting/waiting_page.dart';
import '../pages/map/map_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/admin/admin_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/waiting',
      name: 'waiting',
      builder: (context, state) => const WaitingPage(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const MapPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminPage(),
    ),
  ],
);
