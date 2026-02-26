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
      resolvedRoleName = json['role_name'] as String? ?? json['role'] as String?;
    }

    return EmployeeModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      restaurantId: (json['restaurant_id'] ?? '').toString(),
      roleId: (json['role_id'] ?? '').toString(),
      roleName: resolvedRoleName,
      phone: json['phone'] as String?,
      baseSalary: (json['base_salary'] as num?)?.toDouble() ?? 0.0,
      joiningDate: json['joining_date'] != null
          ? DateTime.tryParse(json['joining_date'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? email,
    String? name,
    String? restaurantId,
    String? roleId,
    String? roleName,
    String? phone,
    double? baseSalary,
    DateTime? joiningDate,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      restaurantId: restaurantId ?? this.restaurantId,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      phone: phone ?? this.phone,
      baseSalary: baseSalary ?? this.baseSalary,
      joiningDate: joiningDate ?? this.joiningDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'restaurant_id': restaurantId,
      'role_id': roleId,
      'role_name': roleName,
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
