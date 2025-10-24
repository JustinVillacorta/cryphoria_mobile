import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Static Terms & Conditions content widget.
class TermsAndConditionsContent extends StatelessWidget {
  const TermsAndConditionsContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final isTablet = size.width > 600;

    Widget sectionTitle(String text) => Padding(
          padding: EdgeInsets.only(top: isSmallScreen ? 16 : 20, bottom: isSmallScreen ? 8 : 12),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 18 : isSmallScreen ? 16 : 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        );

    Widget paragraph(String text) => Padding(
          padding: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: isTablet ? 15 : isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A4A4A),
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        );

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isTablet ? 24 : 16,
        isSmallScreen ? 16 : 20,
        isTablet ? 24 : 16,
        isSmallScreen ? 20 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          paragraph(
            'Welcome to Cryphoria. By downloading, accessing, or using our application, you agree to the following Terms and Conditions. Please read them carefully before using our services.',
          ),
          
          sectionTitle('Acceptance of Terms'),
          paragraph(
            'By creating an account or accessing the application, you enter into a binding agreement to comply with these Terms and Conditions and all applicable laws and regulations governing your use of the services. Your continued use of the application constitutes ongoing acceptance of these terms as they may be modified from time to time.',
          ),

          sectionTitle('Data Collection and Usage'),
          paragraph(
            'To provide our services, we collect and process certain information including personal and business details such as employee names and business credentials, as well as financial data including budgets, wallet addresses, and transaction records. All information collected is used exclusively to deliver and enhance our services.',
          ),
          paragraph(
            'We are committed to safeguarding your privacy in strict accordance with the Data Privacy Act of 2012 (Republic Act No. 10173) of the Republic of the Philippines and all other applicable data protection legislation. Your personal data is processed securely, stored with appropriate confidentiality measures, and will not be disclosed to third parties without your explicit prior consent except where required by law or regulatory authority.',
          ),

          sectionTitle('Service Scope and Limitations'),
          paragraph(
            'The Cryphoria platform is designed to facilitate cryptocurrency-based payroll distribution. At this time, the system only supports businesses or organizations that pay employees on a fixed monthly salary basis.',
          ),
          paragraph(
            'The platform does not support or calculate hourly wages, commission-based compensation, attendance tracking, or overtime pay. Users acknowledge and accept full responsibility for verifying the accuracy of all payment amounts prior to initiating any transaction through the platform.',
          ),

          sectionTitle('Financial Transactions Disclaimer'),
          paragraph(
            'Users bear sole responsibility for ensuring the accuracy of all wallet addresses and transaction details they enter. Cryphoria is not liable for any loss of funds resulting from incorrect recipient information, fraudulent activities, or scams occurring outside our platform.',
          ),
          paragraph(
            'All cryptocurrency transactions executed through the platform are final and irreversible. Users are strongly advised to carefully verify all information before confirming any transaction.',
          ),

          sectionTitle('Artificial Intelligence and Automated Processing'),
          paragraph(
            'This application leverages Artificial Intelligence (AI) and Large Language Models (LLMs) to streamline accounting and financial operations. While we maintain high standards for accuracy, users should be aware that AI-generated results may occasionally contain errors, inaccuracies, or require human verification.',
          ),
          paragraph(
            'Users are responsible for reviewing and validating all automated results before making critical decisions.',
          ),

          sectionTitle('User Responsibilities'),
          paragraph(
            'Users are required to provide accurate, complete, and current information and to maintain the security of their account credentials. The platform must be used exclusively for lawful purposes.',
          ),
          paragraph(
            'Any engagement in fraudulent, illegal, or unauthorized activities will result in immediate termination of account access without prior notice and may be reported to appropriate legal and regulatory authorities. Users must promptly notify Cryphoria of any suspected unauthorized access to their account.',
          ),

          sectionTitle('Amendments to Terms'),
          paragraph(
            'Cryphoria reserves the right to modify or update these Terms and Conditions at any time. All modifications shall become effective immediately upon publication within the application.',
          ),
          paragraph(
            'Continued use of the application following any such modification constitutes binding acceptance of the revised terms. Users are encouraged to review these terms periodically to remain informed of any changes.',
          ),

          sectionTitle('Contact Us'),
          paragraph(
            'For inquiries, concerns, or requests regarding these Terms and Conditions, please contact us at:',
          ),
          Padding(
            padding: EdgeInsets.only(left: isTablet ? 0 : 0, bottom: isSmallScreen ? 10 : 12),
            child: SelectableText(
              'cryphoria.team@gmail.com',
              style: GoogleFonts.inter(
                fontSize: isTablet ? 15 : isSmallScreen ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9747FF),
            
              ),
            ),
          ),
        ],
      ),
    );
  }
}

