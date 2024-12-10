import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final VoidCallback onAddTenant;
  final VoidCallback onAutomateReminder;
  final VoidCallback onAddBillPayment;
  final VoidCallback onGenerateReport;

  Sidebar({
    required this.onAddTenant,
    required this.onAutomateReminder,
    required this.onAddBillPayment,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add New Tenant'),
            onTap: onAddTenant,
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Automate Reminder'),
            onTap: onAutomateReminder,
          ),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Add Bill/Payment'),
            onTap: onAddBillPayment,
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Generate Report'),
            onTap: onGenerateReport,
          ),
        ],
      ),
    );
  }
}
