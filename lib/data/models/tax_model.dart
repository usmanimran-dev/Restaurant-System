import 'package:equatable/equatable.dart';

/// Per-restaurant tax configuration.
class TaxConfigurationModel extends Equatable {
  const TaxConfigurationModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.rate,
    this.isDefault = true,
    this.isActive = true,
    this.ntn,
    this.businessName,
    this.businessAddress,
    this.fbrPosId,
  });

  final String id;
  final String restaurantId;
  final String name; // e.g., "GST", "Service Tax"
  final double rate; // e.g., 17.0 for 17%
  final bool isDefault;
  final bool isActive;
  final String? ntn; // National Tax Number (Pakistan)
  final String? businessName;
  final String? businessAddress;
  final String? fbrPosId; // POS ID assigned by FBR

  factory TaxConfigurationModel.fromJson(Map<String, dynamic> json) {
    return TaxConfigurationModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      ntn: json['ntn'] as String?,
      businessName: json['business_name'] as String?,
      businessAddress: json['business_address'] as String?,
      fbrPosId: json['fbr_pos_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'rate': rate,
      'is_default': isDefault,
      'is_active': isActive,
      'ntn': ntn,
      'business_name': businessName,
      'business_address': businessAddress,
      'fbr_pos_id': fbrPosId,
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, name, rate, isDefault, isActive,
        ntn, businessName, businessAddress, fbrPosId,
      ];
}

/// Tax category to assign to individual menu items (e.g., "Exempt", "Reduced Rate").
class TaxCategoryModel extends Equatable {
  const TaxCategoryModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.rate,
  });

  final String id;
  final String restaurantId;
  final String name;
  final double rate; // Can override the restaurant default (e.g., 0 for exempt)

  factory TaxCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaxCategoryModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'rate': rate,
    };
  }

  @override
  List<Object?> get props => [id, restaurantId, name, rate];
}

/// A record of a submitted FBR invoice.
class FbrInvoiceModel extends Equatable {
  const FbrInvoiceModel({
    required this.id,
    required this.restaurantId,
    required this.orderId,
    required this.invoiceNumber,
    required this.status,
    this.response,
    this.qrCodeData,
    this.submittedAt,
    this.retryCount = 0,
  });

  final String id;
  final String restaurantId;
  final String orderId;
  final String invoiceNumber;
  final String status; // 'pending', 'submitted', 'failed', 'verified'
  final String? response; // Raw response from FBR API
  final String? qrCodeData;
  final DateTime? submittedAt;
  final int retryCount;

  factory FbrInvoiceModel.fromJson(Map<String, dynamic> json) {
    return FbrInvoiceModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      orderId: json['order_id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      status: json['status'] as String,
      response: json['response'] as String?,
      qrCodeData: json['qr_code_data'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'order_id': orderId,
      'invoice_number': invoiceNumber,
      'status': status,
      'response': response,
      'qr_code_data': qrCodeData,
      'submitted_at': submittedAt?.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  @override
  List<Object?> get props => [
        id, restaurantId, orderId, invoiceNumber, status,
        response, qrCodeData, submittedAt, retryCount,
      ];
}
