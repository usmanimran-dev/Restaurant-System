import 'package:equatable/equatable.dart';

abstract class TenantEvent extends Equatable {
  const TenantEvent();

  @override
  List<Object?> get props => [];
}

class LoadTenants extends TenantEvent {}

class CreateTenant extends TenantEvent {
  final String name;
  final String? address;
  final String? contact;
  final String adminEmail;
  final String adminPassword;
  final String adminName;

  const CreateTenant({
    required this.name,
    this.address,
    this.contact,
    required this.adminEmail,
    required this.adminPassword,
    this.adminName = 'Restaurant Admin',
  });

  @override
  List<Object?> get props => [name, address, contact, adminEmail, adminPassword, adminName];
}

class UpdateTenant extends TenantEvent {
  final String tenantId;
  final Map<String, dynamic> updates;

  const UpdateTenant(this.tenantId, this.updates);

  @override
  List<Object?> get props => [tenantId, updates];
}

class DeleteTenant extends TenantEvent {
  final String tenantId;

  const DeleteTenant(this.tenantId);

  @override
  List<Object?> get props => [tenantId];
}

class ToggleModule extends TenantEvent {
  final String tenantId;
  final String moduleKey;
  final bool isEnabled;

  const ToggleModule(this.tenantId, this.moduleKey, this.isEnabled);

  @override
  List<Object?> get props => [tenantId, moduleKey, isEnabled];
}
