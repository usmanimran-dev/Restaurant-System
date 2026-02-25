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
  // A password for the auto-created admin account can be specified if needed
  final String adminEmail;
  final String adminPassword;

  const CreateTenant({
    required this.name,
    this.address,
    this.contact,
    required this.adminEmail,
    required this.adminPassword,
  });

  @override
  List<Object?> get props => [name, address, contact, adminEmail, adminPassword];
}

class ToggleModule extends TenantEvent {
  final String tenantId;
  final String moduleKey;
  final bool isEnabled;

  const ToggleModule(this.tenantId, this.moduleKey, this.isEnabled);

  @override
  List<Object?> get props => [tenantId, moduleKey, isEnabled];
}
