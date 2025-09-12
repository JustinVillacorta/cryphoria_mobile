import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/notifiers/audit_notifier.dart';
import '../../../domain/entities/audit_report.dart';

class OverallAssessmentScreen extends StatelessWidget {
  final String contractName;
  final String fileName;

  const OverallAssessmentScreen({
    super.key,
    required this.contractName,
    required this.fileName,
  });

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
          
          if (auditReport == null) {
            return Center(
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
            );
          }

          return _buildAssessmentContent(context, auditReport);
        },
      ),
    );
  }

  Widget _buildAssessmentContent(BuildContext context, AuditReport auditReport) {
    // Calculate assessment data from real audit report
    final totalVulnerabilities = auditReport.vulnerabilities.length;
    final criticalVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.critical).length;
    final highVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.high).length;
    final mediumVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.medium).length;
    final lowVulns = auditReport.vulnerabilities.where((v) => v.severity == Severity.low).length;
    
    final gasOptimizations = auditReport.gasOptimization.suggestions.length;
    final overallScore = auditReport.overallScore;
    
    // Determine risk level
    String riskLevel;
    MaterialColor riskColor;
    String riskMessage;
    
    if (criticalVulns > 0) {
      riskLevel = 'Critical';
      riskColor = Colors.red;
      riskMessage = 'This contract has critical vulnerabilities that could lead to significant financial loss or security breaches.';
    } else if (highVulns > 0) {
      riskLevel = 'High';
      riskColor = Colors.orange;
      riskMessage = 'This contract has high-severity vulnerabilities that should be addressed before deployment.';
    } else if (mediumVulns > 0) {
      riskLevel = 'Medium';
      riskColor = Colors.amber;
      riskMessage = 'This contract has medium-severity vulnerabilities that should be reviewed and addressed.';
    } else if (lowVulns > 0) {
      riskLevel = 'Low';
      riskColor = Colors.blue;
      riskMessage = 'This contract has minor vulnerabilities that pose minimal risk but should be considered.';
    } else {
      riskLevel = 'Secure';
      riskColor = Colors.green;
      riskMessage = 'This contract passed all security checks with no vulnerabilities detected.';
    }

    // Gas optimization level
    String gasOptLevel;
    MaterialColor gasOptColor;
    String gasOptMessage;
    
    if (gasOptimizations == 0) {
      gasOptLevel = 'Optimized';
      gasOptColor = Colors.green;
      gasOptMessage = 'Your contract is already well-optimized for gas usage. No significant improvements needed.';
    } else if (gasOptimizations <= 2) {
      gasOptLevel = 'Good';
      gasOptColor = Colors.blue;
      gasOptMessage = 'Few optimization opportunities identified. Implementing these could provide modest gas savings.';
    } else if (gasOptimizations <= 5) {
      gasOptLevel = 'Moderate';
      gasOptColor = Colors.orange;
      gasOptMessage = 'Several opportunities to optimize gas usage were identified. Implementing these changes could reduce transaction costs by approximately 15-25%.';
    } else {
      gasOptLevel = 'Poor';
      gasOptColor = Colors.red;
      gasOptMessage = 'Many optimization opportunities identified. Significant gas savings possible with proper optimization.';
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
                    _buildProgressStep(3, false, true),
                    _buildProgressLine(true),
                    _buildProgressStep(4, true, false),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Progress labels
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
                
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
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
                  // Risk Assessment
                  Container(
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
                            const Spacer(),
                            Text(
                              'Score: ${overallScore.toStringAsFixed(0)}/100',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: riskColor[800],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Risk Assessment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Icon(
                              totalVulnerabilities > 0 ? Icons.warning : Icons.security,
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
                        
                        if (totalVulnerabilities > 0) ...[
                          _buildKeyFinding('$totalVulnerabilities vulnerabilities detected' +
                            (criticalVulns > 0 ? ' ($criticalVulns critical)' : 
                             highVulns > 0 ? ' ($highVulns high severity)' : '')),
                          if (criticalVulns > 0)
                            _buildKeyFinding('Immediate action required for critical vulnerabilities'),
                          if (mediumVulns > 0 || lowVulns > 0)
                            _buildKeyFinding('Medium and low severity issues require attention'),
                        ] else
                          _buildKeyFinding('No security vulnerabilities detected'),
                        
                        if (gasOptimizations > 0)
                          _buildKeyFinding('$gasOptimizations gas optimization opportunities identified')
                        else
                          _buildKeyFinding('Contract is already well-optimized for gas usage'),
                        
                        if (auditReport.recommendations.isNotEmpty)
                          _buildKeyFinding('${auditReport.recommendations.length} recommendations provided'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gas Optimization
                  Container(
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
                              gasOptimizations == 0 ? Icons.check_circle : Icons.speed, 
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
                            const Text(
                              'Optimization Level',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
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
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recommendations
                  const Text(
                    'Recommendations',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Build recommendations from real audit data
                  if (auditReport.recommendations.isNotEmpty) ...[
                    ...auditReport.recommendations.map((recommendation) {
                      MaterialColor recColor;
                      switch (recommendation.priority) {
                        case Priority.high:
                          recColor = Colors.red;
                          break;
                        case Priority.medium:
                          recColor = Colors.orange;
                          break;
                        case Priority.low:
                          recColor = Colors.blue;
                          break;
                      }
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          '${recommendation.priority.name.toUpperCase()} Priority',
                          recommendation.description,
                          recColor[100]!,
                          recColor[800]!,
                        ),
                      );
                    }).toList(),
                  ] else ...[
                    // Show vulnerability-based recommendations if no specific recommendations
                    if (criticalVulns > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          'Critical Priority',
                          'Address critical vulnerabilities immediately. These pose significant security risks and should be fixed before deployment.',
                          Colors.red[100]!,
                          Colors.red[800]!,
                        ),
                      ),
                    
                    if (highVulns > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          'High Priority',
                          'Fix high-severity vulnerabilities to prevent potential security breaches and ensure contract safety.',
                          Colors.orange[100]!,
                          Colors.orange[800]!,
                        ),
                      ),
                    
                    if (mediumVulns > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          'Medium Priority',
                          'Review and address medium-severity vulnerabilities to improve overall contract security.',
                          Colors.blue[100]!,
                          Colors.blue[800]!,
                        ),
                      ),
                    
                    if (gasOptimizations > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          'Gas Optimization',
                          'Implement the identified gas optimization suggestions to reduce transaction costs for users.',
                          Colors.green[100]!,
                          Colors.green[800]!,
                        ),
                      ),
                      
                    if (totalVulnerabilities == 0 && gasOptimizations == 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRecommendationCard(
                          'Best Practices',
                          'Your contract is secure and well-optimized. Continue following security best practices for future development.',
                          Colors.green[100]!,
                          Colors.green[800]!,
                        ),
                      ),
                  ],
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDownloadDialog(context);
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
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Download Full Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Back to Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildKeyFinding(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.chevron_right, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
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

  Widget _buildOptimizationPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.green[700],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
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

  Widget _buildRecommendationCard(String priority, String description, Color bgColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            priority,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Download Report'),
          content: const Text('This feature would download a comprehensive PDF report with all audit findings and recommendations.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
