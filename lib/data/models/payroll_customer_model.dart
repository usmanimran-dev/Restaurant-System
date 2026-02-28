import 'package:equatable/equatable.dart';

/// Attendance status.
enum AttendanceStatus { present, late, absent, halfDay }

/// Employee attendance record.
class AttendanceRecordModel extends Equatable {
  const AttendanceRecordModel({
    required this.id,
    required this.restaurantId,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.status = AttendanceStatus.absent,
    this.overtimeHours = 0,
    this.shiftAssigned,
  });

  final String id;
  final String restaurantId;
  final String employeeId;
  final String employeeName;
  final String date; // YYYY-MM-DD
  final DateTime? clockIn;
  final DateTime? clockOut;
  final AttendanceStatus status;
  final double overtimeHours;
  final String? shiftAssigned;

  double get hoursWorked {
    if (clockIn == null || clockOut == null) return 0;
    return clockOut!.difference(clockIn!).inMinutes / 60.0;
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String? ?? '',
      date: json['date'] as String,
      clockIn: json['clock_in'] != null ? DateTime.parse(json['clock_in'] as String) : null,
      clockOut: json['clock_out'] != null ? DateTime.parse(json['clock_out'] as String) : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'absent'),
        orElse: () => AttendanceStatus.absent,
      ),
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0,
      shiftAssigned: json['shift_assigned'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'date': date,
        'clock_in': clockIn?.toIso8601String(),
        'clock_out': clockOut?.toIso8601String(),
        'status': status.name,
        'overtime_hours': overtimeHours,
        'shift_assigned': shiftAssigned,
      };

  @override
  List<Object?> get props => [id, restaurantId, employeeId, date, status];
}

/// Employee loan model.
class LoanModel extends Equatable {
  const LoanModel({
    required this.id,
    required this.restaurantId,
    required this.employeeId,
    required this.employeeName,
    required this.amount,
    this.remainingAmount = 0,
    this.monthlyDeduction = 0,
    this.reason,
    this.status = 'active',
    this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String employeeId;
  final String employeeName;
  final double amount;
  final double remainingAmount;
  final double monthlyDeduction;
  final String? reason;
  final String status; // active, paid, cancelled
  final DateTime? createdAt;

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      employeeId: json['employee_id'] as String,
      employeeName: json['employee_name'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num?)?.toDouble() ?? 0,
      monthlyDeduction: (json['monthly_deduction'] as num?)?.toDouble() ?? 0,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'employee_id': employeeId,
        'employee_name': employeeName,
        'amount': amount,
        'remaining_amount': remainingAmount,
        'monthly_deduction': monthlyDeduction,
        'reason': reason,
        'status': status,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  @override
  List<Object?> get props => [id, restaurantId, employeeId, amount, status];
}

/// Customer entity for CRM.
class CustomerModel extends Equatable {
  const CustomerModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.customerType = 'regular',
    this.totalOrders = 0,
    this.totalSpent = 0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.createdAt,
    this.lastOrderAt,
  });

  final String id;
  final String restaurantId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String customerType;
  final int totalOrders;
  final double totalSpent;
  final int loyaltyPoints;
  final String loyaltyTier; // bronze, silver, gold
  final DateTime? createdAt;
  final DateTime? lastOrderAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      customerType: json['customer_type'] as String? ?? 'regular',
      totalOrders: json['total_orders'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      loyaltyTier: json['loyalty_tier'] as String? ?? 'bronze',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      lastOrderAt: json['last_order_at'] != null ? DateTime.parse(json['last_order_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurant_id': restaurantId,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'customer_type': customerType,
        'total_orders': totalOrders,
        'total_spent': totalSpent,
        'loyalty_points': loyaltyPoints,
        'loyalty_tier': loyaltyTier,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
        'last_order_at': lastOrderAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, restaurantId, name, phone, totalOrders, loyaltyPoints, loyaltyTier];
}
