import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/overall_assessment_screen.dart';
import 'package:cryphoria_mobile/features/data/notifiers/audit_notifier.dart';
import 'package:cryphoria_mobile/features/domain/entities/audit_report.dart';

class AuditResultsScreen extends StatefulWidget {
  final String contractName;
  final String fileName;

  const AuditResultsScreen({
    super.key,
    required this.contractName,
    required this.fileName,
  });

  @override
  State<AuditResultsScreen> createState() => _AuditResultsScreenState();
}

class _AuditResultsScreenState extends State<AuditResultsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _hasTriedToFetchReport = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _tryFetchReportIfNeeded(AuditNotifier auditNotifier) {
    if (!_hasTriedToFetchReport && 
        auditNotifier.currentAuditReport == null && 
        auditNotifier.currentAuditId != null && 
        !auditNotifier.isLoading) {
      _hasTriedToFetchReport = true;
      print("🔄 AuditResultsScreen: Attempting to fetch missing audit report...");
      auditNotifier.getAuditReport(auditNotifier.currentAuditId!);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      ),
      body: Consumer<AuditNotifier>(
        builder: (context, auditNotifier, child) {
          final auditReport = auditNotifier.currentAuditReport;
          
          // Try to fetch the report if it's missing
          _tryFetchReportIfNeeded(auditNotifier);
          
          if (auditReport == null) {
            // Show different message based on whether we have an error or are still loading
            String loadingMessage = 'Loading audit results...';
            IconData loadingIcon = Icons.hourglass_empty;
            
            if (auditNotifier.error != null) {
              loadingMessage = 'Fetching audit results...';
              loadingIcon = Icons.refresh;
            } else if (auditNotifier.currentAuditId != null && !auditNotifier.isLoading) {
              loadingMessage = 'Processing audit data...';
              loadingIcon = Icons.analytics;
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(loadingIcon, size: 48, color: Colors.purple),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.purple),
                  const SizedBox(height: 16),
                  Text(
                    loadingMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  if (auditNotifier.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Retrying...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (auditNotifier.currentAuditId != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Audit ID: ${auditNotifier.currentAuditId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          // Calculate summary data from real audit report
          final totalVulnerabilities = auditReport.vulnerabilities.length;
          final criticalVulnerabilities = auditReport.vulnerabilities
              .where((v) => v.severity == Severity.critical)
              .length;
          final gasOptimizations = auditReport.gasOptimization.suggestions.length;
          
          // Determine risk level based on vulnerabilities
          String getRiskLevel() {
            if (criticalVulnerabilities > 0) return 'Critical Risk';
            if (auditReport.vulnerabilities.where((v) => v.severity == Severity.high).isNotEmpty) return 'High Risk';
            if (auditReport.vulnerabilities.where((v) => v.severity == Severity.medium).isNotEmpty) return 'Medium Risk';
            return 'Low Risk';
          }
          
          Color getRiskColor() {
            final riskLevel = getRiskLevel();
            switch (riskLevel) {
              case 'Critical Risk': return Colors.red;
              case 'High Risk': return Colors.orange;
              case 'Medium Risk': return Colors.yellow[700]!;
              default: return Colors.green;
            }
          }

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
                    Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                    Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Results header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Audit Results',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getRiskColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        getRiskLevel(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: getRiskColor().withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Summary cards with real data
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Vulnerabilities',
                        totalVulnerabilities.toString(),
                        'Issues\nDetected',
                        Colors.red[50]!,
                        Colors.red[700]!,
                        Icons.warning_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        'Gas\nOptimization',
                        gasOptimizations.toString(),
                        'Improvements\nPossible',
                        Colors.green[50]!,
                        Colors.green[700]!,
                        Icons.speed_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs: const [
                Tab(text: 'Vulnerabilities'),
                Tab(text: 'Gas Optimization'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVulnerabilitiesTab(auditReport),
                _buildGasOptimizationTab(auditReport),
              ],
            ),
          ),
          
          // View Overall Assessment button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
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
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
        },
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? Colors.purple : Colors.grey[300],
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
        color: isCompleted ? Colors.purple : Colors.grey[300],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, String subtitle, Color bgColor, Color textColor, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 24,
              color: textColor,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilitiesTab(AuditReport auditReport) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section with enhanced information
          Container(
            padding: const EdgeInsets.all(16),
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
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Vulnerability Analysis Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  auditReport.vulnerabilities.isEmpty 
                    ? 'Great news! No vulnerabilities were detected in your smart contract. This indicates good security practices.'
                    : '${auditReport.vulnerabilities.length} vulnerabilities were detected in the smart contract. These issues should be addressed before deployment to ensure security and reliability.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (auditReport.vulnerabilities.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildSeverityChip('Critical', auditReport.vulnerabilities.where((v) => v.severity == Severity.critical).length, Colors.red),
                      _buildSeverityChip('High', auditReport.vulnerabilities.where((v) => v.severity == Severity.high).length, Colors.orange),
                      _buildSeverityChip('Medium', auditReport.vulnerabilities.where((v) => v.severity == Severity.medium).length, Colors.yellow[700]!),
                      _buildSeverityChip('Low', auditReport.vulnerabilities.where((v) => v.severity == Severity.low).length, Colors.blue),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Vulnerabilities list or empty state
          if (auditReport.vulnerabilities.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.security, size: 64, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No Vulnerabilities Found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your smart contract passed all security checks.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Build vulnerability cards from real data
            ...auditReport.vulnerabilities.asMap().entries.map((entry) {
              final index = entry.key;
              final vulnerability = entry.value;
              Color bgColor;
              Color textColor;
              
              switch (vulnerability.severity) {
                case Severity.critical:
                  bgColor = Colors.red[100]!;
                  textColor = Colors.red[800]!;
                  break;
                case Severity.high:
                  bgColor = Colors.orange[100]!;
                  textColor = Colors.orange[800]!;
                  break;
                case Severity.medium:
                  bgColor = Colors.yellow[100]!;
                  textColor = Colors.yellow[800]!;
                  break;
                case Severity.low:
                  bgColor = Colors.blue[100]!;
                  textColor = Colors.blue[800]!;
                  break;
                default:
                  bgColor = Colors.grey[100]!;
                  textColor = Colors.grey[800]!;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildVulnerabilityCard(
                  vulnerability.title,
                  vulnerability.severity.name.toUpperCase(),
                  vulnerability.lineNumbers.isNotEmpty 
                    ? 'Line ${vulnerability.lineNumbers.join(", ")}'
                    : 'Multiple locations',
                  bgColor,
                  textColor,
                  true,
                  description: vulnerability.description,
                  remediation: vulnerability.remediation,
                  vulnerabilityId: vulnerability.id,
                  category: vulnerability.category,
                  index: index + 1,
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildGasOptimizationTab(AuditReport auditReport) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.speed, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Gas Optimization Analysis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  auditReport.gasOptimization.suggestions.isEmpty
                    ? 'Your smart contract is already well-optimized for gas usage. No significant improvements found.'
                    : 'The following ${auditReport.gasOptimization.suggestions.length} gas optimization opportunities were identified to reduce transaction costs.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                if (auditReport.gasOptimization.estimatedGasSaved > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.savings, color: Colors.green[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Total Savings: ${auditReport.gasOptimization.estimatedGasSaved.toStringAsFixed(0)} gas',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Optimization suggestions or empty state
          if (auditReport.gasOptimization.suggestions.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Already Optimized',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your contract follows gas optimization best practices.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Build optimization cards from real data
            ...auditReport.gasOptimization.suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              
              // Color based on priority
              Color bgColor;
              Color textColor;
              switch (suggestion.priority) {
                case Priority.high:
                  bgColor = Colors.orange[100]!;
                  textColor = Colors.orange[800]!;
                  break;
                case Priority.medium:
                  bgColor = Colors.blue[100]!;
                  textColor = Colors.blue[800]!;
                  break;
                case Priority.low:
                  bgColor = Colors.green[100]!;
                  textColor = Colors.green[800]!;
                  break;
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildOptimizationCard(
                  suggestion.suggestion,
                  bgColor,
                  textColor,
                  function: suggestion.function,
                  estimatedSaving: suggestion.estimatedSaving,
                  priority: suggestion.priority.name.toUpperCase(),
                  index: index + 1,
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildVulnerabilityCard(
    String title, 
    String severity, 
    String location, 
    Color bgColor, 
    Color textColor, 
    bool isExpandable, {
    String? description,
    String? remediation,
    String? vulnerabilityId,
    String? category,
    int? index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: index != null
                    ? Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      )
                    : Icon(Icons.warning, color: textColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            severity,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          Text(' • ', style: TextStyle(color: textColor)),
                          Text(
                            location,
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpandable)
                Icon(Icons.expand_more, color: textColor),
            ],
          ),
          if (category != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: textColor.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  'Category: $category',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                if (vulnerabilityId != null && vulnerabilityId.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.fingerprint, size: 16, color: textColor.withOpacity(0.7)),
                  const SizedBox(width: 4),
                  Text(
                    'ID: $vulnerabilityId',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (remediation != null && remediation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, size: 16, color: textColor),
                      const SizedBox(width: 4),
                      Text(
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remediation,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withOpacity(0.9),
                      height: 1.3,
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

  Widget _buildOptimizationCard(
    String title, 
    Color bgColor, 
    Color textColor, {
    String? function,
    int? estimatedSaving,
    String? priority,
    int? index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: index != null
                    ? Text(
                        '$index',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      )
                    : Icon(Icons.check_circle, color: textColor, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    if (priority != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$priority PRIORITY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (function != null || estimatedSaving != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (function != null) ...[
                    Row(
                      children: [
                        Icon(Icons.code, size: 16, color: textColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Function',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      function,
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                        color: textColor.withOpacity(0.9),
                      ),
                    ),
                    if (estimatedSaving != null) const SizedBox(height: 8),
                  ],
                  if (estimatedSaving != null) ...[
                    Row(
                      children: [
                        Icon(Icons.trending_down, size: 16, color: textColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'Estimated Gas Saving',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${estimatedSaving.toStringAsFixed(0)} gas',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $count',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
