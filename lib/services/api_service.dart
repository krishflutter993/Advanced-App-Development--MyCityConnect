import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ApiService {
  static const String baseUrl = 'https://prakrutitech.xyz/krish';
  static const int timeoutSeconds = 30;

  // Get all services
  static Future<List<ServiceModel>> fetchServices() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/get_all_services.php'),
          )
          .timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((json) => ServiceModel.fromJson(json)).toList();
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'API returned status false');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  // Get services by category
  static Future<List<ServiceModel>> fetchServicesByCategory(
      String category) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_category_services.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'category': category},
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == true) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((json) => ServiceModel.fromJson(json)).toList();
        } else {
          throw Exception(
              jsonResponse['message'] ?? 'API returned status false');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load category services: $e');
    }
  }

  // ✅ NEW: Upload Image API
  static Future<bool> uploadImage(String imagePath, String serviceId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload_image.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // API field name - confirm karein
          imagePath,
        ),
      );

      request.fields['service_id'] = serviceId;

      var response = await request.send().timeout(
            const Duration(seconds: 60),
          );

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return jsonResponse['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
