
import '../../entities/payslip.dart';
import '../../entities/create_payslip_request.dart';
import '../../repositories/payslip_repository.dart';

class CreatePayslipUseCase {
  final PayslipRepository repository;

  CreatePayslipUseCase(this.repository);

  Future<Payslip> call(CreatePayslipRequest request) async {
    return await repository.createPayslip(request);
  }
}