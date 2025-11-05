import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../widgets/service_item_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> services = [
    {
      'name': 'HAIR CUT',
      'description': 'Fresh fades, clean cuts.',
      'icon': Icons.content_cut,
      'price': 30,
    },
    {
      'name': 'SHAVING',
      'description': 'Professional beard grooming',
      'icon': Icons.face,
      'price': 25,
    },
    {
      'name': 'CREAMBATH',
      'description': 'Relaxing scalp treatment',
      'icon': Icons.spa,
      'price': 40,
    },
    {
      'name': 'HAIR COLORING',
      'description': 'Premium hair coloring',
      'icon': Icons.palette,
      'price': 50,
    },
  ];

  int? _selectedServiceIndex;

  void _selectService(int index) {
    setState(() => _selectedServiceIndex = index);
    final service = services[index];
    context.push(
      AppRoutes.bookAppointment,
      extra: {
        'serviceName': service['name'],
        'price': service['price'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8E2),
      appBar: AppBar(
        title: const Text('SERVICES'),
        titleTextStyle: const TextStyle(color: Color(0xFFF3E8E2), fontSize: 24),
        backgroundColor: const Color(0xFF233826),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isSelected = index == _selectedServiceIndex;
                    return ServiceItemWidget(
                      name: service['name'] as String,
                      description: service['description'] as String,
                      icon: service['icon'] as IconData,
                      price: service['price'] as int,
                      selected: isSelected,
                      onTap: () => _selectService(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}