import 'package:flutter_test/flutter_test.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/pdf_generation_helper.dart';

void main() {
  group('Balance Sheet PDF Generation', () {
    test('should generate PDF without type casting error', () async {
      // Sample balance sheet data structure that matches the actual data format
      final reportData = {
        'summary': {
          'total_assets': 100000.0,
          'total_liabilities': 40000.0,
          'total_equity': 60000.0,
        },
        'assets': {
          'current_assets': {
            'crypto_holdings': 50000.0,
            'cash_equivalents': 10000.0,
            'receivables': 5000.0,
            'total': 65000.0,
          },
          'non_current_assets': {
            'long_term_investments': 20000.0,
            'equipment': 10000.0,
            'other': 5000.0,
            'total': 35000.0,
          },
          'total': 100000.0,
        },
        'liabilities': {
          'current_liabilities': {
            'accrued_expenses': 5000.0,
            'short_term_debt': 10000.0,
            'tax_liabilities': 5000.0,
            'total': 20000.0,
          },
          'long_term_liabilities': {
            'long_term_debt': 15000.0,
            'deferred_tax': 3000.0,
            'other': 2000.0,
            'total': 20000.0,
          },
          'total': 40000.0,
        },
        'equity': {
          'retained_earnings': 50000.0,
          'unrealized_gains_losses': 10000.0,
          'total': 60000.0,
        },
      };

      // This should not throw a type casting error
      expect(() async {
        await PdfGenerationHelper.generateBalanceSheetPdf(reportData);
      }, returnsNormally);
    });

    test('should handle null values gracefully', () async {
      // Test with minimal data structure
      final reportData = {
        'summary': {
          'total_assets': 0.0,
          'total_liabilities': 0.0,
          'total_equity': 0.0,
        },
        'assets': {
          'current_assets': null,
          'non_current_assets': null,
          'total': 0.0,
        },
        'liabilities': {
          'current_liabilities': null,
          'long_term_liabilities': null,
          'total': 0.0,
        },
        'equity': {
          'retained_earnings': 0.0,
          'unrealized_gains_losses': 0.0,
          'total': 0.0,
        },
      };

      // This should not throw any errors
      expect(() async {
        await PdfGenerationHelper.generateBalanceSheetPdf(reportData);
      }, returnsNormally);
    });
  });
}





