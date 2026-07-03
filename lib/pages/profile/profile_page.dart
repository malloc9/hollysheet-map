import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../services/geocoding_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/avatar.dart';
import '../../widgets/profile_image_cropper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _geocodingService = GeocodingService();
  final _profileImageCropper = ProfileImageCropper();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isUploadingImage = false;
  Map<String, dynamic>? _selectedLocation;
  String? _userEmail;
  UserProvider? _userProvider;
  final ImageUploadService _imageUploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userEmail = user.email;
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      _userProvider!.loadUser(user.uid);
      
      // Add listener to update controllers whenever user changes
      _userProvider!.addListener(_onUserChanged);
      
      // Update controllers immediately if user is already loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_userProvider!.currentUser != null) {
          _updateControllers();
        }
      });
    }
  }
  
  void _onUserChanged() {
    if (_userProvider!.currentUser != null) {
      _updateControllers();
    }
  }
  
  void _updateControllers() {
    final currentUser = _userProvider!.currentUser;
    if (currentUser != null) {
      _nationalityController.text = currentUser.nationality ?? '';
      _bioController.text = currentUser.bio ?? '';
      _avatarUrlController.text = currentUser.avatarUrl ?? '';
    }
  }

  Future<void> _searchLocations() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final results = await _geocodingService.search(_searchController.text);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _selectLocation(Map<String, dynamic> location) async {
    setState(() {
      _selectedLocation = location;
      _searchController.text = location['displayName'];
      _searchResults = [];
    });
  }

    Future<void> _uploadAvatar() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userId = user.uid;

      final croppedFile = await _profileImageCropper.cropImage(isCircle: true);

      if (croppedFile == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Uploading profile picture...'),
            ],
          ),
        ),
      );

      final downloadUrl = await _imageUploadService.uploadImage(
        File(croppedFile.path),
        userId,
      );

      await Navigator.of(context).pop();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      User updatedUser = userProvider.currentUser!.copyWith(
        avatarUrl: downloadUrl,
        updatedAt: DateTime.now(),
      );

      await userProvider.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      await Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    User updatedUser = currentUser.copyWith(
      nationality: _nationalityController.text.isEmpty ? null : _nationalityController.text,
      bio: _bioController.text.isEmpty ? null : _bioController.text,
      updatedAt: DateTime.now(),
    );

    if (_selectedLocation != null) {
      updatedUser = updatedUser.copyWith(
        country: _selectedLocation!['country'],
        city: _selectedLocation!['city'],
        latitude: _selectedLocation!['latitude'],
        longitude: _selectedLocation!['longitude'],
      );
    }

    await userProvider.updateUser(updatedUser);
    if (mounted) {
      context.go('/map');
    }
  }

    @override
    Widget build(BuildContext context) {
      final userProvider = Provider.of<UserProvider>(context);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/map'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Avatar(avatarUrl: currentUser.avatarUrl, email: _userEmail, size: 96),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _isUploadingImage ? null : _uploadAvatar,
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            const SizedBox(height: 8),
            if (_userEmail != null)
              Text(
                'Gravatar linked to $_userEmail',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search city or country',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocations,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchLocations(),
            ),
            const SizedBox(height: 16),
            if (_isSearching) const Center(child: CircularProgressIndicator()),
            if (_searchResults.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return ListTile(
                      title: Text(location['displayName']),
                      onTap: () => _selectLocation(location),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _nationalityController,
              decoration: const InputDecoration(
                labelText: 'Nationality (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio (optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userProvider?.removeListener(_onUserChanged);
    _searchController.dispose();
    _nationalityController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
