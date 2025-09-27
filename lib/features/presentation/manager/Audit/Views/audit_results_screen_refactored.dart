import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../ViewModels/audit_results_viewmodel.dart';
import '../ViewModels/audit_main_viewmodel.dart';
import 'package:cryphoria_mobile/features/domain/entities/audit_report.dart';
import 'overall_assessment_screen.dart';

class AuditResultsScreenRefactored extends ConsumerStatefulWidget {
  final String contractName;
  final String fileName;

  const AuditResultsScreenRefactored({
    super.key,
    required this.contractName,
    required this.fileName,
  });

  @override
  ConsumerState<AuditResultsScreenRefactored> createState() => _AuditResultsScreenRefactoredState();
}

class _AuditResultsScreenRefactoredState extends ConsumerState<AuditResultsScreenRefactored>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AuditResultsViewModel _resultsViewModel;
  late AuditMainViewModel _mainViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize ViewModels
    _resultsViewModel = ref.read(auditResultsViewModelProvider);
    _mainViewModel = ref.read(auditMainViewModelProvider);
    
    // Add listeners
    _resultsViewModel.addListener(_onResultsViewModelChanged);
    
    // Load audit report if we have an audit ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainViewModel.currentAuditId != null) {
        _resultsViewModel.loadAuditReport(_mainViewModel.currentAuditId!);
      }
    });
  }

  @override
  void dispose() {
    _resultsViewModel.removeListener(_onResultsViewModelChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onResultsViewModelChanged() {
    if (_resultsViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_resultsViewModel.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    // Update main ViewModel if we got a report
    if (_resultsViewModel.auditReport != null) {
      _mainViewModel.setCurrentAuditReport(_resultsViewModel.auditReport!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsViewModel = ref.watch(auditResultsViewModelProvider);
    ref.watch(auditMainViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          if (resultsViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
              ),
            );
          }

          if (resultsViewModel.error != null) {
            return _buildErrorState(resultsViewModel.error!);
          }

          if (!resultsViewModel.hasReport) {
            return _buildNoReportState();
          }

          return _buildResultsContent(resultsViewModel);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Audit Results',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Text(
                    '${widget.contractName} • ${widget.fileName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_mainViewModel.currentAuditId != null) {
                  _resultsViewModel.loadAuditReport(_mainViewModel.currentAuditId!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9747FF),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoReportState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Report Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The audit report is not available yet. Please try again later.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(AuditResultsViewModel viewModel) {
    final report = viewModel.auditReport!;
    
    return Column(
      children: [
        // Progress indicators for audit flow
        _buildProgressIndicators(),
        
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: viewModel.setSelectedTab,
            indicator: BoxDecoration(
              color: const Color(0xFF9747FF),
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'Security Analysis'),
              Tab(text: 'Vulnerabilities'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSecurityAnalysisTab(report),
              _buildVulnerabilitiesTab(viewModel),
            ],
          ),
        ),
        
        // Overall Assessment Button
        _buildAssessmentButton(),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildProgressStep(1, false, true),
          _buildProgressLine(true),
          _buildProgressStep(2, false, true),
          _buildProgressLine(true),
          _buildProgressStep(3, true, false),
          _buildProgressLine(false),
          _buildProgressStep(4, false, false),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? const Color(0xFF9747FF) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFF9747FF) : Colors.grey[300],
      ),
    );
  }

  Widget _buildSecurityAnalysisTab(AuditReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Score Card
          _buildSecurityScoreCard(report),
          const SizedBox(height: 24),
          
          // Issue Breakdown
          _buildIssueBreakdown(report),
          const SizedBox(height: 24),
          
          // Security Checks
          _buildSecurityChecks(report.securityAnalysis.completedChecks),
        ],
      ),
    );
  }

  Widget _buildSecurityScoreCard(AuditReport report) {
    final score = report.overallScore;
    final color = _resultsViewModel.riskColor;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Security Score',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${score.toInt()}%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _resultsViewModel.riskLevel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueBreakdown(AuditReport report) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Issue Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildIssueItem('Critical', _resultsViewModel.criticalCount, Colors.red),
          _buildIssueItem('High', _resultsViewModel.highCount, Colors.orange),
          _buildIssueItem('Medium', _resultsViewModel.mediumCount, Colors.yellow[700]!),
          _buildIssueItem('Low', _resultsViewModel.lowCount, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildIssueItem(String severity, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              severity,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityChecks(List<SecurityCheck> checks) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Checks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...checks.map((check) => _buildCheckItem(check)),
        ],
      ),
    );
  }

  Widget _buildCheckItem(SecurityCheck check) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            check.passed ? Icons.check_circle : Icons.cancel,
            color: check.passed ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (check.description.isNotEmpty)
                  Text(
                    check.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                if (!check.passed && check.failureReason != null)
                  Text(
                    check.failureReason!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilitiesTab(AuditResultsViewModel viewModel) {
    return Column(
      children: [
        // Filter buttons
        _buildVulnerabilityFilters(viewModel),
        
        // Vulnerabilities list
        Expanded(
          child: viewModel.filteredVulnerabilities.isEmpty
              ? _buildNoVulnerabilitiesState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: viewModel.filteredVulnerabilities.length,
                  itemBuilder: (context, index) {
                    final vulnerability = viewModel.filteredVulnerabilities[index];
                    return _buildVulnerabilityCard(vulnerability);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVulnerabilityFilters(AuditResultsViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null, viewModel),
            const SizedBox(width: 8),
            _buildFilterChip('Critical', Severity.critical, viewModel),
            const SizedBox(width: 8),
            _buildFilterChip('High', Severity.high, viewModel),
            const SizedBox(width: 8),
            _buildFilterChip('Medium', Severity.medium, viewModel),
            const SizedBox(width: 8),
            _buildFilterChip('Low', Severity.low, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Severity? severity, AuditResultsViewModel viewModel) {
    final isSelected = viewModel.selectedSeverityFilter == severity;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        viewModel.filterBySeverity(selected ? severity : null);
      },
      selectedColor: const Color(0xFF9747FF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF9747FF),
    );
  }

  Widget _buildNoVulnerabilitiesState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 64,
            color: Colors.green,
          ),
          SizedBox(height: 16),
          Text(
            'No Vulnerabilities Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Great! Your smart contract appears to be secure.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityCard(Vulnerability vulnerability) {
    Color severityColor;
    switch (vulnerability.severity) {
      case Severity.critical:
        severityColor = Colors.red;
        break;
      case Severity.high:
        severityColor = Colors.orange;
        break;
      case Severity.medium:
        severityColor = Colors.yellow[700]!;
        break;
      case Severity.low:
        severityColor = Colors.blue;
        break;
      default:
        severityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vulnerability.severity.name.toUpperCase(),
                  style: TextStyle(
                    color: severityColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                vulnerability.category,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            vulnerability.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vulnerability.description,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          if (vulnerability.remediation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Remediation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vulnerability.remediation!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessmentButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OverallAssessmentScreen(
              contractName: widget.contractName,
              fileName: widget.fileName,
            ),
          ),
        );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9747FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'View Overall Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
