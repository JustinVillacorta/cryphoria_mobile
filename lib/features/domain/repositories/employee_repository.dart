import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAllEmployees();

  Future<List<Employee>> getManagerTeam();

  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request);

  Future<Employee> registerEmployee(EmployeeRegistrationRequest request);

  Future<void> updateEmployeeRole(String username, String newRole);

  Future<List<Employee>> getEmployeesByManager();

  Future<void> updateEmployeeStatus(String username, bool isActive);

  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request);

  Future<List<PayrollInfo>> getPayrollEntries();

  Future<Payslip> createPayslip(PayslipCreateRequest request);

  Future<List<Payslip>> getPayslips({String? employeeId, String? status});

  Future<String> generatePayslipPdf(String payslipId);

  Future<void> sendPayslipEmail(String payslipId);

  Future<void> processPayslipPayment(String payslipId);

  Future<List<Employee>> getManagerTeamWithWallets();

  Future<String?> getEmployeeWalletAddress(String userId);

  Future<void> removeEmployeeFromTeam(String email);
}