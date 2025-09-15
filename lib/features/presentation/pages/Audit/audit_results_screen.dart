import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/overall_assessment_screen.dart';

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
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Critical Risk',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Vulnerabilities',
                        '3',
                        'Issues\nDetected',
                        Colors.red[100]!,
                        Colors.red[800]!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Gas\nOptimization',
                        '4',
                        'Improvements\nPossible',
                        Colors.green[100]!,
                        Colors.green[800]!,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Overall\nScore',
                        'D',
                        'Security\nRating',
                        Colors.blue[100]!,
                        Colors.blue[800]!,
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
                Tab(text: 'Code Quality'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVulnerabilitiesTab(),
                _buildGasOptimizationTab(),
                _buildCodeQualityTab(),
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

  Widget _buildSummaryCard(String title, String value, String subtitle, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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

  Widget _buildVulnerabilitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3 vulnerabilities were detected in the smart contract. These issues should be addressed before deployment.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildVulnerabilityCard(
            'Unprotected Ether Withdrawal',
            'Critical',
            'Line 21',
            Colors.red[100]!,
            Colors.red[800]!,
            true,
          ),
          
          const SizedBox(height: 16),
          
          _buildVulnerabilityCard(
            'Integer Overflow',
            'High',
            'Line 45',
            Colors.orange[100]!,
            Colors.orange[800]!,
            true,
          ),
          
          const SizedBox(height: 16),
          
          _buildVulnerabilityCard(
            'Reentrancy Vulnerability',
            'Critical',
            'Line 78',
            Colors.red[100]!,
            Colors.red[800]!,
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildGasOptimizationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The following gas optimization opportunities were identified to reduce transaction costs.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildOptimizationCard(
            'Replace memory with calldata for read-only function parameters',
            Colors.green[100]!,
            Colors.green[800]!,
          ),
          
          const SizedBox(height: 16),
          
          _buildOptimizationCard(
            'Use uint256 instead of smaller uints when possible',
            Colors.green[100]!,
            Colors.green[800]!,
          ),
          
          const SizedBox(height: 16),
          
          _buildOptimizationCard(
            'Avoid unnecessary storage reads in loops',
            Colors.green[100]!,
            Colors.green[800]!,
          ),
          
          const SizedBox(height: 16),
          
          _buildOptimizationCard(
            'Consider using assembly for complex operations',
            Colors.green[100]!,
            Colors.green[800]!,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeQualityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Code quality assessment evaluates the readability, maintainability, and structure of your contract.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildCodeQualityCard('Documentation', 'Insufficient documentation for key functions. Consider adding NatSpec comments.'),
          const SizedBox(height: 16),
          _buildCodeQualityCard('Function Complexity', 'Some functions have high cyclomatic complexity. Consider breaking them down into smaller functions.'),
          const SizedBox(height: 16),
          _buildCodeQualityCard('Code Duplication', 'Minimal code duplication detected. Good use of modular functions.'),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityCard(String title, String severity, String location, Color bgColor, Color textColor, bool isExpandable) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: textColor, size: 24),
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
                    Text(
                      severity,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                    Text(' • ', style: TextStyle(color: textColor)),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpandable)
            Icon(Icons.expand_more, color: textColor),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard(String title, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: textColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeQualityCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
