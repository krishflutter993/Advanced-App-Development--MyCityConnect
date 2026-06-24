import 'dart:convert';

class BookingModel {
  final String serviceId;
  final String serviceName;
  final String customerName;
  final String phone;
  final String email;
  final String address;
  final String bookingDate;
  final String bookingTime;
  final String? notes;

  BookingModel({
    required this.serviceId,
    required this.serviceName,
    required this.customerName,
    required this.phone,
    required this.email,
    required this.address,
    required this.bookingDate,
    required this.bookingTime,
    this.notes,
  });

  Map<String, String> toMap() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'customer_name': customerName,
      'phone': phone,
      'email': email,
      'address': address,
      'booking_date': bookingDate,
      'booking_time': bookingTime,
      if (notes != null && notes!.isNotEmpty) 'notes': notes!,
    };
  }

  String toJson() => json.encode(toMap());
}
