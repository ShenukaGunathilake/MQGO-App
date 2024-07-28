import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFFF60C3B),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("images/home_icon.png"),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("images/explore_icon.png"),
          ),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("images/services_icon.png"),
          ),
          label: 'Services',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("images/cart_icon.png"),
          ),
          label: 'Your Cart',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage("images/profile_icon.png"),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
