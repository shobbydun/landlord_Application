import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/addEditTenant.dart';
import 'package:landify/pages/tenant_details_page.dart'; // New Page for Tenant Details

class Tenant {
  final String id;
  final String name;
  final String apartment;
  final String phone;
  final DateTime leaseStart;
  final DateTime leaseEnd;
  final bool rentPaid;
  final String notes;
  final String? profileImage;

  Tenant({
    this.id = '',
    required this.name,
    required this.apartment,
    required this.phone,
    required this.leaseStart,
    required this.leaseEnd,
    required this.rentPaid,
    required this.notes,
    this.profileImage,
  });

  factory Tenant.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Tenant(
      id: doc.id,
      name: data['name'] ?? '',
      apartment: data['apartment'] ?? '',
      phone: data['phone'] ?? '',
      leaseStart: (data['leaseStart'] as Timestamp).toDate(),
      leaseEnd: (data['leaseEnd'] as Timestamp).toDate(),
      rentPaid: data['rentPaid'] ?? false,
      notes: data['notes'] ?? '',
      profileImage: data['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'apartment': apartment,
      'phone': phone,
      'leaseStart': leaseStart,
      'leaseEnd': leaseEnd,
      'rentPaid': rentPaid,
      'notes': notes,
      'profileImage': profileImage,
    };
  }

  String get leaseStartString => DateFormat('MM/dd/yyyy').format(leaseStart);
  String get leaseEndString => DateFormat('MM/dd/yyyy').format(leaseEnd);
}

class TenantsScreen extends StatefulWidget {
  @override
  _TenantPageState createState() => _TenantPageState();
}

class _TenantPageState extends State<TenantsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool showOnlyUnpaidRent = false;
  List<Tenant> tenants = [];
  List<Tenant> filteredTenants = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  void _loadTenants() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch tenants from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tenants')
          .orderBy('leaseStart', descending: true) // Sorting by lease start
          .limit(10)
          .get();

      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          tenants = querySnapshot.docs
              .map((doc) => Tenant.fromFirestore(doc))
              .toList();
          filteredTenants = _sortTenantsByLeaseStart(tenants);
          isLoading = false;
        });
      }
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print("Error loading tenants: $e");
    }
  }

  // Custom sorting function
  List<Tenant> _sortTenantsByLeaseStart(List<Tenant> tenants) {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month,
        today.day); // Ensure we compare only the date, not the time

    tenants.sort((a, b) {
      // Check if lease starts today
      if (a.leaseStart.isAtSameMomentAs(today)) {
        return -1; // Place 'a' at the top if its lease starts today
      }
      if (b.leaseStart.isAtSameMomentAs(today)) {
        return 1; // Place 'b' at the top if its lease starts today
      }

      // Otherwise, sort by lease start date (descending order)
      return b.leaseStart.compareTo(a.leaseStart);
    });

    return tenants;
  }

  void _filterTenants() {
    setState(() {
      filteredTenants = tenants.where((tenant) {
        bool matchesSearch = tenant.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            tenant.apartment
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        bool matchesRentStatus = showOnlyUnpaidRent ? !tenant.rentPaid : true;
        return matchesSearch && matchesRentStatus;
      }).toList();
    });
  }

  void _addTenant() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditTenantDialog(
          onSave: (tenant) {
            FirebaseFirestore.instance
                .collection('tenants')
                .add(tenant.toMap())
                .then((value) {
              _loadTenants();
            });
          },
        );
      },
    );
  }

  void _editTenant(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditTenantDialog(
          tenant: tenant,
          onSave: (updatedTenant) {
            FirebaseFirestore.instance
                .collection('tenants')
                .doc(tenant.id)
                .update(updatedTenant.toMap())
                .then((_) {
              _loadTenants();
              Navigator.pop(context);
            }).catchError((error) {
              print("Error updating tenant: $error");
              Navigator.pop(context);
            });
          },
        );
      },
    );
  }

  void _deleteTenant(Tenant tenant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this tenant?'),
          actions: [
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tenants')
                    .doc(tenant.id)
                    .delete()
                    .then((_) {
                  _loadTenants();
                  Navigator.pop(context);
                });
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _viewTenantDetails(Tenant tenant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantDetailsPage(
          tenant: tenant,
          onSave: (updatedTenant) {
            setState(() {
              int index = tenants.indexWhere((t) => t.id == updatedTenant.id);
              if (index != -1) {
                tenants[index] = updatedTenant;
              }
              filteredTenants = tenants;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom AppBar contents without using the AppBar widget
            Row(
              children: [
                // IconButton(
                //   icon: Icon(Icons.arrow_back),
                //   onPressed: () => Navigator.pop(context),
                // ),
                SizedBox(width: 8),
                Text(
                  "Tenants List",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTenant,
                ),
              ],
            ),
            SizedBox(height: 20),
            // Search bar with styling
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Tenant',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (text) => _filterTenants(),
            ),
            SizedBox(height: 10),
            // Rent Paid filter
            Row(
              children: [
                Checkbox(
                  value: showOnlyUnpaidRent,
                  onChanged: (value) {
                    setState(() {
                      showOnlyUnpaidRent = value!;
                      _filterTenants();
                    });
                  },
                ),
                Text('Show Only Unpaid Rent'),
              ],
            ),
            SizedBox(height: 20),
            // Loading indicator
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTenants.length,
                  itemBuilder: (context, index) {
                    final tenant = filteredTenants[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(tenant.name,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Apartment: ${tenant.apartment}\nLease: ${tenant.leaseStartString} to ${tenant.leaseEndString}',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(
                          tenant.rentPaid ? Icons.check_circle : Icons.cancel,
                          color: tenant.rentPaid ? Colors.green : Colors.red,
                        ),
                        onTap: () => _viewTenantDetails(tenant),
                        onLongPress: () => _deleteTenant(tenant),
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
}
