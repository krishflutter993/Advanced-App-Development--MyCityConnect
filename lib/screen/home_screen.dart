import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/service_model.dart';
import '../services/api_service.dart';
import '../widgets/drawer_widget.dart';
import 'service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  /// 🔥 USER NAME (FROM FIREBASE DB)
  String userName = "User";
  bool isLoadingName = true;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  /// ✅ Firebase DB (IMPORTANT REGION FIX)
  final db = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL:
        "https://myapp-b8bfe-default-rtdb.asia-southeast1.firebasedatabase.app",
  );

  final List<String> _categories = [
    'All',
    'Salon',
    'Plumbing',
    'Tutor',
    'Electrician',
    'Repair',
    'Fitness'
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadUserName(); // 🔥 LOAD NAME
  }

  /// 🔥 LOAD USER NAME FROM FIREBASE
  Future<void> _loadUserName() async {
    if (_currentUser == null) return;

    final ref = db.ref("users/${_currentUser!.uid}");

    ref.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data != null) {
        final map = Map<String, dynamic>.from(data as Map);

        setState(() {
          userName = map['name'] ?? "User";
          isLoadingName = false;
        });
      }
    });
  }

  /// 🔥 LOAD SERVICES
  Future<void> _loadServices({String? category}) async {
    setState(() => _isLoading = true);

    try {
      List<ServiceModel> services;

      if (category == null || category == 'All') {
        services = await ApiService.fetchServices();
      } else {
        services = await ApiService.fetchServicesByCategory(category);
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading services: $e");
    }
  }

  /// 🔍 FILTER
  List<ServiceModel> get _filteredServices {
    return _services.where((service) {
      final matchesCategory =
          _selectedCategory == 'All' || service.category == _selectedCategory;

      final matchesSearch = _searchQuery.isEmpty ||
          service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.category.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyCityConnect'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),

      /// 🔥 DRAWER
      drawer: DrawerWidget(
        userName: userName,
        userEmail: _currentUser?.email ?? '',
      ),

      body: Column(
        children: [
          /// 🔥 HEADER
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 NAME SHOW HERE
                Text(
                  isLoadingName ? 'Hello...' : 'Hello, $userName!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Find Services in Your City',
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 15),

                /// 🔍 SEARCH
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search services...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔥 CATEGORY FILTER
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _loadServices(category: category);
                    },
                    selectedColor: const Color(0xFF667eea),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔥 SERVICES GRID
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServices.isEmpty
                    ? const Center(child: Text('No services available'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredServices.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return _buildServiceCard(service);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  /// 🔥 SERVICE CARD
  Widget _buildServiceCard(ServiceModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                service.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Center(child: Icon(Icons.image)),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    service.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(
                        service.rating.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
