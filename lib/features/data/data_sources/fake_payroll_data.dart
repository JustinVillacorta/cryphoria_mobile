import '../../domain/entities/payroll_history.dart';

class FakePayrollDataSource {
  List<PayrollHistory> getPayrollHistory() {
    return [
      PayrollHistory(
        avatarUrl: 'https://via.placeholder.com/150',
        name: 'Yuno Cruz',
        subtitle: '0x238…c68',
        amount: '+\$123',
        date: '21 June 2025',
        isFailed: true,
        reason: 'Wallet not found',
      ),
      PayrollHistory(
        avatarUrl: 'https://via.placeholder.com/150',
        name: 'Yuno Cruz',
        subtitle: '0x238…c68',
        amount: '+\$123',
        date: '21 June 2025',
        isFailed: false,
      ),
      // Add more items as needed
    ];
  }
}