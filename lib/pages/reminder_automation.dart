import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/bills/bills_model.dart';
import 'package:landify/pages/tenants_screen.dart';

class ReminderAutomation extends StatefulWidget {
  @override
  _ReminderAutomationScreenState createState() =>
      _ReminderAutomationScreenState();
}

class _ReminderAutomationScreenState extends State<ReminderAutomation> {
  bool isLoading = true;
  List<Tenant> tenants = [];
  Map<String, Bill?> tenantBills = {}; // Store bills for tenants
  TextEditingController _customMessageController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  bool filterByDueDate = false;
  bool filterByHighestDebt = false;
  bool messageEntered = false; // Flag to track if a custom message is entered
  String customMessage = '';
  List<Tenant> selectedTenants = [];

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  // Helper method to format currency
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Kshs ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Function to fetch tenants from Firestore
  void _loadTenants() async {
    try {
      QuerySnapshot tenantSnapshot =
          await FirebaseFirestore.instance.collection('tenants').get();
      if (mounted) {
        setState(() {
          tenants = tenantSnapshot.docs
              .map((doc) => Tenant.fromFirestore(doc))
              .toList();
          isLoading = false;
        });
      }

      // Fetch bills for each tenant in parallel after loading tenants
      for (var tenant in tenants) {
        await _fetchBillForTenant(tenant);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error loading tenants: $e");
    }
  }

  // Function to fetch the bill for a tenant
  Future<void> _fetchBillForTenant(Tenant tenant) async {
    try {
      final billSnapshot = await FirebaseFirestore.instance
          .collection('bills')
          .where('tenantId', isEqualTo: tenant.id)
          .limit(1)
          .get();

      if (billSnapshot.docs.isNotEmpty) {
        tenantBills[tenant.id] = Bill.fromFirestore(billSnapshot.docs.first);
      } else {
        tenantBills[tenant.id] = null;
      }
    } catch (e) {
      print("Error fetching bill for tenant: $e");
      tenantBills[tenant.id] = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  // Sorting tenants by debt (highest debt first) and due date (nearest first)
  List<Tenant> _sortedTenants() {
    if (filterByDueDate) {
      tenants.sort((a, b) {
        var billA = tenantBills[a.id];
        var billB = tenantBills[b.id];
        if (billA == null || billB == null) return 0;
        return billA.dueDate.compareTo(billB.dueDate); // Nearest due date first
      });
    } else if (filterByHighestDebt) {
      tenants.sort((a, b) {
        var billA = tenantBills[a.id];
        var billB = tenantBills[b.id];
        if (billA == null || billB == null) return 0;
        return billB.balanceDue
            .compareTo(billA.balanceDue); // Highest debt first
      });
    }
    return tenants;
  }

  // Function to select tenants for sending messages
  void _selectTenantsToSendMessage() async {
    selectedTenants.clear(); // Reset selected tenants before showing dialog

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Tenants'),
          content: SingleChildScrollView(
            child: Column(
              children: tenants.map((tenant) {
                return CheckboxListTile(
                  title: Text(tenant.name),
                  value: selectedTenants
                      .contains(tenant), // Reflect selected state
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedTenants.add(tenant);
                      } else {
                        selectedTenants.remove(tenant);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Send the reminder to selected tenants
                for (var tenant in selectedTenants) {
                  var bill = tenantBills[tenant.id];
                  if (bill != null && (bill.reminderSet ?? false) == false) {
                    _sendReminder(tenant, bill, customMessage: customMessage);
                  }
                }
              },
              child: Text('Send'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to send reminders
  void _sendReminder(Tenant tenant, Bill bill, {String? customMessage}) async {
    String message = customMessage ??
        'Dear ${tenant.name}, your rent of ${formatCurrency(bill.totalAmount)} is due on ${DateFormat('MM/dd/yyyy').format(bill.dueDate)}. Please pay before the due date.';

    try {
      print('Sending message to ${tenant.name}: $message');

      FirebaseFirestore.instance
          .collection('bills')
          .doc(bill.id)
          .update({'reminderSet': true});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder sent to ${tenant.name}')),
      );
    } catch (e) {
      print("Error sending reminder: $e");
    }

    // Clear custom message after sending
    _customMessageController.clear();
    setState(() {
      customMessage = '';
      messageEntered = false;
    });
  }

  // Function to send reminders to all tenants after confirmation
  void _sendAllReminders() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sending Reminders'),
          content:
              Text('Are you sure you want to send reminders to all tenants?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                for (var tenant in tenants) {
                  var bill = tenantBills[tenant.id];
                  if (bill != null && (bill.reminderSet ?? false) == false) {
                    _sendReminder(tenant, bill, customMessage: customMessage);
                  }
                }
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // Widget to build tenant's bill details
  Widget _buildTenantBillTile(Tenant tenant, Bill? bill) {
    if (bill == null) {
      return ListTile(
        title: Text(tenant.name),
        subtitle: Text('No bill available'),
        onTap: () {
          // Optionally, show bill details or perform actions on tap
        },
      );
    }

    double totalAmountDue = bill.totalAmount;
    double balanceDue = bill.balanceDue;

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: () {
            // Show detailed bill information or allow actions like marking as paid
            _showBillDetailsDialog(tenant, bill);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text('Total Amount Due: ${formatCurrency(totalAmountDue)}'),
                    Text('Balance Due: ${formatCurrency(balanceDue)}'),
                    Text(
                        'Due Date: ${DateFormat('MM/dd/yyyy').format(bill.dueDate)}'),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Ask for confirmation before sending reminder
                  _confirmSendReminder(tenant, bill);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirm reminder before sending
  void _confirmSendReminder(Tenant tenant, Bill bill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sending Reminder'),
          content: Text(
              'Are you sure you want to send a reminder to ${tenant.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _sendReminder(tenant, bill, customMessage: customMessage);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // Show bill details dialog
  void _showBillDetailsDialog(Tenant tenant, Bill bill) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bill Details for ${tenant.name}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Amount Due: ${formatCurrency(bill.totalAmount)}'),
              Text('Balance Due: ${formatCurrency(bill.balanceDue)}'),
              Text(
                  'Due Date: ${DateFormat('MM/dd/yyyy').format(bill.dueDate)}'),
              // You can add more functionalities like 'Mark as Paid', 'Edit Bill', etc.
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Filter tenants based on the search query
  List<Tenant> _filterTenants() {
    return tenants.where((tenant) {
      final bill = tenantBills[tenant.id];
      return tenant.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (filterByDueDate &&
              bill != null &&
              bill.dueDate
                  .isBefore(DateTime.now())); // Filter by due date if enabled
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 10),
                Text(
                  'Reminder Automation',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Tenants',
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                PopupMenuButton<bool>(
                  icon: Icon(Icons.filter_alt),
                  onSelected: (value) {
                    setState(() {
                      if (value == true) {
                        filterByDueDate = true;
                        filterByHighestDebt = false;
                      } else {
                        filterByDueDate = false;
                        filterByHighestDebt = true;
                      }
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: true,
                        child: Text('Filter by Due Date'),
                      ),
                      PopupMenuItem(
                        value: false,
                        child: Text('Filter by Highest Debt'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _sortedTenants().length,
                itemBuilder: (context, index) {
                  var tenant = _sortedTenants()[index];
                  var bill = tenantBills[tenant.id];
                  return _buildTenantBillTile(tenant, bill);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Enter Custom Message',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: _customMessageController,
                      onChanged: (value) {
                        setState(() {
                          customMessage = value;
                          messageEntered = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Custom Reminder Message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    messageEntered
                        ? ElevatedButton(
                            onPressed: messageEntered
                                ? () {
                                    // Proceed with sending the reminders
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                'Send Custom Message',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _sendAllReminders();
                                                },
                                                child:
                                                    Text('Send to All Tenants'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _selectTenantsToSendMessage();
                                                },
                                                child: Text('Select Tenants'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                : null, // Disable the button if no message is entered
                            child: Text('Send'),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            },
          );
        },
        child: Icon(Icons.message),
      ),
    );
  }
}
