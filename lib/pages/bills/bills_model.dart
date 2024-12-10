import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  final String id;
  final String tenantId;
  final DateTime billDate;
  final DateTime dueDate;
  late final double totalAmount;
  final double amountPaid;
  final double balanceDue;
  final double rentAmount;
  final double waterUnits;
  final double powerUnits;
  final double powerAmount;
  final double utilitiesAmount;
  final double lateFees;
  final double otherFees;
  final double pricePerWaterUnit;
  final double pricePerPowerUnit;
  bool isPaid; // Mutable
  final bool? reminderSet; // New field to track if reminder is set

  Bill({
    this.id = '',
    required this.tenantId,
    required this.billDate,
    required this.dueDate,
    required this.totalAmount,
    required this.amountPaid,
    required this.balanceDue,
    required this.rentAmount,
    required this.waterUnits,
    required this.powerUnits,
    required this.powerAmount,
    required this.utilitiesAmount,
    required this.lateFees,
    required this.otherFees,
    required this.pricePerWaterUnit,
    required this.pricePerPowerUnit,
    required this.isPaid,
    this.reminderSet, 
  });

  // Factory method to create a Bill instance from Firestore data
  factory Bill.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Bill(
      id: doc.id,
      tenantId: data['tenantId'] ?? '',
      billDate: (data['billDate'] != null && data['billDate'] is Timestamp)
          ? (data['billDate'] as Timestamp).toDate()
          : DateTime.now(),
      dueDate: (data['dueDate'] != null && data['dueDate'] is Timestamp)
          ? (data['dueDate'] as Timestamp).toDate()
          : DateTime.now().add(Duration(days: 30)),
      totalAmount: data['totalAmount'] ?? 0.0,
      amountPaid: data['amountPaid'] ?? 0.0,
      balanceDue: data['balanceDue'] ?? 0.0,
      rentAmount: data['rentAmount'] ?? 0.0,
      waterUnits: data['waterUnits'] ?? 0.0,
      powerUnits: data['powerUnits'] ?? 0.0,
      powerAmount: data['powerAmount'] ?? 0.0,
      utilitiesAmount: data['utilitiesAmount'] ?? 0.0,
      lateFees: data['lateFees'] ?? 0.0,
      otherFees: data['otherFees'] ?? 0.0,
      pricePerWaterUnit: data['pricePerWaterUnit'] ?? 0.0,
      pricePerPowerUnit: data['pricePerPowerUnit'] ?? 0.0,
      isPaid: data['isPaid'] ?? false,
      reminderSet: data['reminderSet'], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tenantId': tenantId,
      'billDate': billDate,
      'dueDate': dueDate,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'balanceDue': balanceDue,
      'rentAmount': rentAmount,
      'waterUnits': waterUnits,
      'powerUnits': powerUnits,
      'powerAmount': powerAmount,
      'utilitiesAmount': utilitiesAmount,
      'lateFees': lateFees,
      'otherFees': otherFees,
      'pricePerWaterUnit': pricePerWaterUnit,
      'pricePerPowerUnit': pricePerPowerUnit,
      'isPaid': isPaid,
      'reminderSet': reminderSet, 
    };
  }

  Bill copyWith({
    String? id,
    String? tenantId,
    DateTime? billDate,
    DateTime? dueDate,
    double? totalAmount,
    double? amountPaid,
    double? balanceDue,
    double? rentAmount,
    double? waterUnits,
    double? powerUnits,
    double? powerAmount,
    double? utilitiesAmount,
    double? lateFees,
    double? otherFees,
    double? pricePerWaterUnit,
    double? pricePerPowerUnit,
    bool? isPaid,
    bool? reminderSet, 
  }) {
    return Bill(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      rentAmount: rentAmount ?? this.rentAmount,
      waterUnits: waterUnits ?? this.waterUnits,
      powerUnits: powerUnits ?? this.powerUnits,
      powerAmount: powerAmount ?? this.powerAmount,
      utilitiesAmount: utilitiesAmount ?? this.utilitiesAmount,
      lateFees: lateFees ?? this.lateFees,
      otherFees: otherFees ?? this.otherFees,
      pricePerWaterUnit: pricePerWaterUnit ?? this.pricePerWaterUnit,
      pricePerPowerUnit: pricePerPowerUnit ?? this.pricePerPowerUnit,
      isPaid: isPaid ?? this.isPaid,
      reminderSet: reminderSet ?? this.reminderSet, 
    );
  }
}
