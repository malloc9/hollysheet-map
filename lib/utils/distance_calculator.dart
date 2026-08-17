import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import '../models/user.dart';

/// Pure utility for geospatial distance calculations and neighbor discovery.
class GeoCalculator {
  /// Calculates the great-circle distance between two points on Earth
  /// using the Haversine formula.
  ///
  /// Returns the distance in kilometers.
  static double haversineDistance(LatLng a, LatLng b) {
    const double earthRadiusKm = 6371.0;

    final phi1 = _degreesToRadians(a.latitude);
    final phi2 = _degreesToRadians(b.latitude);
    final deltaPhi = _degreesToRadians(b.latitude - a.latitude);
    final deltaLambda = _degreesToRadians(b.longitude - a.longitude);

    final sinDeltaPhiHalf = math.sin(deltaPhi / 2);
    final sinDeltaLambdaHalf = math.sin(deltaLambda / 2);

    final haversineA =
        sinDeltaPhiHalf * sinDeltaPhiHalf +
        math.cos(phi1) * math.cos(phi2) * sinDeltaLambdaHalf * sinDeltaLambdaHalf;
    final c = 2 * math.atan2(math.sqrt(haversineA), math.sqrt(1 - haversineA));

    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}

/// Result of nearest/furthest calculation.
class NearestAndFurthest {
  final User? nearest;
  final User? furthest;
  final double? nearestDistanceKm;
  final double? furthestDistanceKm;

  NearestAndFurthest({
    this.nearest,
    this.furthest,
    this.nearestDistanceKm,
    this.furthestDistanceKm,
  });
}

/// Finds the nearest and furthest user to [currentUser] from the given list.
///
/// Users without coordinates are excluded. The [currentUser] itself is
/// excluded from the results. Returns null for nearest/furthest if no
/// other users with coordinates are found.
NearestAndFurthest findNearestAndFurthest(
  User? currentUser,
  List<User> users,
) {
  final currentLat = currentUser?.latitude;
  final currentLng = currentUser?.longitude;

  if (currentLat == null || currentLng == null) {
    return NearestAndFurthest();
  }

  final currentPoint = LatLng(currentLat, currentLng);
  final others = users
      .where((u) => u.uid != currentUser?.uid)
      .where((u) => u.latitude != null && u.longitude != null)
      .toList();

  if (others.isEmpty) {
    return NearestAndFurthest();
  }

  User? nearestUser;
  User? furthestUser;
  double? nearestDist;
  double? furthestDist;

  for (final user in others) {
    final point = LatLng(user.latitude!, user.longitude!);
    final dist = GeoCalculator.haversineDistance(currentPoint, point);

    if (nearestDist == null || dist < nearestDist) {
      nearestDist = dist;
      nearestUser = user;
    }
    if (furthestDist == null || dist > furthestDist) {
      furthestDist = dist;
      furthestUser = user;
    }
  }

  return NearestAndFurthest(
    nearest: nearestUser,
    furthest: furthestUser,
    nearestDistanceKm: nearestDist,
    furthestDistanceKm: furthestDist,
  );
}
