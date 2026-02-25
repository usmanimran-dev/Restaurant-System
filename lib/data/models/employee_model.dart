import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  const EmployeeModel({
    required this.id,
    required this.email,
    required this.name,
    required this.restaurantId,
    required this.roleId,
    this.roleName,
    this.phone,
    this.baseSalary = 0.0,
    this.joiningDate,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final String restaurantId;
  final String roleId;
  final String? roleName;
  final String? phone;
  final double baseSalary;
  final DateTime? joiningDate;
  final DateTime? createdAt;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    String? resolvedRoleName;
    if (json['roles'] is Map) {
      resolvedRoleName = (json['roles'] as Map<String, dynamic>)['name'] as String?;
    } else {
      resolvedRoleName = json['role_name'] as String?;
    }

    return EmployeeModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      restaurantId: json['restaurant_id'] as String,
      roleId: json['role_id'] as String,
      roleName: resolvedRoleName,
      phone: json['phone'] as String?,
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0.0,
      joiningDate: json['joining_date'] != null
          ? DateTime.parse(json['joining_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'restaurant_id': restaurantId,
      'role_id': roleId,
      'phone': phone,
      'base_salary': baseSalary,
      'joining_date': joiningDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id, email, name, restaurantId, roleId, roleName,
        phone, baseSalary, joiningDate, createdAt,
      ];
}
