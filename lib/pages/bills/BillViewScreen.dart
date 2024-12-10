import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/bills/biils_detailsScreen.dart';
import 'package:landify/pages/bills/bills_model.dart';
import 'package:landify/pages/reminder_automation.dart';
import 'package:landify/pages/tenants_screen.dart';

class BillViewScreen extends StatelessWidget {
  final Bill? bill;
  final String tenantName; // Accept tenantName

  BillViewScreen({this.bill, required this.tenantName});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Kshs ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  Future<void> _deleteBill(BuildContext context) async {
    if (bill == null) return;

    // Ask for confirmation before deleting
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete this bill data? This will set all fields to zero.'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && bill != null) {
      try {
        await FirebaseFirestore.instance
            .collection('bills')
            .doc(bill!.id)
            .update({
          'totalAmount': 0.0,
          'balanceDue': 0.0,
          'dueDate': DateTime.now(),
          'rentAmount': 0.0,
          'waterUnits': 0.0,
          'powerUnits': 0.0,
          'powerAmount': 0.0,
          'utilitiesAmount': 0.0,
          'lateFees': 0.0,
          'otherFees': 0.0,
          'amountPaid': 0.0,
          'isPaid': false,
        });

        Navigator.pop(context, true); // Indicate the bill was deleted
      } catch (error) {
        print("Error deleting bill: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bill == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text(
            'Error: Bill data is not available.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Bill Details for $tenantName'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildBillDetailCard(
                'Total Amount', formatCurrency(bill!.totalAmount)),
            _buildBillDetailCard(
                'Balance Due', formatCurrency(bill!.balanceDue)),
            _buildBillDetailCard(
                'Due Date', DateFormat('MM/dd/yyyy').format(bill!.dueDate)),
            _buildBillDetailCard(
                'Rent Amount', formatCurrency(bill!.rentAmount)),
            if (bill!.waterUnits > 0)
              _buildBillDetailCard('Water Units',
                  '${bill!.waterUnits} units (Price per unit: ${formatCurrency(bill!.pricePerWaterUnit)})'),
            if (bill!.powerUnits > 0)
              _buildBillDetailCard('Power Units',
                  '${bill!.powerUnits} units (Price per unit: ${formatCurrency(bill!.pricePerPowerUnit)})'),
            _buildBillDetailCard(
                'Utilities Amount', formatCurrency(bill!.utilitiesAmount)),
            _buildBillDetailCard('Late Fees', formatCurrency(bill!.lateFees)),
            _buildBillDetailCard('Other Fees', formatCurrency(bill!.otherFees)),
            _buildBillDetailCard(
                'Amount Paid', formatCurrency(bill!.amountPaid)),
            _buildBillDetailCard(
                'Bill Completed?', bill!.isPaid ? 'Yes' : 'No'),

            // Reminder Section
            SizedBox(height: 20),
            _buildReminderSection(context),
            SizedBox(height: 20),

            // Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Ensure tenant data is available
                    if (bill != null) {
                      FirebaseFirestore.instance
                          .collection('tenants')
                          .doc(bill!.tenantId)
                          .get()
                          .then((tenantDoc) {
                        if (tenantDoc.exists) {
                          Tenant tenant = Tenant.fromFirestore(tenantDoc);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillDetailsScreen(
                                tenant: tenant, // Pass the tenant
                                bill: bill, // Pass the bill
                              ),
                            ),
                          );
                        }
                      });
                    }
                  },
                  child: Text('Edit', style: TextStyle(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton(
                  onPressed: () => _deleteBill(context),
                  child: Text('Delete', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    bool isReminderSet =
        bill != null && bill!.reminderSet != null && bill!.reminderSet!;

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder Status',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  isReminderSet
                      ? 'Reminder Set for Due Date'
                      : 'No Reminder Set',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: isReminderSet ? Colors.green : Colors.red,
                  ),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: bill != null
                      ? () {
                          // Navigate to Reminder Automation Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderAutomation(),
                            ),
                          );
                        }
                      : null,
                  child: Text('Set Reminder',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            if (isReminderSet)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Reminder has been sent for this bill. Please ensure you follow up.',
                  style: TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper method for bill detail card layout
  Widget _buildBillDetailCard(String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
