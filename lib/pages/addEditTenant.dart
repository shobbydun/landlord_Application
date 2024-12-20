import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/tenants_screen.dart'; // Import Tenant class

class AddEditTenantDialog extends StatefulWidget {
  final Tenant? tenant;
  final Function(Tenant) onSave;

  AddEditTenantDialog({this.tenant, required this.onSave});

  @override
  _AddEditTenantDialogState createState() => _AddEditTenantDialogState();
}

class _AddEditTenantDialogState extends State<AddEditTenantDialog> {
  late TextEditingController _nameController;
  late TextEditingController _apartmentController;
  late TextEditingController _phoneController;
  late DateTime _leaseStart;
  late DateTime _leaseEnd;
  late bool _rentPaid;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tenant?.name ?? '');
    _apartmentController =
        TextEditingController(text: widget.tenant?.apartment ?? '');
    _phoneController = TextEditingController(text: widget.tenant?.phone ?? '');
    _leaseStart = widget.tenant?.leaseStart ?? DateTime.now();
    _leaseEnd =
        widget.tenant?.leaseEnd ?? DateTime.now().add(Duration(days: 365));
    _rentPaid = widget.tenant?.rentPaid ?? false;
    _notesController = TextEditingController(text: widget.tenant?.notes ?? '');
  }

  // Validation for the form
  bool _validateForm() {
    if (_nameController.text.isEmpty || _apartmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name and Apartment are required!')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tenant == null ? 'Add Tenant' : 'Edit Tenant'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _apartmentController,
              decoration: InputDecoration(labelText: 'Apartment Number'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            ListTile(
              title: Text('Lease Start'),
              subtitle: Text(DateFormat.yMMMd().format(_leaseStart)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _leaseStart,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  setState(() {
                    _leaseStart = date;
                  });
                }
              },
            ),
            ListTile(
              title: Text('Lease End'),
              subtitle: Text(DateFormat.yMMMd().format(_leaseEnd)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _leaseEnd,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  setState(() {
                    _leaseEnd = date;
                  });
                }
              },
            ),
            SwitchListTile(
              title: Text('Rent Paid'),
              value: _rentPaid,
              onChanged: (value) {
                setState(() {
                  _rentPaid = value;
                });
              },
            ),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_validateForm()) {
              final tenant = Tenant(
                id: widget.tenant?.id ?? '', // Empty for new tenant, will be generated by Firestore
                name: _nameController.text,
                apartment: _apartmentController.text,
                phone: _phoneController.text,
                leaseStart: _leaseStart,
                leaseEnd: _leaseEnd,
                rentPaid: _rentPaid,
                notes: _notesController.text,
              );
              widget.onSave(tenant); // Pass tenant to onSave callback
              Navigator.of(context).pop(); // Close dialog
            }
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
