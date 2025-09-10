import 'package:flutter/material.dart';
import '../../../../domain/entities/employee.dart';

class EmployeeViewModel extends ChangeNotifier {
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

  EmployeeViewModel() {
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
          id: '1',
          name: 'Sarah Johnson',
          position: 'Senior Accountant',
          department: 'Finance',
          employeeCode: 'EMP-001',
          netPay: 3250.00,
        ),
        Employee(
          id: '2',
          name: 'Michael Chen',
          position: 'Financial Analyst',
          department: 'Finance',
          employeeCode: 'EMP-001',
          netPay: 3250.00,
        ),
        Employee(
          id: '3',
          name: 'Kristy Sy',
          position: 'Senior Accountant',
          department: 'Finance',
          employeeCode: 'EMP-001',
          netPay: 3250.00,
        ),
        Employee(
          id: '4',
          name: 'Jasmine Ty',
          position: 'Senior Accountant',
          department: 'Finance',
          employeeCode: 'EMP-001',
          netPay: 3250.00,
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
                               employee.department.toLowerCase() == _selectedDepartment.toLowerCase();
      bool matchesSearch = _searchQuery.isEmpty || 
                          employee.name.toLowerCase().contains(_searchQuery);
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

  /// Gets list of unique departments
  List<String> get departments {
    return _employees.map((e) => e.department).toSet().toList()..sort();
  }
}
