import '../entities/employee.dart';

abstract class EmployeeRepository {
  /// Get all employees (Manager only)
  Future<List<Employee>> getAllEmployees();
  
  /// Get employees managed by current manager
  Future<List<Employee>> getManagerTeam();
  
  /// Add existing employee to manager's team
  Future<Employee> addEmployeeToTeam(AddEmployeeToTeamRequest request);
  
  /// Register a new employee
  Future<Employee> registerEmployee(EmployeeRegistrationRequest request);
  
  /// Update employee role (Manager only)
  Future<void> updateEmployeeRole(String username, String newRole);
  
  /// Get employees managed by current user (Manager only)
  Future<List<Employee>> getEmployeesByManager();
  
  /// Update employee status (active/inactive)
  Future<void> updateEmployeeStatus(String username, bool isActive); // Changed from employeeId to username
  
  /// Create payroll entry for employee
  Future<PayrollInfo> createPayrollEntry(PayrollCreateRequest request);
  
  /// Get payroll entries
  Future<List<PayrollInfo>> getPayrollEntries();
  
  /// Create payslip for employee
  Future<Payslip> createPayslip(PayslipCreateRequest request);
  
  /// Get payslips (optionally filtered by employee ID or status)
  Future<List<Payslip>> getPayslips({String? employeeId, String? status});
  
  /// Generate payslip PDF
  Future<String> generatePayslipPdf(String payslipId);
  
  /// Send payslip email
  Future<void> sendPayslipEmail(String payslipId);
  
  /// Process payslip payment
  Future<void> processPayslipPayment(String payslipId);
}