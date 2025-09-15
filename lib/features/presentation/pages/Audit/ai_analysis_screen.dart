import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/pages/Audit/audit_results_screen.dart';

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
      duration: const Duration(seconds: 8),
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

    _startAnalysis();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
        _progressController.animateTo((i + 1) / _analysisSteps.length);
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuditResultsScreen(
            contractName: widget.contractName,
            fileName: widget.fileName,
          ),
        ),
      );
    }
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
                                
                                Text(
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
