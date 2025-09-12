import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/notifiers/audit_notifier.dart';
import '../../../domain/entities/smart_contract.dart';
import '../../../domain/entities/audit_report.dart';
import 'audit_results_screen.dart';

class AiAnalysisScreen extends StatefulWidget {
  final String contractName;
  final String fileName;

  const AiAnalysisScreen({
    super.key,
    required this.contractName,
    required this.fileName,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen>
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
    final auditNotifier = Provider.of<AuditNotifier>(context, listen: false);
    
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
      
      // Start the UI animation and polling simultaneously
      _startUIAnimation();
      
      // Start real-time polling for audit completion (this will handle navigation)
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
    print("🎨 AiAnalysisScreen._startUIAnimation: Starting UI animation");
    
    // Animate through the analysis steps for visual feedback
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        
        // Calculate progress based on current step
        double progress = (i + 1) / _analysisSteps.length;
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
          
          // Try to get the audit report, but don't fail navigation if it fails
          try {
            await auditNotifier.getAuditReport(auditNotifier.currentAuditId!);
            print("📄 AiAnalysisScreen._pollForAuditCompletion: Report retrieved successfully");
          } catch (e) {
            print("⚠️ AiAnalysisScreen._pollForAuditCompletion: Report parsing failed: $e");
            print("🎯 AiAnalysisScreen._pollForAuditCompletion: Proceeding with navigation anyway...");
          }
          
          print("🔍 AiAnalysisScreen._pollForAuditCompletion: Checking mounted state: $mounted");
          
          if (mounted) {
            print("🎯 AiAnalysisScreen._pollForAuditCompletion: Starting navigation to results");
            
            try {
              // Ensure progress animation is at 100% (should already be there from UI animation)
              await _progressController.animateTo(1.0, duration: const Duration(milliseconds: 300));
              setState(() {
                _currentStep = _analysisSteps.length - 1;
              });
              
              print("🎨 AiAnalysisScreen._pollForAuditCompletion: Animation completed at 100%");
              
              // Wait a bit for visual feedback
              await Future.delayed(const Duration(milliseconds: 800));
              
              print("🚀 AiAnalysisScreen._pollForAuditCompletion: Attempting navigation...");
              
              // Navigate to results even if report parsing failed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuditResultsScreen(
                    contractName: widget.contractName,
                    fileName: widget.fileName,
                  ),
                ),
              );
              
              print("✅ AiAnalysisScreen._pollForAuditCompletion: Navigation completed successfully");
              return;
            } catch (navigationError) {
              print("❌ AiAnalysisScreen._pollForAuditCompletion: Navigation error: $navigationError");
              rethrow;
            }
          } else {
            print("❌ AiAnalysisScreen._pollForAuditCompletion: Widget not mounted, cannot navigate");
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        kToolbarHeight - 48, // Account for padding
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
            SizedBox(
              height: MediaQuery.of(context).size.height - 200, // Constrain height
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
    )));
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
