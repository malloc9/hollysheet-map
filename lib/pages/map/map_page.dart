import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user.dart';
import '../../models/role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/distance_calculator.dart';
import '../../widgets/avatar.dart';
import '../../widgets/map_marker.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  User? _selectedUser;

  @override
  void initState() {
    super.initState();
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.loadUser(user.uid);
      userProvider.loadApprovedUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = userProvider.currentUser;
    final approvedUsers = userProvider.approvedUsers;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!currentUser.approved) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/waiting');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nearestAndFurthest = findNearestAndFurthest(currentUser, approvedUsers);
    final nearestUid = nearestAndFurthest.nearest?.uid;
    final furthestUid = nearestAndFurthest.furthest?.uid;

    final markers = approvedUsers
        .where((user) => user.latitude != null && user.longitude != null)
        .map((user) => Marker(
          point: LatLng(user.latitude!, user.longitude!),
          width: 120,
          height: 80,
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedUser = user;
            }),
            child: MapMarker(
              avatarUrl: user.avatarUrl,
              email: user.email,
              name: user.displayName,
              highlightColor: user.uid == nearestUid
                  ? Colors.green
                  : user.uid == furthestUid
                      ? Colors.red
                      : null,
            ),
          ),
        ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HolySheet Map'),
        actions: [
          if (currentUser.role == Role.admin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => context.go('/admin'),
            ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => context.go('/rankings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentUser.latitude != null && currentUser.longitude != null
                  ? LatLng(currentUser.latitude!, currentUser.longitude!)
                  : const LatLng(0, 0),
              initialZoom: currentUser.latitude != null && currentUser.longitude != null ? 6 : 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.holysheet.map',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          // Top-left overlay: nearest and furthest neighbors
          if (nearestAndFurthest.nearest != null ||
              nearestAndFurthest.furthest != null)
            Positioned(
              top: 16,
              left: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Neighbors',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (nearestAndFurthest.nearest != null)
                        _buildNeighborRow(
                          context,
                          nearestAndFurthest.nearest!,
                          nearestAndFurthest.nearestDistanceKm!,
                          Colors.green,
                        ),
                      if (nearestAndFurthest.furthest != null)
                        _buildNeighborRow(
                          context,
                          nearestAndFurthest.furthest!,
                          nearestAndFurthest.furthestDistanceKm!,
                          Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_selectedUser != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Avatar(avatarUrl: _selectedUser!.avatarUrl, email: _selectedUser!.email, size: 64),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedUser!.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (_selectedUser!.country != null)
                                  Text(
                                    '${_selectedUser!.city != null ? '${_selectedUser!.city!}, ' : ''}${_selectedUser!.country!}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                if (_selectedUser!.nationality != null)
                                  Text(
                                    'Nationality: ${_selectedUser!.nationality!}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() {
                              _selectedUser = null;
                            }),
                          ),
                        ],
                      ),
                      if (_selectedUser!.bio != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _selectedUser!.bio!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNeighborRow(
    BuildContext context,
    User user,
    double distanceKm,
    Color highlightColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: highlightColor.withValues(alpha: 0.2),
          child: Avatar(
            avatarUrl: user.avatarUrl,
            email: user.email,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(width: 8),
        Text(
          '${distanceKm.toStringAsFixed(1)} km',
          style: TextStyle(
            fontSize: 12,
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
