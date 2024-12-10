import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class StaffScreen extends StatelessWidget {
  final CollectionReference staffCollection =
      FirebaseFirestore.instance.collection('staff');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 30,
                left: 16,
                right: 16), // Positioning slightly lower from top
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(
                            context); // Navigate back to previous screen
                      },
                    ),
                    SizedBox(
                        width: 10), // Space between the back button and text
                    Text(
                      'Staff List',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Manage your staff members',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<QuerySnapshot>(
              future: staffCollection.get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  var staffList = snapshot.data!.docs;
                  int totalStaff = staffList.length;
                  double totalWage = 0.0;
                  int unpaidCount = 0;

                  for (var staff in staffList) {
                    totalWage += staff['wage'] ?? 0.0;
                    if (!staff['isPaid']) {
                      unpaidCount++;
                    }
                  }

                  return SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Allow horizontal scrolling
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _OverviewCard(
                          title: 'Total Staff',
                          value: totalStaff.toString(),
                          icon: Icons.people,
                          color: Colors.blueAccent,
                        ),
                        _OverviewCard(
                          title: 'Total Wages',
                          value: NumberFormat.simpleCurrency(name: 'KES')
                              .format(totalWage),
                          icon: Icons.attach_money,
                          color: Colors.greenAccent,
                        ),
                        _OverviewCard(
                          title: 'Unpaid Staff',
                          value: unpaidCount.toString(),
                          icon: Icons.warning,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  );
                }

                return Center(child: Text('Error loading staff data.'));
              },
            ),
          ),

          // Staff List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: staffCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No staff members found.'));
                }

                var staffList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    var staff = staffList[index];

                    // Safely get the imageUrl or fallback to default
                    String imageUrl = (staff.data() as Map<String, dynamic>)
                                .containsKey('imageUrl') &&
                            staff['imageUrl'] != null
                        ? staff['imageUrl'] // If a network image URL is present
                        : 'assets/cooldp.jpeg'; // Fallback to local asset image if not

                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        title: Text(staff['name']),
                        subtitle: Text(
                            '${staff['role']} - ${NumberFormat.simpleCurrency(name: 'KES').format(staff['wage'])}'),
                        trailing: Icon(
                          staff['isPaid'] ? Icons.check_circle : Icons.cancel,
                          color: staff['isPaid'] ? Colors.green : Colors.red,
                        ),
                        onTap: () {
                          showStaffDetails(context, staff);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),

      // FAB for adding staff
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddStaffDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void showStaffDetails(BuildContext context, DocumentSnapshot staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StaffDetailScreen(staff: staff),
      ),
    );
  }

  // Add or edit staff
  void _showAddStaffDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController roleController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController wageController = TextEditingController();
    bool isPaid = false; // State variable to manage the switch
    File? imageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Staff'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            imageFile = File(pickedFile.path);
                          }
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: imageFile == null
                              ? AssetImage(
                                  'assets/cooldp.jpeg') // Use default image if no image is selected
                              : FileImage(imageFile!) as ImageProvider,
                          child: imageFile == null
                              ? Icon(Icons.camera_alt,
                                  size: 50, color: Colors.blue)
                              : null,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter the name';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: roleController,
                        decoration: InputDecoration(labelText: 'Role'),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter the role';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(labelText: 'Phone'),
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Please enter the phone number';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter the email';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: wageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Wage'),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter the wage';
                          return null;
                        },
                      ),
                      SwitchListTile(
                        title: Text('Paid?'),
                        value: isPaid,
                        onChanged: (bool value) {
                          setState(() {
                            isPaid = value; // Update the state of the switch
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      FirebaseFirestore.instance.collection('staff').add({
                        'name': nameController.text,
                        'role': roleController.text,
                        'phone': phoneController.text,
                        'email': emailController.text,
                        'wage': double.parse(wageController.text),
                        'isPaid': isPaid, // Use the current state of 'isPaid'
                        'imageUrl': imageFile == null
                            ? ''
                            : imageFile!.path, // Save image path or URL
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class StaffDetailScreen extends StatelessWidget {
  final DocumentSnapshot staff;

  StaffDetailScreen({required this.staff});

  @override
  Widget build(BuildContext context) {
    // Safely get the imageUrl or fallback to default asset
    String imageUrl =
        (staff.data() as Map<String, dynamic>).containsKey('imageUrl') &&
                staff['imageUrl'] != null
            ? staff['imageUrl'] // Use network image if available
            : 'assets/cooldp.jpeg'; // Default asset image

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Details'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit staff screen
              // This is where you would add a screen or dialog to edit staff details
              _showEditStaffDialog(context, staff);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Show confirmation dialog before deleting
              _showDeleteConfirmationDialog(context, staff);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(imageUrl),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Name', staff['name']),
                      _buildDetailRow('Role', staff['role']),
                      _buildDetailRow('Phone', staff['phone']),
                      _buildDetailRow('Email', staff['email']),
                      _buildDetailRow(
                        'Wage',
                        NumberFormat.simpleCurrency(name: 'KES')
                            .format(staff['wage']),
                      ),
                      _buildDetailRow('Paid', staff['isPaid'] ? 'Yes' : 'No'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a detailed row for display
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Show a dialog to confirm deleting the staff member
  void _showDeleteConfirmationDialog(
      BuildContext context, DocumentSnapshot staff) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Staff Member'),
          content: Text(
              'Are you sure you want to delete this staff member? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Delete the staff member from Firestore
                staff.reference.delete().then((value) {
                  Navigator.pop(context); // Close the confirmation dialog
                  Navigator.pop(context); // Go back to the previous screen
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Staff member deleted successfully.'),
                  ));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error deleting staff member: $error'),
                  ));
                });
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without deleting
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show a dialog to edit the staff member (this can be expanded with a form)
  void _showEditStaffDialog(BuildContext context, DocumentSnapshot staff) {
    final nameController = TextEditingController(text: staff['name']);
    final roleController = TextEditingController(text: staff['role']);
    final phoneController = TextEditingController(text: staff['phone']);
    final emailController = TextEditingController(text: staff['email']);
    final wageController =
        TextEditingController(text: staff['wage'].toString());
    bool isPaid = staff['isPaid'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Staff Member'),
          content: Form(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: roleController,
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: wageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Wage'),
                  ),
                  SwitchListTile(
                    title: Text('Paid?'),
                    value: isPaid,
                    onChanged: (bool value) {
                      isPaid = value; // Update the isPaid value
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Update staff in Firestore
                staff.reference.update({
                  'name': nameController.text,
                  'role': roleController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'wage': double.parse(wageController.text),
                  'isPaid': isPaid,
                }).then((value) {
                  Navigator.pop(context); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Staff member updated successfully.'),
                  ));
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error updating staff member: $error'),
                  ));
                });
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

// Custom Overview Card Widget
class _OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Title text is white
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
