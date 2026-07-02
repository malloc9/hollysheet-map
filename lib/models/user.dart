import 'package:cloud_firestore/cloud_firestore.dart';
import 'role.dart';

class User {
  final String uid;
  final String userId;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String? country;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? nationality;
  final String? bio;
  final bool approved;
  final Role role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uid,
    required this.userId,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.nationality,
    this.bio,
    required this.approved,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? uid,
    String? userId,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
    String? nationality,
    String? bio,
    bool? approved,
    Role? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      country: country ?? this.country,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nationality: nationality ?? this.nationality,
      bio: bio ?? this.bio,
      approved: approved ?? this.approved,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'userId': userId,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'country': country,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'nationality': nationality,
      'bio': bio,
      'approved': approved,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory User.fromFirestore(Map<String, dynamic> data) {
    return User(
      uid: data['uid'] as String,
      userId: (data['userId'] as String?) ?? (data['discordId'] as String?) ?? data['uid'] as String,
      displayName: (data['displayName'] as String?) ?? (data['discordName'] as String?) ?? 'Anonymous',
      email: data['email'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      country: data['country'] as String?,
      city: data['city'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      nationality: data['nationality'] as String?,
      bio: data['bio'] as String?,
      approved: data['approved'] as bool,
      role: Role.values.firstWhere((r) => r.name == data['role'] as String, orElse: () => Role.pending),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
