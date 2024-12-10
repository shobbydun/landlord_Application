import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String value;
  final IconData icon;

  const DashboardTile({
    required this.backgroundColor,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),  // Reduced radius for a smaller corner radius
      ),
      padding: EdgeInsets.all(16),  // Reduced padding for smaller space around content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Colors.white),  // Reduced icon size
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,  // Reduced font size for the value text
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),  // Reduced space between value and title
          Text(
            title,
            style: TextStyle(
              fontSize: 14,  // Reduced font size for the title text
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}


class LargeDashboardTile extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final List<Map<String, dynamic>> data;

  const LargeDashboardTile({
    required this.backgroundColor,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Column(
            children: data.map((item) {
              return Row(
                children: [
                  Icon(item['icon'], size: 24, color: Colors.black54),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['label'],
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  Text(
                    item['value'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}