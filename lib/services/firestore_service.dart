import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/role.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Stream<User?> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return User.fromFirestore(snapshot.data()!);
      }
      return null;
    });
  }

  Future<User?> getUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (snapshot.exists) {
      return User.fromFirestore(snapshot.data()!);
    }
    return null;
  }

  Stream<List<User>> getApprovedUsersStream() {
    return _firestore
        .collection('users')
        .where('approved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => User.fromFirestore(doc.data())).toList());
  }

  Stream<List<User>> getPendingUsersStream() {
    return _firestore
        .collection('users')
        .where('approved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => User.fromFirestore(doc.data())).toList());
  }

  Stream<List<User>> getMembersStream() {
    return _firestore
        .collection('users')
        .where('approved', isEqualTo: true)
        .where('role', isEqualTo: Role.member.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => User.fromFirestore(doc.data())).toList());
  }

  Stream<List<User>> getAdminsStream() {
    return _firestore
        .collection('users')
        .where('approved', isEqualTo: true)
        .where('role', isEqualTo: Role.admin.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => User.fromFirestore(doc.data())).toList());
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
  }

  Future<void> updateUserImage(String uid, String? avatarUrl) async {
    await _firestore.collection('users').doc(uid).update({
      'avatarUrl': avatarUrl,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'approved': true,
      'role': Role.member.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> rejectUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<void> promoteToAdmin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'role': Role.admin.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> removeUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
