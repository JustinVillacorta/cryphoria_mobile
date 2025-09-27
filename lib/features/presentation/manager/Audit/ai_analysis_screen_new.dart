import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/app_providers.dart';
import '../../../data/notifiers/audit_notifier.dart';
import '../../../domain/entities/smart_contract.dart';
import '../../../domain/entities/audit_report.dart';
import 'Views/audit_results_screen.dart';

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
    _progressController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final auditNotifier = ref.read(auditNotifierProvider);
    
    print("🔄 AiAnalysisScreen._startAnalysis: Starting analysis");
    print("📋 Contract name: ${widget.contractName}");
    print("📄 File name: ${widget.fileName}");
    
    // Create audit request using data from the notifier
    final auditRequest = AuditRequest(
      contractId: auditNotifier.currentContract?.id ?? '',
      contractName: widget.contractName,
      fileName: widget.fileName,
      sourceCode: auditNotifier.currentContract?.sourceCode ?? '',
      options: const AuditOptions(),
      requestedAt: DateTime.now(),
    );

    try {
      // Submit audit request to backend first
      await auditNotifier.submitAuditRequest(auditRequest);
      
      // Start the UI animation while polling for results
      _startUIAnimation();
      
      // Start real-time polling for audit completion
      await _pollForAuditCompletion(auditNotifier);
      
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
    // Animate through the analysis steps for visual feedback
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        _progressController.animateTo((i + 1) / _analysisSteps.length);
      }
    }
  }

  Future<void> _pollForAuditCompletion(AuditNotifier auditNotifier) async {
    int attempts = 0;
    const maxAttempts = 30; // 30 seconds maximum wait
    const pollInterval = Duration(seconds: 1);
    
    print("🔄 AiAnalysisScreen._pollForAuditCompletion: Starting polling");
    print("📊 Polling for audit ID: ${auditNotifier.currentAuditId}");
    
    while (attempts < maxAttempts && mounted) {
      // Check if audit is completed
      if (auditNotifier.currentAuditId != null) {
        print("📤 AiAnalysisScreen._pollForAuditCompletion: Checking status for audit ID: ${auditNotifier.currentAuditId}");
        
        await auditNotifier.getAuditStatus(auditNotifier.currentAuditId!);
        
        print("📥 AiAnalysisScreen._pollForAuditCompletion: Current status: ${auditNotifier.currentAuditStatus}");
        
        if (auditNotifier.currentAuditStatus == AuditStatus.completed) {
          print("✅ AiAnalysisScreen._pollForAuditCompletion: Audit completed! Getting report...");
          
          // Get the audit report
          await auditNotifier.getAuditReport(auditNotifier.currentAuditId!);
          
          if (mounted && auditNotifier.currentAuditReport != null) {
            print("🎯 AiAnalysisScreen._pollForAuditCompletion: Report received, navigating to results");
            
            // Complete the progress animation
            _progressController.animateTo(1.0);
            setState(() {
              _currentStep = _analysisSteps.length - 1;
            });
            
            // Wait a bit for visual feedback
            await Future.delayed(const Duration(milliseconds: 1000));
            
            // Navigate to results
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AuditResultsScreen(
                  contractName: widget.contractName,
                  fileName: widget.fileName,
                ),
              ),
            );
            return;
          }
        }
        
        if (auditNotifier.currentAuditStatus == AuditStatus.failed) {
          print("❌ AiAnalysisScreen._pollForAuditCompletion: Audit failed");
          throw Exception('Audit failed on server');
        }
      } else {
        print("⚠️ AiAnalysisScreen._pollForAuditCompletion: No audit ID available yet");
      }
      
      // Wait before next poll
      await Future.delayed(pollInterval);
      attempts++;
      
      print("⏳ AiAnalysisScreen._pollForAuditCompletion: Poll attempt $attempts/$maxAttempts");
    }
    
    // If we get here, polling timed out
    print("⏰ AiAnalysisScreen._pollForAuditCompletion: Polling timed out after $attempts attempts");
    throw Exception('Analysis timed out. Please try again.');
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
          children: [
            // Progress indicator
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
            
            // Progress labels
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('AI Analysis', style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.w600)),
                Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // Analysis animation
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Loading animation
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
                              color: Colors.purple[100]!,
                              width: 3,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purple[50],
                            ),
                            child: const Icon(
                              Icons.analytics_outlined,
                              size: 48,
                              color: Colors.purple,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  const Text(
                    'Our AI is performing a comprehensive\naudit of your smart contract',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Progress bar
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
                  
                  // Current analysis step
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
