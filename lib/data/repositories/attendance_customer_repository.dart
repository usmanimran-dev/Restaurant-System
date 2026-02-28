import 'package:restaurant/data/models/payroll_customer_model.dart';
import 'package:restaurant/data/repositories/firestore_repository.dart';

/// Repository for attendance, loans, and customer management.
class AttendanceRepository {
  AttendanceRepository(this._firestore);
  final FirestoreRepository _firestore;

  Future<List<AttendanceRecordModel>> fetchAttendance(String restaurantId, {String? employeeId, String? date}) async {
    final data = await _firestore.fetchAll('attendance', restaurantId: restaurantId);
    var records = data.map((d) => AttendanceRecordModel.fromJson(d)).toList();
    if (employeeId != null) records = records.where((r) => r.employeeId == employeeId).toList();
    if (date != null) records = records.where((r) => r.date == date).toList();
    return records;
  }

  Future<void> clockIn(AttendanceRecordModel record) async {
    await _firestore.insert('attendance', record.toJson());
  }

  Future<void> clockOut(String restaurantId, String recordId, DateTime clockOut) async {
    await _firestore.update('attendance', recordId, {
      'clock_out': clockOut.toIso8601String(),
      'status': 'present',
    });
  }
}

/// Repository for employee loans.
class LoanRepository {
  LoanRepository(this._firestore);
  final FirestoreRepository _firestore;

  Future<List<LoanModel>> fetchLoans(String restaurantId) async {
    final data = await _firestore.fetchAll('loans', restaurantId: restaurantId);
    return data.map((d) => LoanModel.fromJson(d)).toList();
  }

  Future<void> createLoan(LoanModel loan) async {
    await _firestore.insert('loans', loan.toJson());
  }

  Future<void> updateLoan(String restaurantId, String loanId, Map<String, dynamic> data) async {
    await _firestore.update('loans', loanId, data);
  }
}

/// Repository for customer CRM.
class CustomerRepository {
  CustomerRepository(this._firestore);
  final FirestoreRepository _firestore;

  Future<List<CustomerModel>> fetchCustomers(String restaurantId) async {
    final data = await _firestore.fetchAll('customers', restaurantId: restaurantId);
    return data.map((d) => CustomerModel.fromJson(d)).toList();
  }

  Future<void> createCustomer(CustomerModel customer) async {
    await _firestore.insert('customers', customer.toJson());
  }

  Future<void> updateCustomer(String restaurantId, String customerId, Map<String, dynamic> data) async {
    await _firestore.update('customers', customerId, data);
  }

  Future<CustomerModel?> findByPhone(String restaurantId, String phone) async {
    final all = await fetchCustomers(restaurantId);
    try {
      return all.firstWhere((c) => c.phone == phone);
    } catch (_) {
      return null;
    }
  }
}
