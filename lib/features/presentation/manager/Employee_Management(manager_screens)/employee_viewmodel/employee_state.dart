import '../../../../domain/entities/employee.dart';

class EmployeeState {
  final List<Employee> employees;
  final List<Employee> filteredEmployees;
  final bool isLoading;
  final String? error;
  final String selectedDepartment;
  final String searchQuery;

  const EmployeeState({
    required this.employees,
    required this.filteredEmployees,
    required this.isLoading,
    this.error,
    required this.selectedDepartment,
    required this.searchQuery,
  });

  factory EmployeeState.initial() {
    return const EmployeeState(
      employees: [],
      filteredEmployees: [],
      isLoading: false,
      error: null,
      selectedDepartment: '',
      searchQuery: '',
    );
  }

  bool get hasEmployees => employees.isNotEmpty;

  List<String> get departments {
    return employees
        .where((e) => e.department != null && e.department!.isNotEmpty)
        .map((e) => e.department!)
        .toSet()
        .toList()
      ..sort();
  }

  EmployeeState copyWith({
    List<Employee>? employees,
    List<Employee>? filteredEmployees,
    bool? isLoading,
    Function()? error,
    String? selectedDepartment,
    String? searchQuery,
  }) {
    return EmployeeState(
      employees: employees ?? this.employees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      selectedDepartment: selectedDepartment ?? this.selectedDepartment,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
