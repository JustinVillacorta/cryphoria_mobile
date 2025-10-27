
import '../../domain/entities/payroll_details_response.dart';
import 'payroll_statistics_model.dart';
import 'payroll_entry_model.dart';
import 'payslip_model.dart';

class PayrollDetailsResponseModel extends PayrollDetailsResponse {
  const PayrollDetailsResponseModel({
    required super.success,
    required super.payrollStatistics,
    required super.payrollEntries,
    required super.payslips,
  });

  factory PayrollDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return PayrollDetailsResponseModel(
      success: json['success'] as bool? ?? false,
      payrollStatistics: PayrollStatisticsModel.fromJson(
        json['payroll_statistics'] as Map<String, dynamic>? ?? {},
      ),
      payrollEntries: (json['payroll_entries'] as List<dynamic>?)
          ?.map((e) => PayrollEntryModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      payslips: (json['payslips'] as List<dynamic>?)
          ?.map((e) => PayslipModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payroll_statistics': (payrollStatistics as PayrollStatisticsModel).toJson(),
      'payroll_entries': payrollEntries.map((e) => (e as PayrollEntryModel).toJson()).toList(),
      'payslips': payslips.map((e) => (e as PayslipModel).toJson()).toList(),
    };
  }

  PayrollDetailsResponse toEntity() {
    return PayrollDetailsResponse(
      success: success,
      payrollStatistics: (payrollStatistics as PayrollStatisticsModel).toEntity(),
      payrollEntries: payrollEntries.map((e) => (e as PayrollEntryModel).toEntity()).toList(),
      payslips: payslips.map((e) => (e as PayslipModel).toEntity()).toList(),
    );
  }
}