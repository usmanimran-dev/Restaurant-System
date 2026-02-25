import 'package:equatable/equatable.dart';

class SalaryRecordModel extends Equatable {
  const SalaryRecordModel({
    required this.id,
    required this.employeeId,
    required this.restaurantId,
    required this.month, // Format: YYYY-MM
    required this.baseSalary,
    this.bonus = 0.0,
    this.loanDeduction = 0.0,
    this.taxDeduction = 0.0,
    this.reason,
    required this.netSalary,
    required this.status, // 'pending', 'paid'
    this.paymentDate,
  });

  final String id;
  final String employeeId;
  final String restaurantId;
  final String month;
  final double baseSalary;
  final double bonus;
  final double loanDeduction;
  final double taxDeduction;
  final String? reason;
  final double netSalary;
  final String status;
  final DateTime? paymentDate;

  factory SalaryRecordModel.fromJson(Map<String, dynamic> json) {
    return SalaryRecordModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      restaurantId: json['restaurant_id'] as String,
      month: json['month'] as String,
      baseSalary: (json['base_salary'] as num).toDouble(),
      bonus: (json['bonus'] as num?)?.toDouble() ?? 0.0,
      loanDeduction: (json['loan_deduction'] as num?)?.toDouble() ?? 0.0,
      taxDeduction: (json['tax_deduction'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] as String?,
      netSalary: (json['net_salary'] as num).toDouble(),
      status: json['status'] as String,
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'restaurant_id': restaurantId,
      'month': month,
      'base_salary': baseSalary,
      'bonus': bonus,
      'loan_deduction': loanDeduction,
      'tax_deduction': taxDeduction,
      'reason': reason,
      'net_salary': netSalary,
      'status': status,
      'payment_date': paymentDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id, employeeId, restaurantId, month, baseSalary,
        bonus, loanDeduction, taxDeduction, reason,
        netSalary, status, paymentDate
      ];
}
