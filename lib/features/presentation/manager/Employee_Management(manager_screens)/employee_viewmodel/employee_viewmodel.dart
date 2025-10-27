import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/usecases/Employee_management/get_all_employees_usecase.dart';
import '../../../../domain/usecases/Employee_management/get_manager_team_usecase.dart';
import '../../../../domain/usecases/Employee_management/add_employee_to_team_usecase.dart';
import '../../../../domain/usecases/Employee_management/remove_employee_from_team_usecase.dart';
import 'employee_state.dart';

class EmployeeViewModel extends StateNotifier<EmployeeState> {
  final GetAllEmployeesUseCase? _getAllEmployeesUseCase;
  final GetManagerTeamUseCase? _getManagerTeamUseCase;
  final AddEmployeeToTeamUseCase? _addEmployeeToTeamUseCase;
  final RemoveEmployeeFromTeamUseCase? _removeEmployeeFromTeamUseCase;

  EmployeeViewModel({
    GetAllEmployeesUseCase? getAllEmployeesUseCase,
    GetManagerTeamUseCase? getManagerTeamUseCase,
    AddEmployeeToTeamUseCase? addEmployeeToTeamUseCase,
    RemoveEmployeeFromTeamUseCase? removeEmployeeFromTeamUseCase,
  }) : _getAllEmployeesUseCase = getAllEmployeesUseCase,
       _getManagerTeamUseCase = getManagerTeamUseCase,
       _addEmployeeToTeamUseCase = addEmployeeToTeamUseCase,
       _removeEmployeeFromTeamUseCase = removeEmployeeFromTeamUseCase,
       super(EmployeeState.initial());

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final employees = [
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
      state = state.copyWith(
        employees: employees,
        filteredEmployees: List.from(employees),
        isLoading: false,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  void filterByDepartment(String department) {
    state = state.copyWith(selectedDepartment: department);
    _applyFilters();
  }

  void searchEmployees(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
    _applyFilters();
  }

  void _applyFilters() {
    final filteredEmployees = state.employees.where((employee) {
      bool matchesDepartment = state.selectedDepartment.isEmpty || 
                               (employee.department?.toLowerCase() == state.selectedDepartment.toLowerCase());
      bool matchesSearch = state.searchQuery.isEmpty || 
                          employee.displayName.toLowerCase().contains(state.searchQuery) ||
                          employee.username.toLowerCase().contains(state.searchQuery);
      return matchesDepartment && matchesSearch;
    }).toList();
    
    state = state.copyWith(filteredEmployees: filteredEmployees);
  }

  void clearFilters() {
    state = state.copyWith(
      selectedDepartment: '',
      searchQuery: '',
      filteredEmployees: List.from(state.employees),
    );
  }

  Future<void> refresh() async {
    await _loadInitialData();
  }

  void clearError() {
    state = state.copyWith(error: () => null);
  }

  Future<void> loadSampleData() async {
    await _loadInitialData();
  }

  Future<void> getManagerTeam() async {
    if (_getManagerTeamUseCase == null) {
      await _loadInitialData();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      final employees = await _getManagerTeamUseCase.execute();
      state = state.copyWith(
        employees: employees,
        isLoading: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

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

    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      final request = AddEmployeeToTeamRequest(
        email: email,
        position: position,
        department: department,
        fullName: fullName,
        phone: phone,
      );

      await _addEmployeeToTeamUseCase.execute(request);
      await getManagerTeam();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
      rethrow;
    }
  }

  Future<void> getAllEmployees() async {
    if (_getAllEmployeesUseCase == null) {
      await _loadInitialData();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      final employees = await _getAllEmployeesUseCase.execute();
      state = state.copyWith(
        employees: employees,
        isLoading: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> removeEmployeeFromTeam(String email) async {
    if (_removeEmployeeFromTeamUseCase == null) {
      throw Exception('Remove employee from team functionality not available');
    }

    state = state.copyWith(
      isLoading: true,
      error: () => null,
    );

    try {
      await _removeEmployeeFromTeamUseCase.execute(email);

      final updatedEmployees = state.employees
          .where((employee) => employee.email != email)
          .toList();

      state = state.copyWith(
        employees: updatedEmployees,
        filteredEmployees: updatedEmployees,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
      rethrow;
    }
  }
}