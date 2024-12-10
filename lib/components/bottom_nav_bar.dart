import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  final ValueChanged<int> onTabSelected;
  final int selectedIndex;
  final List<Widget> pages;

  BottomNavBar({
    required this.onTabSelected,
    required this.selectedIndex,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize PersistentTabController properly
    PersistentTabController _controller = PersistentTabController(initialIndex: selectedIndex);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30.0),
        topRight: Radius.circular(30.0),
      ),
      child: PersistentTabView(
        context,
        controller: _controller,  // Pass the controller
        screens: pages,  // List of screens
        items: [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.home),
            title: "Home",
            activeColorPrimary: Colors.white,
            inactiveColorPrimary: Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.payment),
            title: "Bills",
            activeColorPrimary: Colors.white,
            inactiveColorPrimary: Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.assignment),
            title: "Reports",
            activeColorPrimary: Colors.white,
            inactiveColorPrimary: Colors.black,
          ),
          PersistentBottomNavBarItem(
            icon: Icon(Icons.people),
            title: "Tenants",
            activeColorPrimary: Colors.white,
            inactiveColorPrimary: Colors.black,
          ),
        ],
        navBarStyle: NavBarStyle.style1, // Choose the navbar style
        onItemSelected: onTabSelected, // Pass the onTabSelected callback
        backgroundColor: Colors.grey, // Set the background color here
      ),
    );
  }
}
