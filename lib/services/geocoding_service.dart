import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  Future<List<Map<String, dynamic>>> search(String query) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1',
      ),
      headers: {'User-Agent': 'HolySheet Map App'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) {
        return {
          'displayName': item['display_name'],
          'latitude': double.parse(item['lat']),
          'longitude': double.parse(item['lon']),
          'country': item['address']?['country'],
          'city': item['address']?['city'] ?? item['address']?['town'] ?? item['address']?['village'],
        };
      }).toList();
    } else {
      throw Exception('Failed to search location');
    }
  }
}
