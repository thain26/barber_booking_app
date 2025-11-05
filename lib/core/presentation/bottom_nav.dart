import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatefulWidget {
  final int initialIndex;
  const BottomNav({super.key, required this.initialIndex});
  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int currentIndex;
  final Color _darkGreen = const Color(0xFF233826);
  final Color _softCream = const Color(0xFFF3E8E2);

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: _darkGreen,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 0),
              _buildNavItem(Icons.calendar_today, 1),
              _buildNavItem(Icons.person_outline, 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final bool isSelected = currentIndex == index;
    return IconButton(
      onPressed: () {
        setState(() {
          currentIndex = index;
        });
        _onItemTapped(context, index);
      },
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? _softCream : null,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? _darkGreen : _softCream.withOpacity(0.95),
        ),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/appointments');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }
}