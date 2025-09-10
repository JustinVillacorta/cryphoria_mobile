import 'package:flutter/material.dart';

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
      body: Column(
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
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Critical',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[800],
                                ),
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
                            Icon(Icons.warning, color: Colors.red[700], size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'This contract has several critical vulnerabilities that could lead to financial loss.',
                                style: TextStyle(
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
                        
                        _buildKeyFinding('3 vulnerabilities detected (2 critical)'),
                        _buildKeyFinding('Gas optimization opportunities identified'),
                        _buildKeyFinding('Contract requires access control improvements'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gas Optimization
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                            Icon(Icons.check_circle, color: Colors.green[700], size: 24),
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
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Moderate',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const Text(
                          'Several opportunities to optimize gas usage were identified. Implementing these changes could reduce transaction costs by approximately 15-25%.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildOptimizationPoint('Replace memory with calldata for read-only function parameters'),
                            _buildOptimizationPoint('Use uint256 instead of smaller uints when possible'),
                            _buildOptimizationPoint('Avoid unnecessary storage reads in loops'),
                            _buildOptimizationPoint('Consider using assembly for complex operations'),
                          ],
                        ),
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
                  
                  _buildRecommendationCard(
                    'Critical Priority',
                    'Add proper access control mechanisms to the withdraw function to prevent unauthorized withdrawals.',
                    Colors.red[100]!,
                    Colors.red[800]!,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildRecommendationCard(
                    'High Priority',
                    'Implement SafeMath library or use Solidity 0.8+ built-in overflow checks for all arithmetic operations.',
                    Colors.orange[100]!,
                    Colors.orange[800]!,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildRecommendationCard(
                    'Medium Priority',
                    'Apply the checks-effects-interactions pattern and consider using ReentrancyGuard to prevent reentrancy attacks.',
                    Colors.blue[100]!,
                    Colors.blue[800]!,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildRecommendationCard(
                    'Gas Optimization',
                    'Replace memory with calldata for read-only function parameters and optimize storage access patterns.',
                    Colors.green[100]!,
                    Colors.green[800]!,
                  ),
                  
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
