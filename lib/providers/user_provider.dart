import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  User? _currentUser;
  List<User> _approvedUsers = [];
  List<User> _pendingUsers = [];
  List<User> _members = [];
  List<User> _admins = [];
  bool _isLoading = false;

  UserProvider(this._firestoreService);

  User? get currentUser => _currentUser;
  List<User> get approvedUsers => _approvedUsers;
  List<User> get pendingUsers => _pendingUsers;
  List<User> get members => _members;
  List<User> get admins => _admins;
  bool get isLoading => _isLoading;

  void loadUser(String uid) {
    _firestoreService.getUserStream(uid).listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  void loadApprovedUsers() {
    _firestoreService.getApprovedUsersStream().listen((users) {
      _approvedUsers = users;
      notifyListeners();
    });
  }

  void loadPendingUsers() {
    _firestoreService.getPendingUsersStream().listen((users) {
      _pendingUsers = users;
      notifyListeners();
    });
  }

  void loadMembers() {
    _firestoreService.getMembersStream().listen((users) {
      _members = users;
      notifyListeners();
    });
  }

  void loadAdmins() {
    _firestoreService.getAdminsStream().listen((users) {
      _admins = users;
      notifyListeners();
    });
  }

  Future<void> updateUser(User user) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestoreService.updateUser(user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> approveUser(String uid) async {
    await _firestoreService.approveUser(uid);
  }

  Future<void> rejectUser(String uid) async {
    await _firestoreService.rejectUser(uid);
  }

  Future<void> promoteToAdmin(String uid) async {
    await _firestoreService.promoteToAdmin(uid);
  }

  Future<void> removeUser(String uid) async {
    await _firestoreService.removeUser(uid);
  }
}
