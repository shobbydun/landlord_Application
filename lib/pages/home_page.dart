import 'package:flutter/material.dart';
import 'package:landify/components/bottom_nav_bar.dart';
import 'package:landify/pages/bills/bill_screen.dart';
import 'package:landify/pages/dashboard_page.dart';
import 'package:landify/pages/reports_screen.dart';
import 'package:landify/pages/tenants_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Pages for the bottom navigation
  final List<Widget> _pages = [
    DashboardPage(),
    BillsScreen(),
    ReportsScreen(),
    TenantsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavBar(
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index; // Update selected index
          });
        },
        selectedIndex: _selectedIndex, // Pass selected index to BottomNavBar
        pages: _pages, // Pass pages to BottomNavBar
      ),
    );
  }
}
