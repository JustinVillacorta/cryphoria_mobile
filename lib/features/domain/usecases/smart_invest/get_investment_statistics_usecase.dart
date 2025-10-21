import '../../../domain/entities/investment_report.dart';
import '../../../data/data_sources/smart_invest_remote_data_source.dart';

class GetInvestmentStatisticsUseCase {
  final SmartInvestRemoteDataSource _remoteDataSource;

  GetInvestmentStatisticsUseCase({
    required SmartInvestRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  Future<InvestmentStatistics> execute() async {
    return await _remoteDataSource.getInvestmentStatistics();
  }
}
