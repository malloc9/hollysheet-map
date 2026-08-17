import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:holysheet_map/utils/distance_calculator.dart';
import 'package:holysheet_map/models/user.dart';
import 'package:holysheet_map/models/role.dart';

void main() {
  group('GeoCalculator.haversineDistance', () {
    test('returns zero for identical coordinates', () {
      final a = LatLng(40.7128, -74.0060);
      final b = LatLng(40.7128, -74.0060);
      expect(GeoCalculator.haversineDistance(a, b), closeTo(0.0, 0.01));
    });

    test('calculates known distance between NYC and LA', () {
      // NYC and LA are approximately 3,935 km apart
      final nyc = LatLng(40.7128, -74.0060);
      final la = LatLng(34.0522, -118.2437);
      final distance = GeoCalculator.haversineDistance(nyc, la);
      expect(distance, inInclusiveRange(3900, 4000));
    });

    test('is symmetric: distance(a, b) == distance(b, a)', () {
      final a = LatLng(51.5074, -0.1278); // London
      final b = LatLng(48.8566, 2.3522);  // Paris
      expect(
        GeoCalculator.haversineDistance(a, b),
        closeTo(GeoCalculator.haversineDistance(b, a), 0.001),
      );
    });
  });

  group('findNearestAndFurthest', () {
    User buildUser(String uid, String name, double lat, double lng) {
      return User(
        uid: uid,
        userId: uid,
        displayName: name,
        approved: true,
        role: Role.member,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: lat,
        longitude: lng,
      );
    }

    test('finds nearest and furthest from a set of users', () {
      final currentUser = buildUser('current', 'Me', 40.0, -74.0);
      final users = [
        currentUser,
        buildUser('near', 'Near', 40.01, -74.01), // ~1.5 km away
        buildUser('far', 'Far', 34.0, -118.0),     // ~3,930 km away
        buildUser('mid', 'Mid', 41.0, -73.0),       // ~150 km away
      ];

      final result = findNearestAndFurthest(currentUser, users);

      expect(result.nearest?.displayName, 'Near');
      expect(result.furthest?.displayName, 'Far');
      expect(result.nearestDistanceKm, lessThan(result.furthestDistanceKm!));
    });

    test('returns nulls when current user has no coordinates', () {
      final currentUser = User(
        uid: 'current',
        userId: 'current',
        displayName: 'Me',
        approved: true,
        role: Role.member,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: null,
        longitude: null,
      );
      final users = [
        currentUser,
        buildUser('other', 'Other', 40.0, -74.0),
      ];

      final result = findNearestAndFurthest(currentUser, users);

      expect(result.nearest, isNull);
      expect(result.furthest, isNull);
    });

    test('excludes users without coordinates from results', () {
      final currentUser = buildUser('current', 'Me', 40.0, -74.0);
      final noCoordsUser = User(
        uid: 'no-coords',
        userId: 'no-coords',
        displayName: 'NoCoords',
        approved: true,
        role: Role.member,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        latitude: null,
        longitude: null,
      );
      final users = [
        currentUser,
        noCoordsUser,
        buildUser('real', 'Real', 40.01, -74.01),
      ];

      final result = findNearestAndFurthest(currentUser, users);

      expect(result.nearest?.displayName, 'Real');
      expect(result.furthest?.displayName, 'Real');
    });

    test('returns nulls when no other users exist', () {
      final currentUser = buildUser('current', 'Me', 40.0, -74.0);
      final result = findNearestAndFurthest(currentUser, [currentUser]);

      expect(result.nearest, isNull);
      expect(result.furthest, isNull);
    });

    test('excludes the current user by uid even with same coordinates', () {
      final currentUser = buildUser('current', 'Me', 40.0, -74.0);
      final sameCoords = buildUser('same', 'Same', 40.0, -74.0);
      final users = [currentUser, sameCoords];

      final result = findNearestAndFurthest(currentUser, users);

      expect(result.nearest?.uid, 'same');
      expect(result.furthest?.uid, 'same');
    });
  });
}
