import 'package:flutter/material.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/usecases/Employee_management/get_all_employees_usecase.dart';
import '../../../../domain/usecases/Employee_management/get_manager_team_usecase.dart';
import '../../../../domain/usecases/Employee_management/add_employee_to_team_usecase.dart';

class EmployeeViewModel extends ChangeNotifier {
  final GetAllEmployeesUseCase? _getAllEmployeesUseCase;
  final GetManagerTeamUseCase? _getManagerTeamUseCase;
  final AddEmployeeToTeamUseCase? _addEmployeeToTeamUseCase;
  
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = false;
  String? _error;
  String _selectedDepartment = '';
  String _searchQuery = '';

  // Getters
  List<Employee> get employees => _filteredEmployees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDepartment => _selectedDepartment;
  bool get hasEmployees => _employees.isNotEmpty;

  EmployeeViewModel({
    GetAllEmployeesUseCase? getAllEmployeesUseCase,
    GetManagerTeamUseCase? getManagerTeamUseCase,
    AddEmployeeToTeamUseCase? addEmployeeToTeamUseCase,
  }) : _getAllEmployeesUseCase = getAllEmployeesUseCase,
       _getManagerTeamUseCase = getManagerTeamUseCase,
       _addEmployeeToTeamUseCase = addEmployeeToTeamUseCase {
    // Comment this out to show empty state initially
    // _loadInitialData();
  }

  /// Loads initial employee data (mock data for now)
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Mock data - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      _employees = [
        Employee(
          userId: '1',
          username: 'sarah.johnson',
          email: 'sarah.johnson@company.com',
          role: 'Employee',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          firstName: 'Sarah',
          lastName: 'Johnson',
          department: 'Finance',
          position: 'Senior Accountant',
          payrollInfo: PayrollInfo(
            employeeName: 'Sarah Johnson',
            salaryAmount: 3250.00,
            salaryCurrency: 'USDC',
            paymentFrequency: 'MONTHLY',
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            isActive: true,
            status: 'ACTIVE',
          ),
        ),
        Employee(
          userId: '2',
          username: 'michael.chen',
          email: 'michael.chen@company.com',
          role: 'Employee',
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          firstName: 'Michael',
          lastName: 'Chen',
          department: 'Finance',
          position: 'Financial Analyst',
          payrollInfo: PayrollInfo(
            employeeName: 'Michael Chen',
            salaryAmount: 2800.00,
            salaryCurrency: 'USDC',
            paymentFrequency: 'MONTHLY',
            startDate: DateTime.now().subtract(const Duration(days: 25)),
            isActive: true,
            status: 'ACTIVE',
          ),
        ),
      ];
      _filteredEmployees = List.from(_employees);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters employees by department
  void filterByDepartment(String department) {
    _selectedDepartment = department;
    _applyFilters();
    notifyListeners();
  }

  /// Searches employees by name
  void searchEmployees(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  /// Applies both department and search filters
  void _applyFilters() {
    _filteredEmployees = _employees.where((employee) {
      bool matchesDepartment = _selectedDepartment.isEmpty || 
                               (employee.department?.toLowerCase() == _selectedDepartment.toLowerCase());
      bool matchesSearch = _searchQuery.isEmpty || 
                          employee.displayName.toLowerCase().contains(_searchQuery) ||
                          employee.username.toLowerCase().contains(_searchQuery);
      return matchesDepartment && matchesSearch;
    }).toList();
  }

  /// Clears all filters
  void clearFilters() {
    _selectedDepartment = '';
    _searchQuery = '';
    _filteredEmployees = List.from(_employees);
    notifyListeners();
  }

  /// Refreshes employee data
  Future<void> refresh() async {
    await _loadInitialData();
  }

  /// Clears the current error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Loads sample employee data for demo purposes
  Future<void> loadSampleData() async {
    await _loadInitialData();
  }

  /// Gets manager's team employees (the main list to show)
  Future<void> getManagerTeam() async {
    if (_getManagerTeamUseCase == null) {
      // Fallback to sample data if use case not available
      await _loadInitialData();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final employees = await _getManagerTeamUseCase.execute();
      _employees = employees;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds existing employee to manager's team (NEW WORKFLOW)
  Future<void> addEmployeeToTeam({
    required String email,
    String? position,
    String? department,
    String? fullName,
    String? phone,
  }) async {
    if (_addEmployeeToTeamUseCase == null) {
      throw Exception('Add employee to team functionality not available');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = AddEmployeeToTeamRequest(
        email: email,
        position: position,
        department: department,
        fullName: fullName,
        phone: phone,
      );

      await _addEmployeeToTeamUseCase.execute(request);
      
      // Refresh the team list to include the new employee
      await getManagerTeam();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Gets all employees from the backend (for admin purposes)
  Future<void> getAllEmployees() async {
    if (_getAllEmployeesUseCase == null) {
      // Fallback to sample data if use case not available
      await _loadInitialData();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final employees = await _getAllEmployeesUseCase.execute();
      _employees = employees;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets list of unique departments
  List<String> get departments {
    return _employees
        .where((e) => e.department != null && e.department!.isNotEmpty)
        .map((e) => e.department!)
        .toSet()
        .toList()
      ..sort();
  }
}
