import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/Audit/contract_setup_screen.dart';

class AuditContractMainScreen extends StatelessWidget {
  const AuditContractMainScreen({super.key});

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
                Text('Contract Setup', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('AI Analysis', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Audit Results', style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text('Assessment', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Start audit button
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 80,
                      color: Colors.purple[300],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    const Text(
                      'Smart Contract Audit',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const Text(
                      'Secure and analyze your smart contract for vulnerabilities, security risks, and optimization opportunities.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContractSetupScreen(),
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
                        child: const Text(
                          'Start Smart Audit',
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
