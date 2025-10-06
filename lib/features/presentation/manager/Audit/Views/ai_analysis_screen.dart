import 'package:cryphoria_mobile/features/domain/entities/smart_contract.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';

import '../ViewModels/audit_analysis_viewmodel.dart';
import '../ViewModels/audit_main_viewmodel.dart';
import '../../../../domain/entities/audit_report.dart' show AuditStatus;
import 'audit_results_screen.dart';

class AiAnalysisScreen extends ConsumerStatefulWidget {
  final String contractName;
  final String fileName;

  const AiAnalysisScreen({
    super.key,
    required this.contractName,
    required this.fileName,
  });

  @override
  ConsumerState<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends ConsumerState<AiAnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _rotationController;
  late Animation<double> _progressAnimation;
  late AuditAnalysisViewModel _analysisViewModel;
  late AuditMainViewModel _mainViewModel;
  
  int _currentStep = 0;
  final List<String> _analysisSteps = [
    'Parsing smart contract code',
    'Analyzing contract structure',
    'Identifying potential vulnerabilities',
    'Performing security checks',
    'Running gas optimization analysis',
    'Generating comprehensive report',
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize ViewModels
    _analysisViewModel = ref.read(auditAnalysisViewModelProvider);
    _mainViewModel = ref.read(auditMainViewModelProvider);
    
    // Add listeners
    _analysisViewModel.addListener(_onAnalysisViewModelChanged);
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 8), // Original UI timing for smooth progress
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Start analysis after the frame is built to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  @override
  void dispose() {
    _analysisViewModel.removeListener(_onAnalysisViewModelChanged);
    _progressController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _onAnalysisViewModelChanged() {
    if (_analysisViewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_analysisViewModel.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startAnalysis() async {
    print("🔄 AiAnalysisScreen._startAnalysis: Starting analysis");
    print("📋 Contract name: ${widget.contractName}");
    print("📄 File name: ${widget.fileName}");
    
    // Get current contract from main ViewModel
    final currentContract = _mainViewModel.currentContract;
    
    print("🔍 Checking current contract from main ViewModel...");
    print("📦 Current contract: ${currentContract?.id}");
    print("📝 Contract name: ${currentContract?.name}");
    print("📄 Contract source code length: ${currentContract?.sourceCode.length}");
    
    if (currentContract == null) {
      print("❌ No contract found in main ViewModel!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No contract found. Please upload a contract first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create audit request using data from the main ViewModel
    final auditRequest = AuditRequest(
      contractId: currentContract.id,
      contractName: widget.contractName,
      fileName: widget.fileName,
      sourceCode: currentContract.sourceCode,
      options: const AuditOptions(),
      requestedAt: DateTime.now(),
    );

    try {
      // Start analysis using ViewModel
      final success = await _analysisViewModel.startAnalysis(auditRequest);
      
      if (success) {
        // Start the UI animation and polling simultaneously
        _startUIAnimation();
        
        // Start real-time polling for audit completion
        await _pollForAuditCompletion();
      }
      
    } catch (e) {
      print("❌ AiAnalysisScreen._startAnalysis: Error - $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startUIAnimation() async {
    print("🎨 AiAnalysisScreen._startUIAnimation: Starting UI animation");
    
    // Animate through the analysis steps for visual feedback
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        // Update ViewModel progress instead of local state
        double progress = (i + 1) / _analysisSteps.length;
        _analysisViewModel.updateProgress(progress);
        
        setState(() {
          _currentStep = i;
        });
        
        print("📊 AiAnalysisScreen._startUIAnimation: Step $i, Progress: ${(progress * 100).toInt()}%");
        
        // Animate to the progress and wait for it to complete
        await _progressController.animateTo(progress, duration: const Duration(milliseconds: 600));
        
        // Don't complete the last step automatically - wait for actual completion
        if (i == _analysisSteps.length - 1) {
          print("⏸️ AiAnalysisScreen._startUIAnimation: Reached final step, waiting for backend completion");
          break;
        }
      }
    }
  }

  Future<void> _pollForAuditCompletion() async {
    print("🔄 AiAnalysisScreen._pollForAuditCompletion: Starting polling");
    print("📊 Polling for audit ID: ${_analysisViewModel.currentAuditId}");
    
    try {
      // Use ViewModel's polling method
      final success = await _analysisViewModel.pollForCompletion(
        maxAttempts: 30,
        pollInterval: const Duration(seconds: 1),
      );
      
      if (success && mounted) {
        print("✅ AiAnalysisScreen._pollForAuditCompletion: Audit completed! Navigating to results...");
        
        // Update main ViewModel with audit ID
        if (_analysisViewModel.currentAuditId != null) {
          _mainViewModel.setCurrentAuditId(_analysisViewModel.currentAuditId!);
        }
        
        // Ensure progress animation is at 100%
        await _progressController.animateTo(1.0, duration: const Duration(milliseconds: 300));
        setState(() {
          _currentStep = _analysisSteps.length - 1;
        });
        
        // Wait a bit for visual feedback
        await Future.delayed(const Duration(milliseconds: 800));
        
        print("🚀 AiAnalysisScreen._pollForAuditCompletion: Attempting navigation...");
        
        // Navigate to results
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuditResultsScreen(
                contractName: widget.contractName,
                fileName: widget.fileName,
                auditId: _analysisViewModel.currentAuditId,
              ),
            ),
          );
        }
        
        print("✅ AiAnalysisScreen._pollForAuditCompletion: Navigation completed successfully");
      } else if (mounted) {
        throw Exception('Analysis timed out or failed');
      }
    } catch (e) {
      print("❌ AiAnalysisScreen._pollForAuditCompletion: Error - $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchedAnalysis = ref.watch(auditAnalysisViewModelProvider);

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  48,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _buildProgressStep(1, false, true),
                    _buildProgressLine(true),
                    _buildProgressStep(2, true, false),
                    _buildProgressLine(false),
                    _buildProgressStep(3, false, false),
                    _buildProgressLine(false),
                    _buildProgressStep(4, false, false),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('AI Analysis', style: TextStyle(fontSize: 12, color: Color(0xFF9747FF), fontWeight: FontWeight.w500)),
                    Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 60),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationController.value * 2 * 3.14159,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFE1BFFF)!,
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFF3E5FF),
                                ),
                                child: const Icon(
                                  Icons.analytics_outlined,
                                  size: 48,
                                  color: Color(0xFF9747FF),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Analyzing Smart Contract',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Our AI is performing a comprehensive\naudit of your smart contract',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _progressAnimation,
                                builder: (context, child) {
                                  return Text(
                                    '${(_progressAnimation.value * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return LinearProgressIndicator(
                                value: _progressAnimation.value,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                                minHeight: 8,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Text(
                        watchedAnalysis.currentAuditId != null
                            ? 'Audit ID: ${watchedAnalysis.currentAuditId}'
                            : 'Generating audit ID...',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        switch (watchedAnalysis.currentStatus) {
                          AuditStatus.completed => 'Status: Completed',
                          AuditStatus.failed => 'Status: Failed',
                          _ => 'Status: Analyzing…',
                        },
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      Container(
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
                            const Text(
                              'Analysis Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(_analysisSteps.length, (index) {
                              final isCompleted = index < _currentStep;
                              final isCurrent = index == _currentStep;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCompleted
                                          ? Icons.check_circle
                                          : isCurrent
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                      color: isCompleted || isCurrent
                                          ? Colors.purple
                                          : Colors.grey[400],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _analysisSteps[index],
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isCompleted || isCurrent
                                              ? Colors.black
                                              : Colors.grey[600],
                                          fontWeight: isCurrent
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
}
