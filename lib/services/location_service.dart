import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationService {
  // Key for Places API (New)
  final String apiKey = "AIzaSyCwASHvUScnbpruYUlf9KHLZWj49qu3O8s"; 
  final String sessionToken = const Uuid().v4();

  Future<List<Map<String, dynamic>>> getAutocomplete(String input) async {
    if (input.isEmpty) return [];

    final body = {
      'input': input,
      'sessionToken': sessionToken,
    };

    final uri = Uri.https(
      'places.googleapis.com',
      '/v1/places:autocomplete',
    );

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final suggestions = data['suggestions'] as List? ?? [];
        
        return suggestions.map((s) {
          final prediction = s['placePrediction'];
          return {
            'place_id': prediction['placeId'],
            'description': prediction['text']?['text'] ?? "",
            'structured_formatting': {
              'main_text': prediction['structuredFormat']?['mainText']?['text'] ?? "",
              'secondary_text': prediction['structuredFormat']?['secondaryText']?['text'] ?? "",
            }
          };
        }).toList();
      } else {
        final data = json.decode(response.body);
        throw Exception("Google API Error: ${response.statusCode} - ${data['error']?['message'] ?? 'Check API Console'}");
      }
    } catch (e) {
      debugPrint("LocationService Error: $e");
      rethrow;
    }
  }

  Future<Map<String, String>> getPlaceDetails(String placeId) async {
    final queryParameters = {'sessionToken': sessionToken};
    final uri = Uri.https('places.googleapis.com', '/v1/places/$placeId', queryParameters);

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'addressComponents',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final components = data['addressComponents'] as List? ?? [];
        
        String streetNumber = "";
        String route = "";
        String city = "";
        String postalCode = "";

        for (var component in components) {
          final types = component['types'] as List;
          if (types.contains('street_number')) {
            streetNumber = component['longText'] ?? "";
          } else if (types.contains('route')) {
            route = component['longText'] ?? "";
          } else if (types.contains('locality')) {
            city = component['longText'] ?? "";
          } else if (types.contains('postal_code')) {
            postalCode = component['longText'] ?? "";
          }
        }

        return {
          'street': "$streetNumber $route".trim(),
          'city': city,
          'postalCode': postalCode,
        };
      }
    } catch (e) {
      debugPrint("Place Details Error: $e");
    }
    return {};
  }
}
