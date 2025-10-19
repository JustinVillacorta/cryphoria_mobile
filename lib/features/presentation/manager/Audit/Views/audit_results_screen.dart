import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../ViewModels/audit_results_viewmodel.dart';
import '../ViewModels/audit_main_viewmodel.dart';
import 'package:cryphoria_mobile/features/domain/entities/audit_report.dart';
import 'overall_assessment_screen.dart';

class AuditResultsScreen extends ConsumerStatefulWidget {
  final String contractName;
  final String fileName;
  final String? auditId;

  const AuditResultsScreen({
    super.key,
    required this.contractName,
    required this.fileName,
    this.auditId,
  });

  @override
  ConsumerState<AuditResultsScreen> createState() => _AuditResultsScreenState();
}

class _AuditResultsScreenState extends ConsumerState<AuditResultsScreen>
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
    
    // Load audit report if we have an audit ID and not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mainViewModel.currentAuditId != null && 
          _resultsViewModel.auditReport == null && 
          !_resultsViewModel.isLoading) {
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
      print("❌ AuditResultsScreen: Error in results viewmodel - ${_resultsViewModel.error}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading audit results: ${_resultsViewModel.error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
    
    // Update main ViewModel if we got a report
    if (_resultsViewModel.auditReport != null) {
      print("✅ AuditResultsScreen: Successfully loaded audit report");
      _mainViewModel.setCurrentAuditReport(_resultsViewModel.auditReport!);
    }
    
    // Debug loading state
    if (_resultsViewModel.isLoading) {
      print("🔄 AuditResultsScreen: Loading audit report...");
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultsViewModel = ref.watch(auditResultsViewModelProvider);
    ref.watch(auditMainViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
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
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Smart Audit Contract',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
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
              'The audit report is not available yet. This might be because:\n• The audit is still processing\n• There was an error generating the report\n• The audit ID is invalid',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print("🔄 Retrying to load audit report...");
                if (_mainViewModel.currentAuditId != null) {
                  print("📊 Current audit ID: ${_mainViewModel.currentAuditId}");
                  _resultsViewModel.loadAuditReport(_mainViewModel.currentAuditId!);
                } else {
                  print("❌ No audit ID available in main viewmodel");
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No audit ID available. Please restart the audit process.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9747FF),
              ),
              child: const Text(
                'Retry Loading Report',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Audit ID: ${_mainViewModel.currentAuditId ?? 'Not available'}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
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
        // Header with progress
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              Row(
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
              
              const SizedBox(height: 12),
              
              // Progress labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('AI Analysis', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Audit Results', style: TextStyle(fontSize: 12, color: Color(0xFF9747FF), fontWeight: FontWeight.w600)),
                  Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Audit Results',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRiskColor(report.securityAnalysis.criticalIssues),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getRiskLevel(report.securityAnalysis.criticalIssues),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Vulnerabilities Section
                _buildExpandableSection(
                  title: 'Vulnerabilities',
                  count: report.vulnerabilities.length,
                  subtitle: 'Issues Detected',
                  icon: Icons.warning,
                  color: Colors.red,
                  content: _buildVulnerabilitiesContent(report),
                ),
                
                const SizedBox(height: 16),
                
                // Gas Optimization Section
                _buildExpandableSection(
                  title: 'Gas Optimization',
                  count: report.gasOptimization.suggestions.length,
                  subtitle: 'Improvements Possible',
                  icon: Icons.tune,
                  color: Colors.green,
                  content: _buildGasOptimizationContent(report),
                ),
                
                const SizedBox(height: 32),
                
                // View Overall Assessment Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToOverallAssessment(report),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Overall Assessment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required int count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [content],
      ),
    );
  }

  Widget _buildVulnerabilitiesContent(AuditReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${report.vulnerabilities.length} vulnerabilities were detected in the smart contract. These issues should be addressed before deployment.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        
        // List vulnerabilities
        ...report.vulnerabilities.map((vulnerability) => 
          _buildVulnerabilityItem(vulnerability)),
      ],
    );
  }

  Widget _buildVulnerabilityItem(Vulnerability vulnerability) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSeverityColor(vulnerability.severity).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(vulnerability.severity),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  vulnerability.severity.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (vulnerability.lineNumbers.isNotEmpty)
                Text(
                  'Line ${vulnerability.lineNumbers.first}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            vulnerability.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            vulnerability.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
          if (vulnerability.remediation != null) ...[
            const SizedBox(height: 8),
            const Text(
              'Recommendation',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  Widget _buildGasOptimizationContent(AuditReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${report.gasOptimization.suggestions.length} gas optimization opportunities were identified. Implementing these could reduce transaction costs.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        
        // List gas optimizations
        ...report.gasOptimization.suggestions.map((suggestion) => 
          _buildGasOptimizationItem(suggestion)),
      ],
    );
  }

  Widget _buildGasOptimizationItem(GasOptimizationSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OPTIMIZATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            suggestion.function.isNotEmpty ? suggestion.function : 'General Optimization',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            suggestion.suggestion,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskLevel(int criticalIssues) {
    if (criticalIssues > 0) return 'Critical Risk';
    return 'Low Risk';
  }

  Color _getRiskColor(int criticalIssues) {
    if (criticalIssues > 0) return Colors.red;
    return Colors.green;
  }

  Color _getSeverityColor(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return Colors.red;
      case Severity.high:
        return Colors.orange;
      case Severity.medium:
        return Colors.yellow[700]!;
      case Severity.low:
        return Colors.blue;
      case Severity.info:
        return Colors.grey;
    }
  }

  void _navigateToOverallAssessment(AuditReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OverallAssessmentScreen(
          contractName: widget.contractName,
          fileName: widget.fileName,
        ),
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
}
