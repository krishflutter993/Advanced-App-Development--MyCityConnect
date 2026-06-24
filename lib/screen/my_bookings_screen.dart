import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/booking_api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL:
        "https://myapp-b8bfe-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = "User not logged in";
          _isLoading = false;
        });
        return;
      }

      // 1. Fetch User Profile to get the phone number
      final snapshot = await _database
          .ref()
          .child('users')
          .child(user.uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!snapshot.exists || snapshot.value == null) {
        setState(() {
          _errorMessage = "Profile data not found";
          _isLoading = false;
        });
        return;
      }

      final userData = snapshot.value as Map<dynamic, dynamic>;
      final phone = userData['phone']?.toString();

      if (phone == null || phone.isEmpty) {
        setState(() {
          _errorMessage = "Phone number not found in profile";
          _isLoading = false;
        });
        return;
      }

      // 2. Call API with the phone number
      final data = await BookingApiService.getBookingsByPhone(phone);

      setState(() {
        _bookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load bookings: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteBooking(String id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Booking'),
            content: const Text('Are you sure you want to delete this booking?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await BookingApiService.deleteBooking(id);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (success) {
        setState(() {
          _bookings.removeWhere((booking) => booking['id'].toString() == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete booking')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateStatus(String id, String currentStatus) async {
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Pending'),
                leading: const Icon(Icons.pending_actions, color: Colors.orange),
                onTap: () => Navigator.pop(context, 'Pending'),
              ),
              ListTile(
                title: const Text('Confirmed'),
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                onTap: () => Navigator.pop(context, 'Confirmed'),
              ),
              ListTile(
                title: const Text('Completed'),
                leading: const Icon(Icons.done_all, color: Colors.blue),
                onTap: () => Navigator.pop(context, 'Completed'),
              ),
              ListTile(
                title: const Text('Cancelled'),
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                onTap: () => Navigator.pop(context, 'Cancelled'),
              ),
            ],
          ),
        );
      },
    );

    if (newStatus == null || newStatus == currentStatus) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final success = await BookingApiService.updateBookingStatus(id, newStatus);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (success) {
        // Refresh the list immediately
        await _fetchBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _fetchBookings,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchBookings,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No bookings found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];

          final id = booking['id']?.toString() ?? '';
          final serviceName = booking['service_name']?.toString() ?? 'Unknown Service';
          final bookingDate = booking['booking_date']?.toString() ?? 'N/A';
          final bookingTime = booking['booking_time']?.toString() ?? 'N/A';
          final customerName = booking['customer_name']?.toString() ?? 'N/A';
          final phone = booking['phone']?.toString() ?? 'N/A';
          final address = booking['address']?.toString() ?? 'N/A';
          final status = booking['status']?.toString() ?? 'Pending';

          // Define color based on status
          Color statusColor = Colors.orange;
          if (status.toLowerCase() == 'completed' || status.toLowerCase() == 'confirmed') {
            statusColor = Colors.green;
          } else if (status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected') {
            statusColor = Colors.red;
          }

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER: Service Name & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          serviceName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF667eea),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  
                  // BODY: Details
                  _buildDetailRow(Icons.calendar_month, "Date & Time", "$bookingDate at $bookingTime"),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.person, "Customer", customerName),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.phone, "Phone", phone),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on, "Address", address),

                  const SizedBox(height: 16),
                  
                  // FOOTER: Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _updateStatus(id, status),
                        icon: const Icon(Icons.edit_note, size: 18),
                        label: const Text('Update Status'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => _deleteBooking(id),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
