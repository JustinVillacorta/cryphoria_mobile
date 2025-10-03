import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../dependency_injection/riverpod_providers.dart';
import '../../domain/repositories/reports_repository.dart';

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

  final List<String> reportTypes = ['Payroll', 'Tax', 'Summary'];
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
            'Generating Report...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we generate your $selectedReportType report',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            'Report Generated!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your $selectedReportType Report has been created successfully',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          // Report Icon and Details
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$selectedReportType Report',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedTimePeriod,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: generatedReportId != null ? () async {
                    // Handle download
                    try {
                      final reportsRepository = ref.read(reportsRepositoryProvider);
                      await reportsRepository.downloadReport(generatedReportId!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report download initiated'),
                          backgroundColor: Color(0xFF8B5CF6),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Download failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text(
                    'Download',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: generatedReportId != null ? () async {
                    // Handle email
                    try {
                      final reportsRepository = ref.read(reportsRepositoryProvider);
                      await reportsRepository.emailReport(generatedReportId!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report emailed successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Email failed: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                  icon: const Icon(Icons.email, color: Colors.grey),
                  label: const Text(
                    'Email',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  currentStep = 0;
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
      case 'Payroll':
        icon = Icons.people;
        break;
      case 'Tax':
        icon = Icons.description;
        break;
      case 'Summary':
        icon = Icons.bar_chart;
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
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3F0FF) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey[700],
                ),
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
      final generateReportUseCase = ref.read(generateReportUseCaseProvider);

      final request = ReportGenerationRequest(
        type: selectedReportType,
        timePeriod: selectedTimePeriod,
        format: selectedFormat,
        includeDetailedBreakdown: includeDetailedBreakdown,
        emailWhenGenerated: emailReportWhenGenerated,
      );

      final reportId = await generateReportUseCase.execute(request);
      generatedReportId = reportId;

      // If email is requested, send the email
      if (emailReportWhenGenerated) {
        try {
          final reportsRepository = ref.read(reportsRepositoryProvider);
          await reportsRepository.emailReport(reportId);
        } catch (e) {
          // Email failed, but report was generated successfully
          print('Failed to send email: $e');
        }
      }

      setState(() {
        isLoading = false;
        currentStep = 2; // success step
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
        currentStep = 0; // back to form
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
