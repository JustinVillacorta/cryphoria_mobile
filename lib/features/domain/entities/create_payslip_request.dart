
import 'payslip.dart';

class CreatePayslipRequest {
  final String employeeName;
  final String employeeId;
  final String? employeeEmail;
  final String? employeeWallet;
  final String? department;
  final String? position;
  final double salaryAmount;
  final String? salaryCurrency;
  final String? cryptocurrency;
  final String payPeriodStart;
  final String payPeriodEnd;
  final String? payDate;
  final double? taxDeduction;
  final double? insuranceDeduction;
  final double? retirementDeduction;
  final double? otherDeductions;
  final double? overtimePay;
  final double? bonus;
  final double? allowances;
  final String? notes;

  const CreatePayslipRequest({
    required this.employeeName,
    required this.employeeId,
    this.employeeEmail,
    this.employeeWallet,
    this.department,
    this.position,
    required this.salaryAmount,
    this.salaryCurrency,
    this.cryptocurrency,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    this.payDate,
    this.taxDeduction,
    this.insuranceDeduction,
    this.retirementDeduction,
    this.otherDeductions,
    this.overtimePay,
    this.bonus,
    this.allowances,
    this.notes,
  });

  CreatePayslipRequest copyWith({
    String? employeeName,
    String? employeeId,
    String? employeeEmail,
    String? employeeWallet,
    String? department,
    String? position,
    double? salaryAmount,
    String? salaryCurrency,
    String? cryptocurrency,
    String? payPeriodStart,
    String? payPeriodEnd,
    String? payDate,
    double? taxDeduction,
    double? insuranceDeduction,
    double? retirementDeduction,
    double? otherDeductions,
    double? overtimePay,
    double? bonus,
    double? allowances,
    String? notes,
  }) {
    return CreatePayslipRequest(
      employeeName: employeeName ?? this.employeeName,
      employeeId: employeeId ?? this.employeeId,
      employeeEmail: employeeEmail ?? this.employeeEmail,
      employeeWallet: employeeWallet ?? this.employeeWallet,
      department: department ?? this.department,
      position: position ?? this.position,
      salaryAmount: salaryAmount ?? this.salaryAmount,
      salaryCurrency: salaryCurrency ?? this.salaryCurrency,
      cryptocurrency: cryptocurrency ?? this.cryptocurrency,
      payPeriodStart: payPeriodStart ?? this.payPeriodStart,
      payPeriodEnd: payPeriodEnd ?? this.payPeriodEnd,
      payDate: payDate ?? this.payDate,
      taxDeduction: taxDeduction ?? this.taxDeduction,
      insuranceDeduction: insuranceDeduction ?? this.insuranceDeduction,
      retirementDeduction: retirementDeduction ?? this.retirementDeduction,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      overtimePay: overtimePay ?? this.overtimePay,
      bonus: bonus ?? this.bonus,
      allowances: allowances ?? this.allowances,
      notes: notes ?? this.notes,
    );
  }
}

class PayslipFilter {
  final String? employeeId;
  final PayslipStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? department;

  const PayslipFilter({
    this.employeeId,
    this.status,
    this.startDate,
    this.endDate,
    this.department,
  });

  PayslipFilter copyWith({
    String? employeeId,
    PayslipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? department,
  }) {
    return PayslipFilter(
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      department: department ?? this.department,
    );
  }
}