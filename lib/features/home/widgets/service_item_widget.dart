import 'package:flutter/material.dart';

class ServiceItemWidget extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final int price;
  final bool selected;
  final VoidCallback? onTap;

  const ServiceItemWidget({
    super.key,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: selected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF233826) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF233826),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(description, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Text('\$$price', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF233826))),
            ],
          ),
        ),
      ),
    );
  }
}