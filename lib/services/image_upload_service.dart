import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/firestore_service.dart';

class ImageUploadService {
  final firebase_auth.FirebaseAuth _auth;

  ImageUploadService({
    firebase_auth.FirebaseAuth? auth,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<String> uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final userId = user.uid;

      final FirebaseStorage _storage = FirebaseStorage.instance;
      final FirestoreService _firestoreService = FirestoreService();

      final ref = _storage
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      final uploadTask = ref.putFile(imageFile);
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      await _firestoreService.updateUserImage(userId, downloadUrl);

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String? currentImageUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;

    if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      try {
        final FirebaseStorage _storage = FirebaseStorage.instance;

        final ref = _storage
            .refFromURL(currentImageUrl)
            .child('profile_images')
            .child('$userId.jpg');
        await ref.delete();
      } catch (e) {}
    }

    await FirestoreService().updateUserImage(userId, null);
  }
}