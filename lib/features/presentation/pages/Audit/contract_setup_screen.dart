import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/notifiers/audit_notifier.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'ai_analysis_screen.dart';

class ContractSetupScreen extends StatefulWidget {
  const ContractSetupScreen({super.key});

  @override
  State<ContractSetupScreen> createState() => _ContractSetupScreenState();
}

class _ContractSetupScreenState extends State<ContractSetupScreen> {
  final TextEditingController _contractNameController = TextEditingController();
  bool _isFileUploaded = false;
  bool _isUploading = false;
  String? _selectedFileName;
  String? _sourceCode;

  @override
  void dispose() {
    _contractNameController.dispose();
    super.dispose();
  }

  bool get _canProceed => 
      _contractNameController.text.trim().isNotEmpty && 
      _isFileUploaded && 
      _sourceCode != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Contract Setup',
          style: TextStyle(
            color: Colors.black87,
            fontSize: context.fontSize(20),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: context.safePadding(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Indicator
            _buildProgressIndicator(),
            SizedBox(height: context.spacing(32)),

            // Contract Name Section
            _buildContractNameSection(),
            SizedBox(height: context.spacing(32)),

            // File Upload Section
            _buildFileUploadSection(),
            SizedBox(height: context.spacing(32)),

            // Summary Section
            if (_isFileUploaded) ...[
              _buildSummarySection(),
              SizedBox(height: context.spacing(32)),
            ],

            // Action Button
            _buildActionButton(),
            SizedBox(height: context.spacing(16)), // Bottom safe area
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: context.safePadding(all: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setup Progress',
            style: TextStyle(
              fontSize: context.fontSize(18),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          Row(
            children: [
              _buildProgressStep(1, _contractNameController.text.isNotEmpty),
              _buildProgressLine(_contractNameController.text.isNotEmpty),
              _buildProgressStep(2, _isFileUploaded),
              _buildProgressLine(_isFileUploaded),
              _buildProgressStep(3, false),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contract\nDetails',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  color: _contractNameController.text.isNotEmpty 
                      ? Colors.purple 
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Upload\nContract',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  color: _isFileUploaded ? Colors.purple : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'AI\nAnalysis',
                style: TextStyle(
                  fontSize: context.fontSize(12),
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(int step, bool isCompleted) {
    final isActive = step == 1 && _contractNameController.text.isEmpty ||
                     step == 2 && _contractNameController.text.isNotEmpty && !_isFileUploaded ||
                     step == 3 && _isFileUploaded;
    
    // Responsive step size
    final stepSize = context.responsiveValue(
      mobile: 28.0,
      tablet: 32.0,
      desktop: 36.0,
    );
                     
    return Container(
      width: stepSize,
      height: stepSize,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.purple : (isActive ? Colors.purple : Colors.grey[300]),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
                Icons.check, 
                color: Colors.white, 
                size: context.iconSize(18),
              )
            : Text(
                '$step',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontSize: context.fontSize(14),
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

  Widget _buildContractNameSection() {
    return Container(
      padding: context.safePadding(all: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: EdgeInsets.all(context.responsiveValue(
                  mobile: 6.0,
                  tablet: 8.0,
                  desktop: 10.0,
                )),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_document,
                  color: Colors.purple,
                  size: context.iconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(12)),
              Flexible(
                child: Text(
                  'Contract Details',
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            'Give your smart contract a memorable name',
            style: TextStyle(
              fontSize: context.fontSize(14),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          TextField(
            controller: _contractNameController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'e.g., MyToken Contract, DeFi Protocol...',
              hintStyle: TextStyle(fontSize: context.fontSize(14)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.purple, width: 2),
              ),
              contentPadding: context.responsiveValue(
                mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            style: TextStyle(fontSize: context.fontSize(16)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Container(
      padding: context.safePadding(all: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: EdgeInsets.all(context.responsiveValue(
                  mobile: 6.0,
                  tablet: 8.0,
                  desktop: 10.0,
                )),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.upload_file,
                  color: Colors.blue,
                  size: context.iconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(12)),
              Flexible(
                child: Text(
                  'Upload Contract',
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            'Upload your Solidity smart contract file for analysis',
            style: TextStyle(
              fontSize: context.fontSize(14),
              color: Colors.grey,
            ),
          ),
          SizedBox(height: context.spacing(20)),
          
          // Upload Area
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: context.responsiveValue(
                mobile: const EdgeInsets.all(24),
                tablet: const EdgeInsets.all(32),
                desktop: const EdgeInsets.all(40),
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isFileUploaded ? Colors.green : Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _isFileUploaded 
                    ? Colors.green.withOpacity(0.05) 
                    : Colors.grey[50],
              ),
              child: Column(
                children: [
                  Icon(
                    _isFileUploaded ? Icons.check_circle : Icons.cloud_upload,
                    size: context.responsiveValue(
                      mobile: 40.0,
                      tablet: 48.0,
                      desktop: 56.0,
                    ),
                    color: _isFileUploaded ? Colors.green : Colors.grey[400],
                  ),
                  SizedBox(height: context.spacing(16)),
                  Text(
                    _isFileUploaded 
                        ? 'File Uploaded Successfully!' 
                        : 'Click to browse files',
                    style: TextStyle(
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w600,
                      color: _isFileUploaded ? Colors.green : Colors.black87,
                    ),
                  ),
                  SizedBox(height: context.spacing(8)),
                  Text(
                    _isFileUploaded 
                        ? _selectedFileName ?? 'Unknown file'
                        : 'Supports .sol and .txt files (max 10MB)',
                    style: TextStyle(
                      fontSize: context.fontSize(14),
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: context.safePadding(all: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
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
                padding: EdgeInsets.all(context.responsiveValue(
                  mobile: 6.0,
                  tablet: 8.0,
                  desktop: 10.0,
                )),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.summarize,
                  color: Colors.green,
                  size: context.iconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(12)),
              Flexible(
                child: Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: context.fontSize(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(20)),
          _buildSummaryRow('Contract Name', _contractNameController.text),
          SizedBox(height: context.spacing(12)),
          _buildSummaryRow('File', _selectedFileName ?? 'Unknown'),
          SizedBox(height: context.spacing(12)),
          _buildSummaryRow('Source Code', 
            _sourceCode != null 
                ? '${_sourceCode!.length} characters' 
                : 'Not loaded'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.responsiveValue(
            mobile: 80.0,
            tablet: 100.0,
            desktop: 120.0,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.fontSize(14),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: context.spacing(16)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: context.fontSize(14),
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: context.responsiveValue(
        mobile: 48.0,
        tablet: 56.0,
        desktop: 64.0,
      ),
      child: ElevatedButton(
        onPressed: _canProceed && !_isUploading ? _proceedToAnalysis : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: ResponsiveHelper.buttonPadding(context),
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: context.iconSize(20),
                    height: context.iconSize(20),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: context.spacing(12)),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: context.iconSize(20)),
                  SizedBox(width: context.spacing(8)),
                  Text(
                    'Start AI Analysis',
                    style: TextStyle(
                      fontSize: context.fontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      // Use FileType.any for better Android compatibility
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        final fileName = pickedFile.name.toLowerCase();
        
        // Validate file extension manually for better compatibility
        if (!fileName.endsWith('.sol') && !fileName.endsWith('.txt')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a .sol or .txt file'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        // Check file size (10MB limit)
        if (pickedFile.size > 10 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 10MB limit'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Read file content
        String? fileContent;
        if (pickedFile.path != null) {
          final file = File(pickedFile.path!);
          fileContent = await file.readAsString();
        } else if (pickedFile.bytes != null) {
          fileContent = String.fromCharCodes(pickedFile.bytes!);
        }
        
        if (fileContent == null || fileContent.isEmpty) {
          throw Exception('File is empty or could not be read');
        }

        setState(() {
          _sourceCode = fileContent;
          _selectedFileName = pickedFile.name;
          _isFileUploaded = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File "${pickedFile.name}" uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        // Show helpful dialog for file selection issues
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('File Selection Help'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Having trouble selecting files?'),
                  SizedBox(height: 12),
                  Text('Try these solutions:'),
                  Text('• Use a different file manager app'),
                  Text('• Check file permissions'),
                  Text('• Try copying the file to Downloads folder'),
                  Text('• Ensure file is .sol or .txt format'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickFile(); // Try again
                  },
                  child: const Text('Try Again'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _proceedToAnalysis() async {
    if (!_canProceed || _sourceCode == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final auditNotifier = Provider.of<AuditNotifier>(context, listen: false);
      
      // Upload contract first
      await auditNotifier.uploadContract(
        _contractNameController.text.trim(),
        _selectedFileName!,
        _sourceCode!,
      );

      if (auditNotifier.error != null) {
        throw Exception(auditNotifier.error);
      }

      // Navigate to AI analysis screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiAnalysisScreen(
              contractName: _contractNameController.text.trim(),
              fileName: _selectedFileName!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading contract: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
