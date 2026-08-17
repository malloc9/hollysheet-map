import 'dart:async';
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
  String? _loadUserError;

  UserProvider(this._firestoreService);

  User? get currentUser => _currentUser;
  List<User> get approvedUsers => _approvedUsers;
  List<User> get pendingUsers => _pendingUsers;
  List<User> get members => _members;
  List<User> get admins => _admins;
  bool get isLoading => _isLoading;
  String? get loadUserError => _loadUserError;

  StreamSubscription<User?>? _userSubscription;

  void loadUser(String uid) {
    _loadUserError = null;
    _userSubscription?.cancel();
    _userSubscription = _firestoreService.getUserStream(uid).listen(
      (user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (e) {
        if (kDebugMode) {
          print('Error loading user from Firestore: $e');
        }
        _loadUserError = e.toString();
        notifyListeners();
      },
    );
  }

  void _listenToList(
    Stream<List<User>> stream,
    void Function(List<User>) setter,
  ) {
    stream.listen(setter);
  }

  void loadApprovedUsers() {
    _listenToList(
      _firestoreService.getApprovedUsersStream(),
      (users) {
        _approvedUsers = users;
        notifyListeners();
      },
    );
  }

  void loadPendingUsers() {
    _listenToList(
      _firestoreService.getPendingUsersStream(),
      (users) {
        _pendingUsers = users;
        notifyListeners();
      },
    );
  }

  void loadMembers() {
    _listenToList(
      _firestoreService.getMembersStream(),
      (users) {
        _members = users;
        notifyListeners();
      },
    );
  }

  void loadAdmins() {
    _listenToList(
      _firestoreService.getAdminsStream(),
      (users) {
        _admins = users;
        notifyListeners();
      },
    );
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

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
