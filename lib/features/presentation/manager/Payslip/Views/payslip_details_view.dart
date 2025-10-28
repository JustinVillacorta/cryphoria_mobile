import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import '../../../../domain/entities/payslip.dart';
import '../../../widgets/reports/pdf_generation_helper.dart';
import '../../../widgets/payslip/payslip_header_card.dart';
import '../../../widgets/payslip/payslip_info_card.dart';
import '../../../widgets/payslip/payslip_earnings_card.dart';
import '../../../widgets/payslip/payslip_deductions_card.dart';
import '../../../widgets/payslip/payslip_net_pay_card.dart';
import '../../../widgets/payslip/payslip_payment_status_card.dart';

class PayslipDetailsView extends ConsumerWidget {
  final Payslip payslip;

  const PayslipDetailsView({super.key, required this.payslip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 1024;
    final isSmallScreen = size.height < 700;
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : 20.0;
    final maxContentWidth = isDesktop ? 1000.0 : isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF1A1A1A),
            size: isTablet ? 26 : 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payslip Details',
          style: GoogleFonts.inter(
            color: const Color(0xFF1A1A1A),
            fontSize: isDesktop ? 20.0 : isTablet ? 19.0 : 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.picture_as_pdf_outlined,
              color: const Color(0xFF1A1A1A),
              size: isTablet ? 24 : 22,
            ),
            onPressed: () => _generatePdf(context),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isSmallScreen ? 8 : 12),
                PayslipHeaderCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                PayslipInfoCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                PayslipEarningsCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                PayslipDeductionsCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                PayslipNetPayCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                PayslipPaymentStatusCard(
                  payslip: payslip,
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _generatePdf(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9747FF)),
            strokeWidth: 2.5,
          ),
        ),
      );

      final payslipData = payslip.toJson();
      final pdfPath = await PdfGenerationHelper.generatePayslipPdf(payslipData);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (pdfPath.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payslip PDF saved successfully!\nTap to open: ${pdfPath.split('/').last}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                final scaffoldContext = context;
                try {
                  await OpenFile.open(pdfPath);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Could not open file: $e',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: Colors.orange[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate payslip PDF',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error generating PDF: $e',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}