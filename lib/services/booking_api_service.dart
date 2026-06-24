import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';

class BookingApiService {
  static const String baseUrl = 'https://prakrutitech.xyz/krish';
  static const int timeoutSeconds = 30;

  static Future<bool> saveBooking(BookingModel booking) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/booking_service.php'),
        body: booking.toMap(),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save booking: $e');
    }
  }

  static Future<List<dynamic>> getBookingsByPhone(String phone) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_booking_by_phone.php?phone=$phone'),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is List) {
          return data;
        } else if (data is Map && data.containsKey('data')) {
          return data['data'] ?? [];
        }
        return [];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  static Future<bool> deleteBooking(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delete_booking.php?id=$id'),
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  static Future<bool> updateBookingStatus(String id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update_booking_status.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id': id,
          'status': status,
        },
      ).timeout(const Duration(seconds: timeoutSeconds));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == true;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }
}
