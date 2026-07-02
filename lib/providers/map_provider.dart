import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class MapProvider with ChangeNotifier {
  LatLng _center = const LatLng(0, 0);
  double _zoom = 2.0;

  LatLng get center => _center;
  double get zoom => _zoom;

  void updateCenter(LatLng center) {
    _center = center;
    notifyListeners();
  }

  void updateZoom(double zoom) {
    _zoom = zoom;
    notifyListeners();
  }

  void updatePosition(LatLng center, double zoom) {
    _center = center;
    _zoom = zoom;
    notifyListeners();
  }
}
