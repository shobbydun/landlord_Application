import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/tenants_screen.dart'; // Import Firestore

class TenantDetailsPage extends StatefulWidget {
  final Tenant tenant;
  final Function(Tenant) onSave; // Callback to notify parent

  TenantDetailsPage({required this.tenant, required this.onSave});

  @override
  _TenantDetailsPageState createState() => _TenantDetailsPageState();
}

class _TenantDetailsPageState extends State<TenantDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late TextEditingController _leaseStartController;
  late TextEditingController _leaseEndController;
  late bool _isRentPaid;
  late String _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false; // New state variable to track edit mode

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.tenant.name);
    _phoneController = TextEditingController(text: widget.tenant.phone);
    _notesController = TextEditingController(text: widget.tenant.notes);
    _isRentPaid = widget.tenant.rentPaid;
    _profileImageUrl = widget.tenant.profileImage ?? '';

    _leaseStartController = TextEditingController(
      text: widget.tenant.leaseStartString,
    );
    _leaseEndController = TextEditingController(
      text: widget.tenant.leaseEndString,
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImageUrl = image.path;
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(pickedDate);
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateFormat('MM/dd/yyyy').parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  void _saveTenant() {
    DateTime leaseStart = _parseDate(_leaseStartController.text);
    DateTime leaseEnd = _parseDate(_leaseEndController.text);

    Tenant updatedTenant = Tenant(
      id: widget.tenant.id,
      name: _nameController.text,
      apartment: widget.tenant.apartment,
      phone: _phoneController.text,
      leaseStart: leaseStart,
      leaseEnd: leaseEnd,
      rentPaid: _isRentPaid,
      notes: _notesController.text,
      profileImage: _profileImageUrl,
    );

    FirebaseFirestore.instance
        .collection('tenants')
        .doc(updatedTenant.id)
        .update(updatedTenant.toMap())
        .then((_) {
      widget.onSave(updatedTenant); // Notify parent TenantsScreen to reload
      setState(() {
        _isEditing = false; // Switch back to view mode after saving
      });
    }).catchError((error) {
      print("Error updating tenant: $error");
      setState(() {
        _isEditing = false; // Handle error and revert to view mode
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            children: [
              // Custom AppBar-like Header
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 1,
                    right: 2,
                    bottom: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons
                          .arrow_back), // Default color (usually white on dark or transparent backgrounds)
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Tenant Details' : 'Tenant Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color, // Use default text color
                        ),
                      ),
                    ),
                    if (!_isEditing)
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _isEditing = true; // Toggle edit mode
                          });
                        },
                      ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Profile Image Section
              GestureDetector(
                onTap: _isEditing
                    ? _pickImage
                    : null, // Only allow picking image in edit mode
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.blueGrey[100],
                  backgroundImage: _profileImageUrl.isNotEmpty
                      ? _profileImageUrl.startsWith('http')
                          ? NetworkImage(_profileImageUrl)
                          : FileImage(File(_profileImageUrl))
                      : null,
                  child: _profileImageUrl.isEmpty
                      ? Icon(Icons.camera_alt, color: Colors.white, size: 40)
                      : null,
                ),
              ),
              SizedBox(height: 20),

              // Tenant Info Fields
              _buildTextField('Name', _nameController, enabled: _isEditing),
              _buildTextField('Phone', _phoneController, enabled: _isEditing),
              _buildTextField('Notes', _notesController,
                  enabled: _isEditing, maxLines: 3),
              _buildSwitch('Rent Paid', _isRentPaid, (value) {
                setState(() {
                  _isRentPaid = value;
                });
              }, enabled: _isEditing),
              _buildDatePicker('Lease Start Date', _leaseStartController,
                  enabled: _isEditing),
              _buildDatePicker('Lease End Date', _leaseEndController,
                  enabled: _isEditing),
              SizedBox(height: 20),

              // Save/Cancel Buttons
              if (_isEditing) ...[
                ElevatedButton(
                  onPressed: _saveTenant,
                  child: Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false; // Cancel editing
                    });
                  },
                  child: Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int? maxLines, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          controller: controller,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(hintText: 'Enter $label'),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged,
      {bool enabled = true}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Switch(value: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: enabled ? () => _selectDate(context, controller) : null,
          child: AbsorbPointer(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Select date'),
              keyboardType: TextInputType.datetime,
              enabled: enabled,
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
