import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/bills/BillViewScreen.dart';
import 'package:landify/pages/bills/biils_detailsScreen.dart';
import 'package:landify/pages/bills/bills_model.dart';
import 'package:landify/pages/tenants_screen.dart';

class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<Tenant> tenants = [];
  Map<String, Bill?> tenantBills = {}; // Store fetched bills for tenants
  List<Tenant> filteredTenants = []; // Filtered list of tenants
  bool isLoading = true;
  bool showUnpaidOnly = false;
  String searchQuery = '';
  bool sortByEarliestDueDate = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  void _loadTenants() async {
    try {
      QuerySnapshot tenantSnapshot =
          await FirebaseFirestore.instance.collection('tenants').get();
      if (mounted) {
        setState(() {
          tenants = tenantSnapshot.docs
              .map((doc) => Tenant.fromFirestore(doc))
              .toList();
          filteredTenants = List.from(tenants); // Initialize with all tenants
          isLoading = false;
        });
      }

      // Fetch bills for each tenant in parallel after loading tenants
      for (var tenant in tenants) {
        _fetchBillForTenant(tenant);
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

    // Only call setState if the widget is still mounted
    if (mounted) {
      setState(() {});
    }
  }

  void _applyFilters() {
    List<Tenant> filteredList = List.from(tenants);

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filteredList = filteredList.where((tenant) {
        return tenant.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            tenant.apartment.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by unpaid bills
    if (showUnpaidOnly) {
      filteredList = filteredList.where((tenant) {
        final bill = tenantBills[tenant.id];
        return bill != null && !bill.isPaid;
      }).toList();
    }

    // Sort by due date (earliest first)
    if (sortByEarliestDueDate) {
      filteredList.sort((tenant1, tenant2) {
        final bill1 = tenantBills[tenant1.id];
        final bill2 = tenantBills[tenant2.id];
        if (bill1 != null && bill2 != null) {
          return bill1.dueDate.compareTo(bill2.dueDate);
        }
        return 0; // No sorting if bill is missing
      });
    }

    if (mounted) {
      setState(() {
        filteredTenants = filteredList;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom header section
          Row(
            children: [
              // IconButton(
              //   icon: Icon(Icons.arrow_back, color: Colors.black),
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              // ),
              SizedBox(width: 10),
              Text(
                "Bills Overview", // Title
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Search bar for tenant name or apartment
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              _applyFilters();
            },
            decoration: InputDecoration(
              labelText: 'Search by name or apartment',
              prefixIcon: Icon(Icons.search),
            ),
          ),

          SizedBox(height: 16),

          // Filter and sort controls
          Row(
            children: [
              // Filter for unpaid bills only
              Row(
                children: [
                  Text('Unpaid Only'),
                  Switch(
                    value: showUnpaidOnly,
                    onChanged: (value) {
                      setState(() {
                        showUnpaidOnly = value;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),

              SizedBox(width: 16),

              // Sort by earliest due date
              Row(
                children: [
                  Text('Sort by Due Date'),
                  Switch(
                    value: sortByEarliestDueDate,
                    onChanged: (value) {
                      setState(() {
                        sortByEarliestDueDate = value;
                      });
                      _applyFilters();
                    },
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          // Loading indicator or list of tenants
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredTenants.length,
                    itemBuilder: (context, index) {
                      final tenant = filteredTenants[index];
                      final bill = tenantBills[tenant.id];

                      // Set default values if no bill is found
                      final billAmount = bill?.totalAmount ?? 0.0;
                      final dueDate = bill != null
                          ? bill.dueDate
                          : DateTime.now().add(Duration(days: 30));
                      final isPaid = bill?.isPaid ?? false;

                      return Card(
                        margin: EdgeInsets.only(bottom: 10),
                        elevation: 3,
                        child: ListTile(
                          title: Text(tenant.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Apartment: ${tenant.apartment}"),
                              Text("Amount: Kshs ${billAmount.toStringAsFixed(2)}"),
                              Text(
                                'Due Date: ${DateFormat('MM/dd/yyyy').format(dueDate)}',
                              ),
                              Text(
                                isPaid ? "Status: Paid" : "Status: Not Paid",
                                style: TextStyle(
                                  color: isPaid ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () => _viewBillsForTenant(tenant, bill),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    ),
  );
}

  void _viewBillsForTenant(Tenant tenant, Bill? bill) {
    // Check if the bill is not null and has a non-zero total amount
    if (bill != null && bill.totalAmount > 0) {
      // Navigate to BillViewScreen if the bill has a valid amount
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillViewScreen(
            bill: bill,
            tenantName: tenant.name,
          ),
        ),
      ).then((_) {
        // Reload bill data when coming back from BillViewScreen
        if (mounted) {
          _fetchBillForTenant(tenant); // Fetch updated bill data
        }
      });
    } else {
      // Navigate to BillDetailsScreen if the bill has no valid data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BillDetailsScreen(
            tenant: tenant,
            bill: bill, // Pass bill data, which may be null
          ),
        ),
      ).then((_) {
        // Reload bill data after returning from BillDetailsScreen
        if (mounted) {
          _fetchBillForTenant(tenant); // Fetch updated bill data
        }
      });
    }
  }
}
