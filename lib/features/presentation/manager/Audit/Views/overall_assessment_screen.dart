import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../../../../domain/entities/audit_report.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';

class OverallAssessmentScreen extends ConsumerWidget {
  final String contractName;
  final String fileName;

  const OverallAssessmentScreen({
    super.key,
    required this.contractName,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mainState = ref.watch(auditFlowViewModelProvider);
    final auditReport = mainState.currentAuditReport;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: auditReport == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assessment, size: 64, color: Colors.purple[300]),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.purple),
                  const SizedBox(height: 16),
                  const Text(
                    'Loading assessment data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _buildAssessmentContent(context, auditReport, ref),
    );
  }

  Widget _buildAssessmentContent(BuildContext context, AuditReport auditReport, WidgetRef ref) {
    final criticalVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.critical).length;
    final highVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.high).length;
    final mediumVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.medium).length;
    final lowVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.low).length;

    final gasOptimizations = auditReport.gasOptimization.suggestions.length;

    String riskLevel;
    MaterialColor riskColor;
    String riskMessage;

    if (criticalVulns > 0) {
      riskLevel = 'Critical';
      riskColor = Colors.red;
      riskMessage = 'This contract has $criticalVulns critical vulnerabilities that could lead to financial loss.';
    } else if (highVulns > 0) {
      riskLevel = 'High';
      riskColor = Colors.orange;
      riskMessage = 'This contract has $highVulns high-severity vulnerabilities that should be addressed before deployment.';
    } else if (mediumVulns > 0) {
      riskLevel = 'Medium';
      riskColor = Colors.amber;
      riskMessage = 'This contract has $mediumVulns medium-severity vulnerabilities that should be reviewed and addressed.';
    } else if (lowVulns > 0) {
      riskLevel = 'Low';
      riskColor = Colors.blue;
      riskMessage = 'This contract has $lowVulns minor vulnerabilities that pose minimal risk but should be considered.';
    } else {
      riskLevel = 'Secure';
      riskColor = Colors.green;
      riskMessage = 'This contract passed all security checks with no vulnerabilities detected.';
    }

    String gasOptLevel;
    MaterialColor gasOptColor;
    String gasOptMessage;

    final gasOptScore = auditReport.gasOptimization.optimizationScore;

    if (gasOptScore >= 80) {
      gasOptLevel = 'Excellent';
      gasOptColor = Colors.green;
      gasOptMessage = 'Your contract is well-optimized for gas usage with score ${gasOptScore.toStringAsFixed(1)}/100.';
    } else if (gasOptScore >= 60) {
      gasOptLevel = 'Good';
      gasOptColor = Colors.blue;
      gasOptMessage = 'Good optimization level with score ${gasOptScore.toStringAsFixed(1)}/100. Some improvements possible.';
    } else if (gasOptScore >= 40) {
      gasOptLevel = 'Moderate';
      gasOptColor = Colors.orange;
      gasOptMessage = 'Moderate optimization level with score ${gasOptScore.toStringAsFixed(1)}/100. Several opportunities for improvement.';
    } else {
      gasOptLevel = 'Poor';
      gasOptColor = Colors.red;
      gasOptMessage = 'Low optimization score ${gasOptScore.toStringAsFixed(1)}/100. Significant improvements needed.';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  _buildProgressStep(1, false, true),
                  _buildProgressLine(true),
                  _buildProgressStep(2, false, true),
                  _buildProgressLine(true),
                  _buildProgressStep(3, false, true),
                  _buildProgressLine(true),
                  _buildProgressStep(4, true, false),
                ],
              ),

              const SizedBox(height: 12),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('AI Analysis', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Overall Assessment',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContractDetailsSection(auditReport),

                const SizedBox(height: 16),

                _buildRiskAssessmentCard(auditReport, riskLevel, riskColor, riskMessage, criticalVulns, gasOptimizations),

                const SizedBox(height: 16),

                _buildGasOptimizationCard(auditReport, gasOptLevel, gasOptColor, gasOptMessage, gasOptimizations),

                const SizedBox(height: 16),

                _buildCodeQualitySection(auditReport),

                const SizedBox(height: 24),

                _buildSummaryStatistics(auditReport),

                const SizedBox(height: 16),

                _buildRecommendationsSection(auditReport),

                const SizedBox(height: 32),

                _buildActionButtons(context, ref),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessmentCard(AuditReport auditReport, String riskLevel, MaterialColor riskColor, String riskMessage, int criticalVulns, int gasOptimizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: riskColor[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Risk Assessment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  riskLevel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: riskColor[800],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.warning, 
                color: riskColor[700], 
                size: 20
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  riskMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            'Key Findings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          _buildKeyFinding('${auditReport.vulnerabilities.length} vulnerabilities detected${criticalVulns > 0 ? ' ($criticalVulns critical)' : ''}'),

          if (gasOptimizations > 0)
            _buildKeyFinding('$gasOptimizations gas optimization opportunities identified'),

          if (auditReport.recommendations.isNotEmpty)
            _buildKeyFinding('${auditReport.recommendations.length} actionable recommendations provided'),

          _buildKeyFinding('Overall security score: ${auditReport.overallScore.toStringAsFixed(1)}/100'),
        ],
      ),
    );
  }

  Widget _buildKeyFinding(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasOptimizationCard(AuditReport auditReport, String gasOptLevel, MaterialColor gasOptColor, String gasOptMessage, int gasOptimizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gasOptColor[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gasOptColor[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed, 
                color: gasOptColor[700], 
                size: 24
              ),
              const SizedBox(width: 12),
              const Text(
                'Gas Optimization',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Optimization Level',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Score: ${auditReport.gasOptimization.optimizationScore.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: gasOptColor[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  gasOptLevel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: gasOptColor[800],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            gasOptMessage,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              height: 1.4,
            ),
          ),

          if (auditReport.gasOptimization.suggestions.isNotEmpty) ...[
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: auditReport.gasOptimization.suggestions.take(4).map((suggestion) =>
                _buildOptimizationPoint(suggestion.suggestion)
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptimizationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatistics(AuditReport auditReport) {
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
                child: _buildStatItem(
                  'Total Issues',
                  '${auditReport.vulnerabilities.length}',
                  Icons.bug_report,
                  Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Security Score',
                  '${auditReport.overallScore.toStringAsFixed(0)}/100',
                  Icons.security,
                  auditReport.overallScore >= 70 ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Gas Score',
                  '${auditReport.gasOptimization.optimizationScore.toStringAsFixed(0)}/100',
                  Icons.speed,
                  auditReport.gasOptimization.optimizationScore >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Recommendations',
                  '${auditReport.recommendations.length}',
                  Icons.lightbulb,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color[600],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color[700],
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

  Widget _buildRecommendationsSection(AuditReport auditReport) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommendations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        if (auditReport.recommendations.isNotEmpty) ...[
          ...auditReport.recommendations.map((recommendation) => 
            _buildRecommendationCard(
              recommendation.title,
              recommendation.description,
              _getPriorityColor(recommendation.priority),
              recommendation.category,
              recommendation.priority,
            )
          )
        ] else ...[
          _buildRecommendationCard(
            'General Improvements',
            'Review the audit findings and implement necessary security measures.',
            Colors.blue,
            'General',
            Priority.medium,
          ),
        ],
      ],
    );
  }

  MaterialColor _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.blue;
    }
  }

  Widget _buildRecommendationCard(
    String title, 
    String description, 
    MaterialColor color,
    [String? category,
    Priority? priority]
  ) {
    IconData categoryIcon = Icons.lightbulb_outline;
    if (category != null) {
      switch (category.toLowerCase()) {
        case 'security':
          categoryIcon = Icons.security;
          break;
        case 'ai analysis':
          categoryIcon = Icons.psychology;
          break;
        case 'gas optimization':
          categoryIcon = Icons.speed;
          break;
        case 'general':
          categoryIcon = Icons.checklist;
          break;
        default:
          categoryIcon = Icons.lightbulb_outline;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon,
                  color: color[700],
                  size: 20,
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
                        color: color[700],
                      ),
                    ),
                    if (category != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (priority != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color[300]!),
                  ),
                  child: Text(
                    priority.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color[800],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              'Back to Results',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDownloadDialog(context, ref),
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
                Icon(Icons.download, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Download Full Report',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContractDetailsSection(AuditReport auditReport) {
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
                'Contract Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildDetailRow('Contract Name', auditReport.contractName),
          _buildDetailRow('File Name', auditReport.fileName),
          _buildDetailRow('Audit ID', auditReport.id),
          _buildDetailRow('Status', auditReport.status.name.toUpperCase()),
          _buildDetailRow('Audit Date', _formatDate(auditReport.timestamp)),
          _buildDetailRow('Lines of Code', '${auditReport.codeQuality.linesOfCode}'),
          _buildDetailRow('Complexity Score', '${auditReport.codeQuality.complexityScore}/10'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  Widget _buildCodeQualitySection(AuditReport auditReport) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: Colors.purple[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Code Quality Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQualityStatItem(
                  'Quality Score',
                  '${auditReport.codeQuality.qualityScore.toStringAsFixed(1)}/100',
                  Icons.star,
                  auditReport.codeQuality.qualityScore >= 70 ? Colors.green : Colors.orange,
                ),
              ),
              Expanded(
                child: _buildQualityStatItem(
                  'Lines of Code',
                  '${auditReport.codeQuality.linesOfCode}',
                  Icons.code,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildQualityStatItem(
                  'Complexity',
                  '${auditReport.codeQuality.complexityScore}/10',
                  Icons.timeline,
                  auditReport.codeQuality.complexityScore <= 5 ? Colors.green : Colors.orange,
                ),
              ),
              Expanded(
                child: _buildQualityStatItem(
                  'Issues Found',
                  '${auditReport.codeQuality.issues.length}',
                  Icons.bug_report,
                  auditReport.codeQuality.issues.isEmpty ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),

          if (auditReport.codeQuality.issues.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Code Issues',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...auditReport.codeQuality.issues.take(3).map((issue) => 
              _buildCodeIssueItem(issue)),
          ],
        ],
      ),
    );
  }

  Widget _buildQualityStatItem(String label, String value, IconData icon, Color color) {
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
              fontSize: 16,
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

  Widget _buildCodeIssueItem(CodeIssue issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getSeverityColor(issue.severity).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getSeverityColor(issue.severity),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              issue.severity.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.type,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  issue.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Line ${issue.lineNumber}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildProgressStep(int step, bool isActive, bool isCompleted) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive || isCompleted ? const Color(0xFF6366F1) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted && !isActive
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive || isCompleted ? Colors.white : Colors.grey[600],
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
        color: isCompleted ? const Color(0xFF6366F1) : Colors.grey[300],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context, WidgetRef ref) async {
    final mainState = ref.read(auditFlowViewModelProvider);
    final auditReport = mainState.currentAuditReport;

    if (auditReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audit report available for download'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
          ),
        );
      },
    );

    try {
      final filePath = await PdfGenerationHelper.generateAuditReportPdf(auditReport);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audit report PDF saved successfully!\nTap to open: ${filePath.split('/').last}'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                final scaffoldContext = context;
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text('Could not open file: $e'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}