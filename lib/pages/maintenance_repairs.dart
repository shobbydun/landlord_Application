import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaintenanceRepairs extends StatefulWidget {
  @override
  _MaintenanceRepairsState createState() => _MaintenanceRepairsState();
}

class _MaintenanceRepairsState extends State<MaintenanceRepairs> {
  List<Map<String, dynamic>> maintenanceRequests = [];
  List<Map<String, dynamic>> tenants = [];
  bool isLoading = true;
  bool isSubmitting = false;
  bool isFormVisible = false;

  String? selectedTenantId;
  String? selectedTenantName;
  final _issueController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMaintenanceRequests();
    _fetchTenants();
  }

  // Fetch maintenance requests from Firestore
  Future<void> _fetchMaintenanceRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('maintenance_requests')
          .get();
      if (mounted) {
        setState(() {
          maintenanceRequests = snapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add the document ID to the data
            return data;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching maintenance requests: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fetch tenants from Firestore
  Future<void> _fetchTenants() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('tenants').get();
      if (mounted) {
        setState(() {
          tenants = snapshot.docs
              .map((doc) => {
                    'id': doc.id,
                    'name': doc['name'],
                    'apartment': doc['apartment']
                  })
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching tenants: $e");
    }
  }

  // Submit a new maintenance request
  Future<void> _submitRequest() async {
    if (selectedTenantId == null ||
        _issueController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('maintenance_requests').add({
        'tenantId': selectedTenantId,
        'tenantName': selectedTenantName, // Store tenant's name
        'issue': _issueController.text,
        'description': _descriptionController.text,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });

      // Clear the form
      _issueController.clear();
      _descriptionController.clear();
      if (mounted) {
        setState(() {
          selectedTenantId = null;
          selectedTenantName = null;
          isSubmitting = false;
          isFormVisible = false; // Hide the form after submission
        });
      }

      // Refresh the list
      _fetchMaintenanceRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Maintenance request submitted successfully")),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request")),
      );
    }
  }

  // Mark request as resolved and remove it immediately from the list
  Future<void> _resolveRequest(String requestId) async {
    try {
      // Update the Firestore status to resolved
      await FirebaseFirestore.instance
          .collection('maintenance_requests')
          .doc(requestId)
          .update({
        'status': 'resolved',
      });

      // Remove the resolved request from the local list immediately
      if (mounted) {
        setState(() {
          maintenanceRequests.removeWhere((request) => request['id'] == requestId);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request resolved successfully")),
      );
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom header (replaces app bar)
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
                  "Maintenance Requests",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Toggle for the maintenance request form
            AnimatedCrossFade(
              duration: Duration(milliseconds: 300),
              firstChild: Container(),
              secondChild: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Dropdown to select tenant
                      DropdownButtonFormField<String>(
                        value: selectedTenantId,
                        onChanged: (String? newValue) {
                          if (mounted) {
                            setState(() {
                              selectedTenantId = newValue;
                              selectedTenantName = tenants
                                  .firstWhere((tenant) => tenant['id'] == newValue)['name'];
                            });
                          }
                        },
                        items: tenants.map<DropdownMenuItem<String>>((tenant) {
                          return DropdownMenuItem<String>(
                            value: tenant['id'],
                            child: Text(tenant['name'] ?? 'Unknown Tenant'),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: "Select Tenant",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Issue TextField
                      TextField(
                        controller: _issueController,
                        decoration: InputDecoration(
                          labelText: "Issue",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Description TextField
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSubmitting
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Save Request", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: isFormVisible
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            SizedBox(height: 30),

            // Display existing maintenance requests
            isLoading
                ? Center(child: CircularProgressIndicator())
                : maintenanceRequests.isEmpty
                    ? Center(child: Text("No maintenance requests"))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: maintenanceRequests.length,
                          itemBuilder: (context, index) {
                            var request = maintenanceRequests[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 10),
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  request['tenantName'] ?? 'Unknown Tenant',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Issue: ${request['issue']}"),
                                    Text("Description: ${request['description']}"),
                                    Text("Status: ${request['status']}"),
                                    Text("Saved on: ${request['createdAt'].toDate()}"),
                                  ],
                                ),
                                onTap: () {
                                  // Show request details on tap
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Maintenance Request Details'),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Tenant: ${request['tenantName']}"),
                                            Text("Issue: ${request['issue']}"),
                                            Text("Description: ${request['description']}"),
                                            Text("Status: ${request['status']}"),
                                            Text("Created At: ${request['createdAt'].toDate()}"),
                                          ],
                                        ),
                                        actions: [
                                          if (request['status'] == 'pending')
                                            TextButton(
                                              onPressed: () {
                                                _resolveRequest(request['id']);
                                                Navigator.pop(context);
                                              },
                                              child: Text("Resolve"),
                                            ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("Close"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                trailing: request['status'] == 'pending'
                                    ? IconButton(
                                        icon: Icon(Icons.check, color: Colors.green),
                                        onPressed: () => _resolveRequest(request['id']),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isFormVisible = !isFormVisible;
          });
        },
        backgroundColor: Colors.blue,
        child: Icon(isFormVisible ? Icons.close : Icons.add, color: Colors.white),
      ),
    );
  }
}
