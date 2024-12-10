import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:landify/pages/bills/BillViewScreen.dart';
import 'package:landify/pages/bills/bills_model.dart';
import 'package:landify/pages/tenants_screen.dart';

class BillDetailsScreen extends StatefulWidget {
  final Tenant tenant;
  final Bill? bill;

  BillDetailsScreen({required this.tenant, this.bill}) {
    if (tenant.id.isEmpty) {
      throw ArgumentError('Tenant ID cannot be empty');
    }
  }

  @override
  _BillDetailsScreenState createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  bool isLoading = true;
  Bill? bill;
  bool isEditing = true; 
  bool isPowerApplicable = false;
  bool isWaterApplicable = false;

  late TextEditingController _amountController;
  late TextEditingController _dueDateController;
  late TextEditingController _rentAmountController;
  late TextEditingController _waterUnitsController;
  late TextEditingController _powerUnitsController;
  late TextEditingController _powerAmountController;
  late TextEditingController _utilitiesAmountController;
  late TextEditingController _lateFeesController;
  late TextEditingController _otherFeesController;
  late TextEditingController _pricePerWaterUnitController;
  late TextEditingController _pricePerPowerUnitController;
  late TextEditingController _amountPaidController;
  late TextEditingController _balanceDueController;

  @override
  void initState() {
    super.initState();

    // Initialize the controllers
    _amountController = TextEditingController();
    _dueDateController = TextEditingController();
    _rentAmountController = TextEditingController();
    _waterUnitsController = TextEditingController();
    _powerUnitsController = TextEditingController();
    _powerAmountController = TextEditingController();
    _utilitiesAmountController = TextEditingController();
    _lateFeesController = TextEditingController();
    _otherFeesController = TextEditingController();
    _pricePerWaterUnitController = TextEditingController();
    _pricePerPowerUnitController = TextEditingController();
    _amountPaidController = TextEditingController();
    _balanceDueController = TextEditingController();

    if (widget.bill != null) {
      bill = widget.bill;
      _populateFields(bill!);
    } else {
      isLoading = false; // No bill data, so no loading indicator
    }
  }

  void _populateFields(Bill bill) {
    // Populate text fields with existing bill data
    _amountController.text = bill.totalAmount.toString();
    _dueDateController.text = DateFormat('MM/dd/yyyy').format(bill.dueDate);
    _rentAmountController.text = bill.rentAmount.toString();
    _waterUnitsController.text = bill.waterUnits.toString();
    _powerUnitsController.text = bill.powerUnits.toString();
    _utilitiesAmountController.text = bill.utilitiesAmount.toString();
    _lateFeesController.text = bill.lateFees.toString();
    _otherFeesController.text = bill.otherFees.toString();
    _pricePerWaterUnitController.text = bill.pricePerWaterUnit.toString();
    _pricePerPowerUnitController.text = bill.pricePerPowerUnit.toString();
    _amountPaidController.text = bill.amountPaid.toString();
    _balanceDueController.text = bill.balanceDue.toString();
    isLoading = false; // Once data is loaded, stop loading
  }

  void _updateCalculations() {
    setState(() {
      // Recalculate total amount and balance due on every input change
      double totalAmount = _calculateTotalAmount();
      double amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
      double balanceDue = _calculateBalanceDue(totalAmount, amountPaid);
      _amountController.text = totalAmount.toStringAsFixed(2);
      _amountController.selection = TextSelection.fromPosition(TextPosition(
          offset: _amountController.text.length)); // Keep cursor at the end
      _balanceDueController.text = balanceDue
          .toStringAsFixed(2); // Make sure you have a controller for this field
    });
  }

  double _calculateTotalAmount() {
    final rentAmount = double.tryParse(_rentAmountController.text) ?? 0.0;
    final waterUnits = double.tryParse(_waterUnitsController.text) ?? 0.0;
    final powerUnits = double.tryParse(_powerUnitsController.text) ?? 0.0;
    final utilitiesAmount =
        double.tryParse(_utilitiesAmountController.text) ?? 0.0;
    final lateFees = double.tryParse(_lateFeesController.text) ?? 0.0;
    final otherFees = double.tryParse(_otherFeesController.text) ?? 0.0;
    final pricePerWaterUnit =
        double.tryParse(_pricePerWaterUnitController.text) ?? 0.0;
    final pricePerPowerUnit =
        double.tryParse(_pricePerPowerUnitController.text) ?? 0.0;

    final waterAmount = waterUnits * pricePerWaterUnit;
    final powerAmount = powerUnits * pricePerPowerUnit;

    return rentAmount +
        waterAmount +
        powerAmount +
        utilitiesAmount +
        lateFees +
        otherFees;
  }

  double _calculateBalanceDue(double totalAmount, double amountPaid) {
    return totalAmount - amountPaid;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime initialDate = bill?.dueDate ?? DateTime.now();
    final DateTime firstDate = DateTime(2000);
    final DateTime lastDate = DateTime(2101);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null && pickedDate != bill?.dueDate) {
      setState(() {
        _dueDateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
      });
    }
  }

  void _saveOrUpdateBill() async {
    if (widget.tenant.id.isEmpty) {
      print("Error: Tenant ID is empty");
      return;
    }

    final totalAmount = _calculateTotalAmount();
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    final balanceDue = _calculateBalanceDue(totalAmount, amountPaid);
    final dueDateText = _dueDateController.text.trim();
    DateTime newDueDate = DateTime.now().add(Duration(days: 30));

    if (dueDateText.isNotEmpty) {
      try {
        newDueDate = DateFormat('MM/dd/yyyy').parse(dueDateText);
      } catch (e) {
        print('Error parsing due date: $e');
      }
    }

    // Create or update the bill in Firestore
    if (bill == null) {
      FirebaseFirestore.instance.collection('bills').add({
        'tenantId': widget.tenant.id,
        'totalAmount': totalAmount,
        'dueDate': newDueDate,
        'balanceDue': balanceDue,
        'rentAmount': double.tryParse(_rentAmountController.text) ?? 0.0,
        'waterUnits': double.tryParse(_waterUnitsController.text) ?? 0.0,
        'powerUnits': double.tryParse(_powerUnitsController.text) ?? 0.0,
        'powerAmount': double.tryParse(_powerAmountController.text) ?? 0.0,
        'utilitiesAmount':
            double.tryParse(_utilitiesAmountController.text) ?? 0.0,
        'lateFees': double.tryParse(_lateFeesController.text) ?? 0.0,
        'otherFees': double.tryParse(_otherFeesController.text) ?? 0.0,
        'pricePerWaterUnit':
            double.tryParse(_pricePerWaterUnitController.text) ?? 0.0,
        'pricePerPowerUnit':
            double.tryParse(_pricePerPowerUnitController.text) ?? 0.0,
        'isPaid': false,
        'amountPaid': amountPaid,
      }).then((docRef) {
        setState(() {
          bill = Bill(
            id: docRef.id,
            tenantId: widget.tenant.id,
            billDate: DateTime.now(),
            dueDate: newDueDate,
            totalAmount: totalAmount,
            balanceDue: balanceDue,
            rentAmount: double.tryParse(_rentAmountController.text) ?? 0.0,
            waterUnits: double.tryParse(_waterUnitsController.text) ?? 0.0,
            powerUnits: double.tryParse(_powerUnitsController.text) ?? 0.0,
            powerAmount: double.tryParse(_powerAmountController.text) ?? 0.0,
            utilitiesAmount:
                double.tryParse(_utilitiesAmountController.text) ?? 0.0,
            lateFees: double.tryParse(_lateFeesController.text) ?? 0.0,
            otherFees: double.tryParse(_otherFeesController.text) ?? 0.0,
            pricePerWaterUnit:
                double.tryParse(_pricePerWaterUnitController.text) ?? 0.0,
            pricePerPowerUnit:
                double.tryParse(_pricePerPowerUnitController.text) ?? 0.0,
            isPaid: false,
            amountPaid: amountPaid,
          );
          isEditing = false;
        });

        // After successful save, navigate to BillViewScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BillViewScreen(
              bill: bill!,
              tenantName: widget.tenant.name,
            ),
          ),
        );
      }).catchError((error) {
        print("Error saving bill: $error");
      });
    } else {
      FirebaseFirestore.instance.collection('bills').doc(bill!.id).update({
        'totalAmount': totalAmount,
        'dueDate': newDueDate,
        'balanceDue': balanceDue,
        'rentAmount': double.tryParse(_rentAmountController.text) ?? 0.0,
        'waterUnits': double.tryParse(_waterUnitsController.text) ?? 0.0,
        'powerUnits': double.tryParse(_powerUnitsController.text) ?? 0.0,
        'powerAmount': double.tryParse(_powerAmountController.text) ?? 0.0,
        'utilitiesAmount':
            double.tryParse(_utilitiesAmountController.text) ?? 0.0,
        'lateFees': double.tryParse(_lateFeesController.text) ?? 0.0,
        'otherFees': double.tryParse(_otherFeesController.text) ?? 0.0,
        'pricePerWaterUnit':
            double.tryParse(_pricePerWaterUnitController.text) ?? 0.0,
        'pricePerPowerUnit':
            double.tryParse(_pricePerPowerUnitController.text) ?? 0.0,
        'isPaid': bill!.isPaid,
        'amountPaid': amountPaid,
      }).then((_) {
        setState(() {
          bill = Bill(
            id: bill!.id,
            tenantId: widget.tenant.id,
            billDate: bill!.billDate,
            dueDate: newDueDate,
            totalAmount: totalAmount,
            balanceDue: balanceDue,
            rentAmount: double.tryParse(_rentAmountController.text) ?? 0.0,
            waterUnits: double.tryParse(_waterUnitsController.text) ?? 0.0,
            powerUnits: double.tryParse(_powerUnitsController.text) ?? 0.0,
            powerAmount: double.tryParse(_powerAmountController.text) ?? 0.0,
            utilitiesAmount:
                double.tryParse(_utilitiesAmountController.text) ?? 0.0,
            lateFees: double.tryParse(_lateFeesController.text) ?? 0.0,
            otherFees: double.tryParse(_otherFeesController.text) ?? 0.0,
            pricePerWaterUnit:
                double.tryParse(_pricePerWaterUnitController.text) ?? 0.0,
            pricePerPowerUnit:
                double.tryParse(_pricePerPowerUnitController.text) ?? 0.0,
            isPaid: bill!.isPaid,
            amountPaid: amountPaid,
          );
          isEditing = false;
        });

        // After successful update, navigate to BillViewScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BillViewScreen(
              bill: bill!,
              tenantName: widget.tenant.name,
            ),
          ),
        );
      }).catchError((error) {
        print("Error updating bill: $error");
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[300],
    appBar: AppBar(
      backgroundColor: Colors.blueAccent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Bill Details for ${widget.tenant.name}',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(  // Make the entire screen scrollable
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rent Amount Card
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rent Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextField(
                            controller: _rentAmountController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Enter Rent Amount',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Water Charges Section
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isWaterApplicable,
                                onChanged: (value) {
                                  setState(() {
                                    isWaterApplicable = value!;
                                  });
                                },
                              ),
                              Text(
                                'Water Charges Applicable',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          if (isWaterApplicable)
                            TextField(
                              controller: _waterUnitsController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Water Units',
                              ),
                              keyboardType: TextInputType.number,
                              enabled: isEditing,
                            ),
                          if (isWaterApplicable)
                            TextField(
                              controller: _pricePerWaterUnitController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Price per Water Unit',
                              ),
                              keyboardType: TextInputType.number,
                              enabled: isEditing,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Power Charges Section
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isPowerApplicable,
                                onChanged: (value) {
                                  setState(() {
                                    isPowerApplicable = value!;
                                  });
                                },
                              ),
                              Text(
                                'Power Charges Applicable',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          if (isPowerApplicable)
                            TextField(
                              controller: _powerUnitsController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Power Units',
                              ),
                              keyboardType: TextInputType.number,
                              enabled: isEditing,
                            ),
                          if (isPowerApplicable)
                            TextField(
                              controller: _pricePerPowerUnitController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Price per Power Unit',
                              ),
                              keyboardType: TextInputType.number,
                              enabled: isEditing,
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Utilities, Late Fees, and Other Fees Section
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _utilitiesAmountController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Utilities Amount',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _lateFeesController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Late Fees',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _otherFeesController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Other Fees',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Due Date Picker
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Due Date',
                        ),
                        keyboardType: TextInputType.datetime,
                        enabled: isEditing,
                        onTap: () => _selectDueDate(context),
                      ),
                    ),
                  ),
                  // Amount Paid, Total Amount, and Balance Due
                  Card(
                    elevation: 5,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _amountPaidController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount Paid',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: isEditing,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _amountController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Total Amount',
                            ),
                            enabled: false,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: TextEditingController(
                              text: (_calculateBalanceDue(
                                      _calculateTotalAmount(),
                                      double.tryParse(_amountPaidController.text) ?? 0.0)
                                  .toString()),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Balance Due',
                            ),
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cleared Bill Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: bill?.isPaid ?? false,
                        onChanged: (value) {
                          setState(() {
                            bill?.isPaid = value ?? false;
                          });
                        },
                      ),
                      Text('Cleared Bill', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  // Action Buttons
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (isEditing) {
                        _saveOrUpdateBill(); // Save or update bill when editing
                      } else {
                        if (bill != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BillViewScreen(
                                bill: bill!,
                                tenantName: widget.tenant.name,
                              ),
                            ),
                          );
                        } else {
                          print('Error: Bill is null');
                        }
                      }
                    },
                    child: Text(isEditing ? 'Save Bill' : 'View Bill'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (!isEditing)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                      child: Text('Edit Bill'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
  );
}


}
