import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../ViewModels/audit_contract_viewmodel.dart';
import 'ai_analysis_screen.dart';

class ContractSetupScreenRefactored extends ConsumerStatefulWidget {
  const ContractSetupScreenRefactored({super.key});

  @override
  ConsumerState<ContractSetupScreenRefactored> createState() => _ContractSetupScreenRefactoredState();
}

class _ContractSetupScreenRefactoredState extends ConsumerState<ContractSetupScreenRefactored> {
  final TextEditingController _contractNameController = TextEditingController();
  late AuditContractViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ref.read(auditContractViewModelProvider);
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _contractNameController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(auditContractViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Contract Setup',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildContractNameSection(viewModel),
            const SizedBox(height: 24),
            _buildFileUploadSection(viewModel),
            const SizedBox(height: 32),
            _buildUploadButton(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Contract Audit',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload your smart contract for comprehensive security analysis',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContractNameSection(AuditContractViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _contractNameController,
          onChanged: viewModel.updateContractName,
          decoration: InputDecoration(
            hintText: 'Enter contract name',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection(AuditContractViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contract File',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: viewModel.selectedFileName != null 
                    ? Colors.green 
                    : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  viewModel.selectedFileName != null 
                      ? Icons.check_circle
                      : Icons.cloud_upload,
                  size: 48,
                  color: viewModel.selectedFileName != null 
                      ? Colors.green 
                      : Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  viewModel.selectedFileName ?? 'Select .sol file',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: viewModel.selectedFileName != null 
                        ? Colors.green 
                        : Colors.grey[600],
                  ),
                ),
                if (viewModel.selectedFileName != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: viewModel.clearFile,
                    child: const Text('Remove File'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(AuditContractViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: viewModel.canProceed && !viewModel.isLoading
            ? _handleUpload
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9747FF),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: viewModel.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Start Audit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  void _selectFile() {
    // Mock file selection - in real implementation, use file_picker
    final fileName = 'MyContract.sol';
    final sourceCode = '''
pragma solidity ^0.8.0;

contract MyContract {
    address public owner;
    uint256 public value;
    
    constructor() {
        owner = msg.sender;
    }
    
    function setValue(uint256 _value) public {
        require(msg.sender == owner, "Only owner can set value");
        value = _value;
    }
}
''';
    
    _viewModel.selectFile(fileName, sourceCode);
  }

  void _handleUpload() async {
    final success = await _viewModel.uploadContract();
    
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiAnalysisScreen(
            contractName: _viewModel.contractName,
            fileName: _viewModel.selectedFileName!,
          ),
        ),
      );
    }
  }
}
