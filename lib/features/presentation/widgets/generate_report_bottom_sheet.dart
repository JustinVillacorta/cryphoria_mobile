import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import '../../../dependency_injection/riverpod_providers.dart';
import 'pdf_generation_helper.dart';

class GenerateReportBottomSheet extends ConsumerStatefulWidget {
  const GenerateReportBottomSheet({Key? key}) : super(key: key);

  @override
  ConsumerState<GenerateReportBottomSheet> createState() => _GenerateReportBottomSheetState();
}

class _GenerateReportBottomSheetState extends ConsumerState<GenerateReportBottomSheet> {
  int currentStep = 0; // 0 = form, 1 = success, 2 = loading
  String selectedReportType = 'Payroll';
  String selectedTimePeriod = 'Current Period';
  String selectedFormat = 'PDF';
  bool includeDetailedBreakdown = true;
  bool emailReportWhenGenerated = false;
  bool isLoading = false;
  String? errorMessage;
  String? generatedReportId;
  Map<String, dynamic>? reportData;

  final List<String> reportTypes = ['Tax Reports', 'Balance Sheet', 'Cash Flow'];
  final List<String> timePeriods = ['Current Period', 'Previous Period', 'Year to Date', 'Custom Period'];
  final List<String> formats = ['PDF', 'EXCEL', 'CSV'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: currentStep == 0
                ? _buildFormStep()
                : currentStep == 1
                    ? _buildLoadingStep()
                    : _buildSuccessStep(),
          ),
          if (currentStep == 0) _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          const Expanded(
            child: Text(
              'Generate Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFormStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select report type and options to generate a report instantly.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          
          // Report Type Section
          const Text(
            'Report Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: reportTypes.map((type) => _buildReportTypeCard(type)).toList(),
          ),
          const SizedBox(height: 32),
          
          // Time Period Section
          const Text(
            'Time Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: timePeriods.map((period) => _buildTimePeriodChip(period)).toList(),
          ),
          const SizedBox(height: 32),
          
          // Format Section
          const Text(
            'Format',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: formats.map((format) => _buildFormatChip(format)).toList(),
          ),
          const SizedBox(height: 32),
          
          // Options Section
          Row(
            children: [
              Checkbox(
                value: includeDetailedBreakdown,
                onChanged: (value) {
                  setState(() {
                    includeDetailedBreakdown = value ?? false;
                  });
                },
                activeColor: const Color(0xFF8B5CF6),
              ),
              const Expanded(
                child: Text(
                  'Include detailed breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: emailReportWhenGenerated,
                onChanged: (value) {
                  setState(() {
                    emailReportWhenGenerated = value ?? false;
                  });
                },
                activeColor: const Color(0xFF8B5CF6),
              ),
              const Expanded(
                child: Text(
                  'Email report when generated',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Fetching Report Data...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we fetch your $selectedReportType data from the server',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Success Header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.check,
              color: Color(0xFF4CAF50),
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Report Data Fetched!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your $selectedReportType data has been fetched successfully.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Data Display Section
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getReportIcon(),
                        color: const Color(0xFF8B5CF6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$selectedReportType Data',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildDataDisplay(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Download PDF Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: reportData != null ? () async {
                // Handle PDF download
                try {
                  await _downloadPdf();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF downloaded successfully'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PDF download failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } : null,
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text(
                'Download PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  currentStep = 0;
                  reportData = null;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Generate Another Report',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTypeCard(String type) {
    final isSelected = selectedReportType == type;
    IconData icon;
    switch (type) {
      case 'Tax Reports':
        icon = Icons.receipt_long;
        break;
      case 'Balance Sheet':
        icon = Icons.account_balance;
        break;
      case 'Cash Flow':
        icon = Icons.trending_up;
        break;
      default:
        icon = Icons.description;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedReportType = type;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3F0FF) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[600],
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodChip(String period) {
    final isSelected = selectedTimePeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTimePeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatChip(String format) {
    final isSelected = selectedFormat == format;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFormat = format;
          });
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            format,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _generateReport,
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: const Text(
                'Generate Report',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentStep = 1; // loading step
    });

    try {
      final reportsRepository = ref.read(reportsRepositoryProvider);
      String reportId;
      Map<String, dynamic> data;

      // Handle the 3 financial report types with direct API calls
      if (selectedReportType == 'Tax Reports') {
        print("📤 Fetching Tax Reports...");
        final taxReports = await reportsRepository.getTaxReports();
        // Use the most recent report or first available report
        final taxReport = taxReports.isNotEmpty 
            ? taxReports.reduce((a, b) => 
                (a.generatedAt ?? a.createdAt).isAfter(b.generatedAt ?? b.createdAt) ? a : b)
            : null;
        
        if (taxReport == null) {
          throw Exception('No tax reports available');
        }
        
        data = taxReport.toJson();
        reportId = 'tax_report_${DateTime.now().millisecondsSinceEpoch}';
        print("✅ Tax Reports fetched successfully");
      } else if (selectedReportType == 'Balance Sheet') {
        print("📤 Fetching Balance Sheet...");
        final balanceSheets = await reportsRepository.getAllBalanceSheets();
        if (balanceSheets.isEmpty) {
          throw Exception('No balance sheets available');
        }
        // Use the most recent balance sheet
        final balanceSheet = balanceSheets.reduce((a, b) => 
          a.generatedAt.isAfter(b.generatedAt) ? a : b);
        data = balanceSheet.toJson();
        reportId = 'balance_sheet_${DateTime.now().millisecondsSinceEpoch}';
        print("✅ Balance Sheet fetched successfully");
      } else if (selectedReportType == 'Cash Flow') {
        print("📤 Fetching Cash Flow...");
        final cashFlow = await reportsRepository.getCashFlow();
        data = cashFlow.toJson();
        reportId = 'cash_flow_${DateTime.now().millisecondsSinceEpoch}';
        print("✅ Cash Flow fetched successfully");
      } else {
        throw Exception('Unsupported report type: $selectedReportType');
      }

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      generatedReportId = reportId;
      reportData = data;

      // If email is requested, send the email
      if (emailReportWhenGenerated) {
        try {
          await reportsRepository.emailReport(reportId);
        } catch (e) {
          // Email failed, but report was generated successfully
          print('Failed to send email: $e');
        }
      }

      // Check if widget is still mounted before updating state
      if (!mounted) return;

      setState(() {
        isLoading = false;
        currentStep = 2; // success step
      });
    } catch (e) {
      print("❌ Error generating report: $e");
      
      // Check if widget is still mounted before updating state
      if (!mounted) return;
      
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        currentStep = 0; // back to form
      });
      
      // Show more specific error message
      String errorMsg = 'Failed to generate report';
      if (e.toString().contains('type \'Null\' is not a subtype')) {
        errorMsg = 'Data parsing error: Please check the API response format';
      } else if (e.toString().contains('Network error')) {
        errorMsg = 'Network error: Please check your internet connection';
      } else if (e.toString().contains('Failed to get')) {
        errorMsg = 'API error: ${e.toString().split(': ').last}';
      } else if (e.toString().contains('No balance sheets found') || e.toString().contains('No cash flow statements found')) {
        errorMsg = 'No data available for this report yet. Please wait for transactions to be processed.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _downloadPdf() async {
    if (reportData == null) {
      throw Exception('No report data available');
    }

    print('Generating PDF for $selectedReportType with data: $reportData');
    
    try {
      String filePath;
      
      // Generate PDF based on report type
      if (selectedReportType == 'Tax Reports') {
        filePath = await PdfGenerationHelper.generateTaxReportPdf(reportData!);
      } else if (selectedReportType == 'Balance Sheet') {
        filePath = await PdfGenerationHelper.generateBalanceSheetPdf(reportData!);
      } else if (selectedReportType == 'Cash Flow') {
        filePath = await PdfGenerationHelper.generateCashFlowPdf(reportData!);
      } else {
        throw Exception('Unsupported report type: $selectedReportType');
      }
      
      print('PDF generated successfully at: $filePath');
      
      // Check if widget is still mounted before showing snackbar
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved successfully!\nTap to open: ${filePath.split('/').last}'),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await OpenFile.open(filePath);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open file: $e'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      print('❌ Error generating PDF: $e');
      throw Exception('Failed to generate PDF: $e');
    }
  }

  IconData _getReportIcon() {
    switch (selectedReportType) {
      case 'Tax Reports':
        return Icons.receipt_long;
      case 'Balance Sheet':
        return Icons.account_balance;
      case 'Cash Flow':
        return Icons.trending_up;
      default:
        return Icons.description;
    }
  }

  Widget _buildDataDisplay() {
    if (reportData == null) {
      return const Text(
        'No data available',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info
        _buildDataSection('Report Information', {
          'ID': reportData!['id']?.toString() ?? 'N/A',
          'Type': reportData!['report_type']?.toString() ?? 'N/A',
          'Currency': reportData!['currency']?.toString() ?? 'N/A',
          'Period Start': _formatDate(reportData!['period_start']),
          'Period End': _formatDate(reportData!['period_end']),
        }),
        
        const SizedBox(height: 16),
        
        // Summary Section
        if (reportData!['summary'] != null) ...[
          _buildDataSection('Summary', _formatSummaryData(reportData!['summary'])),
          const SizedBox(height: 16),
        ],
        
        // Activities/Items Section
        if (selectedReportType == 'Cash Flow') ...[
          if (reportData!['operating_activities'] != null && (reportData!['operating_activities'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Operating Activities', reportData!['operating_activities']),
            const SizedBox(height: 12),
          ],
          if (reportData!['investing_activities'] != null && (reportData!['investing_activities'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Investing Activities', reportData!['investing_activities']),
            const SizedBox(height: 12),
          ],
          if (reportData!['financing_activities'] != null && (reportData!['financing_activities'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Financing Activities', reportData!['financing_activities']),
            const SizedBox(height: 12),
          ],
        ] else if (selectedReportType == 'Balance Sheet') ...[
          if (reportData!['assets'] != null && (reportData!['assets'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Assets', reportData!['assets']),
            const SizedBox(height: 12),
          ],
          if (reportData!['liabilities'] != null && (reportData!['liabilities'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Liabilities', reportData!['liabilities']),
            const SizedBox(height: 12),
          ],
          if (reportData!['equity'] != null && (reportData!['equity'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Equity', reportData!['equity']),
            const SizedBox(height: 12),
          ],
        ] else if (selectedReportType == 'Tax Reports') ...[
          if (reportData!['categories'] != null && (reportData!['categories'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Tax Categories', reportData!['categories']),
            const SizedBox(height: 12),
          ],
          if (reportData!['transactions'] != null && (reportData!['transactions'] as List).isNotEmpty) ...[
            _buildActivitiesSection('Transactions', reportData!['transactions']),
            const SizedBox(height: 12),
          ],
        ],
        
        // Raw Data (for debugging)
        const SizedBox(height: 16),
        const Text(
          'Raw Data (Debug)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            reportData.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: Colors.grey,
            ),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(String title, Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  '${entry.key}:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildActivitiesSection(String title, List<dynamic> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...activities.take(5).map((activity) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['description']?.toString() ?? activity['name']?.toString() ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (activity['amount'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  '\$${(activity['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              if (activity['category'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Category: ${activity['category']}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        )).toList(),
        if (activities.length > 5) ...[
          Text(
            '... and ${activities.length - 5} more items',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Map<String, String> _formatSummaryData(Map<String, dynamic> summary) {
    final Map<String, String> formatted = {};
    
    summary.forEach((key, value) {
      if (value is num) {
        formatted[key.replaceAll('_', ' ').toUpperCase()] = '\$${value.toStringAsFixed(2)}';
      } else if (value is Map) {
        // Handle nested objects
        value.forEach((nestedKey, nestedValue) {
          if (nestedValue is num) {
            formatted['${key.replaceAll('_', ' ').toUpperCase()} - ${nestedKey.replaceAll('_', ' ').toUpperCase()}'] = '\$${nestedValue.toStringAsFixed(2)}';
          }
        });
      } else {
        formatted[key.replaceAll('_', ' ').toUpperCase()] = value.toString();
      }
    });
    
    return formatted;
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    
    try {
      if (dateValue is String) {
        final date = DateTime.parse(dateValue);
        return '${date.day}/${date.month}/${date.year}';
      }
      return dateValue.toString();
    } catch (e) {
      return dateValue.toString();
    }
  }
}
