import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../ViewModels/audit_main_viewmodel.dart';
import 'package:cryphoria_mobile/features/domain/entities/audit_report.dart';
import 'overall_assessment_screen.dart';

class AuditResultsScreen extends ConsumerStatefulWidget {
  final AuditReport? auditReport;
  final String? contractName;
  final String? fileName;
  final String? auditId;

  const AuditResultsScreen({
    super.key,
    this.auditReport,
    this.contractName,
    this.fileName,
    this.auditId,
  });

  @override
  ConsumerState<AuditResultsScreen> createState() => _AuditResultsScreenState();
}

class _AuditResultsScreenState extends ConsumerState<AuditResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AuditMainViewModel _mainViewModel;
  AuditReport? _currentAuditReport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize ViewModels
    _mainViewModel = ref.read(auditMainViewModelProvider);
    
    // Set audit report if provided directly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("🔍 UI: initState - widget.auditReport = ${widget.auditReport}");
      print("🔍 UI: initState - _mainViewModel.currentAuditReport = ${_mainViewModel.currentAuditReport}");
      
      if (widget.auditReport != null) {
        print("🔍 UI: Using widget.auditReport");
        print("🔍 UI: widget.auditReport.vulnerabilities.length = ${widget.auditReport!.vulnerabilities.length}");
        _currentAuditReport = widget.auditReport;
        setState(() {});
      } else if (_mainViewModel.currentAuditReport != null) {
        print("🔍 UI: Using _mainViewModel.currentAuditReport");
        print("🔍 UI: _mainViewModel.currentAuditReport.vulnerabilities.length = ${_mainViewModel.currentAuditReport!.vulnerabilities.length}");
        _currentAuditReport = _mainViewModel.currentAuditReport;
        setState(() {});
      }
      
      print("🔍 UI: Final _currentAuditReport = ${_currentAuditReport}");
      if (_currentAuditReport != null) {
        print("🔍 UI: Final _currentAuditReport.vulnerabilities.length = ${_currentAuditReport!.vulnerabilities.length}");
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(auditMainViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          if (_currentAuditReport == null) {
            return _buildNoReportState();
          }

          return _buildResultsContent(_currentAuditReport!);
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
              'The audit report is not available. Please restart the audit process.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9747FF),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(AuditReport report) {
    
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
                // Contract Information Section
                _buildContractInfoSection(report),
                
                const SizedBox(height: 16),
                
                // Audit Summary Section
                _buildAuditSummarySection(report),
                
                const SizedBox(height: 16),
                
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
                
                const SizedBox(height: 16),
                
                // Recommendations Section
                _buildExpandableSection(
                  title: 'Recommendations',
                  count: report.recommendations.length,
                  subtitle: 'Action Items',
                  icon: Icons.lightbulb,
                  color: Colors.blue,
                  content: _buildRecommendationsContent(report),
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
    print("🔍 UI: _buildVulnerabilitiesContent called");
    print("🔍 UI: report.vulnerabilities.length = ${report.vulnerabilities.length}");
    print("🔍 UI: report.vulnerabilities = ${report.vulnerabilities}");
    
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

  Widget _buildContractInfoSection(AuditReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Contract Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Contract Name', report.contractName),
          _buildInfoRow('File Name', report.fileName),
          _buildInfoRow('Audit ID', report.id),
          _buildInfoRow('Status', report.status.name.toUpperCase()),
          _buildInfoRow('Audit Date', _formatDate(report.timestamp)),
          _buildInfoRow('Overall Score', '${report.overallScore.toStringAsFixed(1)}/100'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditSummarySection(AuditReport report) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audit Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Critical Issues',
                  '${report.securityAnalysis.criticalIssues}',
                  Icons.error,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'High Risk',
                  '${report.securityAnalysis.highRiskIssues}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryStatItem(
                  'Medium Risk',
                  '${report.securityAnalysis.mediumRiskIssues}',
                  Icons.info,
                  Colors.yellow[700]!,
                ),
              ),
              Expanded(
                child: _buildSummaryStatItem(
                  'Low Risk',
                  '${report.securityAnalysis.lowRiskIssues}',
                  Icons.check_circle,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsContent(AuditReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${report.recommendations.length} recommendations were provided to improve your smart contract security and performance.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        
        // List recommendations
        ...report.recommendations.map((recommendation) => 
          _buildRecommendationItem(recommendation)),
      ],
    );
  }

  Widget _buildRecommendationItem(Recommendation recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPriorityColor(recommendation.priority).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation.priority),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  recommendation.priority.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                recommendation.category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            recommendation.description,
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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
          contractName: widget.contractName ?? 'Unknown Contract',
          fileName: widget.fileName ?? 'contract.sol',
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
