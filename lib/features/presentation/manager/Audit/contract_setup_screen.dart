import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/ai_analysis_screen.dart';

class ContractSetupScreen extends StatefulWidget {
  const ContractSetupScreen({super.key});

  @override
  State<ContractSetupScreen> createState() => _ContractSetupScreenState();
}

class _ContractSetupScreenState extends State<ContractSetupScreen> {
  final TextEditingController _contractNameController = TextEditingController();
  String? _selectedFileName;
  bool _isFileUploaded = false;

  @override
  void dispose() {
    _contractNameController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    return _contractNameController.text.isNotEmpty && _isFileUploaded;
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              children: [
                _buildProgressStep(1, true, true),
                _buildProgressLine(false),
                _buildProgressStep(2, false, false),
                _buildProgressLine(false),
                _buildProgressStep(3, false, false),
                _buildProgressLine(false),
                _buildProgressStep(4, false, false),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                Text('AI Analysis', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Contract Setup Title
            const Text(
              'Contract Setup',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contract Name
            const Text(
              'Contract Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _contractNameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'e.g., PayrollVault.sol',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Upload Solidity File
            const Text(
              'Upload Solidity File',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 12),
            
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isFileUploaded ? Colors.purple : Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: _isFileUploaded ? Colors.purple[50] : Colors.grey[50],
                ),
                child: Column(
                  children: [
                    Icon(
                      _isFileUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _isFileUploaded ? Colors.purple : Colors.grey[600],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _isFileUploaded 
                          ? _selectedFileName ?? 'File uploaded'
                          : 'Drag and drop your Solidity contract here',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _isFileUploaded ? Colors.purple : Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    if (!_isFileUploaded) ...[
                      const SizedBox(height: 8),
                      Text(
                        '.sol files only (Max 10MB)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            if (!_isFileUploaded) ...[
              const SizedBox(height: 16),
              
              Center(
                child: ElevatedButton(
                  onPressed: _pickFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Browse Files',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            
            const Spacer(),
            
            // Smart Contract Audit Info
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
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Smart Contract Audit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our AI will analyze your Solidity contract for vulnerabilities, security risks, and optimization opportunities. The audit covers reentrancy, overflow/underflow, gas optimization, and more.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[800],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Run Smart Audit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canProceed ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AiAnalysisScreen(
                        contractName: _contractNameController.text,
                        fileName: _selectedFileName ?? 'contract.sol',
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canProceed ? Colors.purple : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Run Smart Audit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Future<void> _pickFile() async {
    // For demo purposes, simulate file upload
    setState(() {
      _selectedFileName = 'sample.sol';
      _isFileUploaded = true;
    });
  }
}
