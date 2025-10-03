import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../data_sources/employee_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Employee>> getAllEmployees() async {
    try {
      return await remoteDataSource.getAllEmployees();
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  @override
  Future<List<Employee>> getManagerTeam() async {
    try {
      return await remoteDataSource.getManagerTeam();
    } catch (e) {
      throw Exception('Failed to load team employees: $e');
    }
  }

  @override
  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request) async {
    try {
      return await remoteDataSource.addEmployeeToTeam(request);
    } catch (e) {
      throw Exception('Failed to add employee to team: $e');
    }
  }

  @override
  Future<Employee> registerEmployee(EmployeeRegistrationRequest request) async {
    try {
      return await remoteDataSource.registerEmployee(request);
    } catch (e) {
      throw Exception('Failed to register employee: $e');
    }
  }

  @override
  Future<void> updateEmployeeRole(String username, String newRole) async {
    try {
      await remoteDataSource.updateEmployeeRole(username, newRole);
    } catch (e) {
      throw Exception('Failed to update employee role: $e');
    }
  }

  @override
  Future<List<Employee>> getEmployeesByManager() async {
    try {
      return await remoteDataSource.getEmployeesByManager();
    } catch (e) {
      throw Exception('Failed to load managed employees: $e');
    }
  }

  @override
  Future<void> updateEmployeeStatus(String username, bool isActive) async {
    try {
      await remoteDataSource.updateEmployeeStatus(username, isActive);
    } catch (e) {
      throw Exception('Failed to update employee status: $e');
    }
  }

  @override
  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request) async {
    try {
      return await remoteDataSource.createPayrollEntry(request);
    } catch (e) {
      throw Exception('Failed to create payroll entry: $e');
    }
  }

  @override
  Future<List<PayrollInfo>> getPayrollEntries() async {
    try {
      return await remoteDataSource.getPayrollEntries();
    } catch (e) {
      throw Exception('Failed to load payroll entries: $e');
    }
  }

  @override
  Future<Payslip> createPayslip(PayslipCreateRequest request) async {
    try {
      return await remoteDataSource.createPayslip(request);
    } catch (e) {
      throw Exception('Failed to create payslip: $e');
    }
  }

  @override
  Future<List<Payslip>> getPayslips({String? employeeId, String? status}) async {
    try {
      return await remoteDataSource.getPayslips(employeeId: employeeId, status: status);
    } catch (e) {
      throw Exception('Failed to load payslips: $e');
    }
  }

  @override
  Future<String> generatePayslipPdf(String payslipId) async {
    try {
      return await remoteDataSource.generatePayslipPdf(payslipId);
    } catch (e) {
      throw Exception('Failed to generate payslip PDF: $e');
    }
  }

  @override
  Future<void> sendPayslipEmail(String payslipId) async {
    try {
      await remoteDataSource.sendPayslipEmail(payslipId);
    } catch (e) {
      throw Exception('Failed to send payslip email: $e');
    }
  }

  @override
  Future<void> processPayslipPayment(String payslipId) async {
    try {
      await remoteDataSource.processPayslipPayment(payslipId);
    } catch (e) {
      throw Exception('Failed to process payslip payment: $e');
    }
  }

  @override
  Future<PayrollBatchResult> processBatchPayroll(PayrollBatchRequest request) async {
    try {
      return await remoteDataSource.processBatchPayroll(request);
    } catch (e) {
      throw Exception('Failed to process batch payroll: $e');
    }
  }
}