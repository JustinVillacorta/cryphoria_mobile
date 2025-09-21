// lib/features/data/datasources/employee_remote_data_source.dart
abstract class EmployeeRemoteDataSource {
  Future<Map<String, dynamic>> getEmployeeData(String employeeId);
  Future<Map<String, dynamic>> getWalletData(String employeeId);
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId);
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5});
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  // This would typically use http, dio, or your preferred networking library

  @override
  Future<Map<String, dynamic>> getEmployeeData(String employeeId) async {
    // Mock data - replace with actual API call
    await Future.delayed(Duration(milliseconds: 500));
    return {
      'id': employeeId,
      'name': 'Anna',
      'avatar_url': '',
    };
  }

  @override
  Future<Map<String, dynamic>> getWalletData(String employeeId) async {
    await Future.delayed(Duration(milliseconds: 300));
    return {
      'currency': 'ETH',
      'balance': 67980.0,
      'converted_amount': 12230.0,
      'converted_currency': 'PHP',
    };
  }

  @override
  Future<Map<String, dynamic>> getPayoutInfo(String employeeId) async {
    await Future.delayed(Duration(milliseconds: 200));
    return {
      'next_payout_date': '2023-06-30T00:00:00Z',
      'frequency': 'Monthly',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentTransactions(String employeeId, {int limit = 5}) async {
    await Future.delayed(Duration(milliseconds: 400));
    return [
      {
        'id': '0x12b...b10j',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '850.00 USD',
        'status': 'paid'
      },
      {
        'id': '0x12b...b10j',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '850.00 USD',
        'status': 'paid'
      },
      {
        'id': '0x12b...b10j',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '850.00 USD',
        'status': 'paid'
      },
      {
        'id': '0x12b...b10j',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '850.00 USD',
        'status': 'paid'
      },
      {
        'id': '0x12b...b10j',
        'date': 'May 31, 2023',
        'amount': '0.45 ETH',
        'usdAmount': '850.00 USD',
        'status': 'paid'
      },
    ];
  }
}