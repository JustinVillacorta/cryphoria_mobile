import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/widgets/compliance.dart';
// Fake Data Model
class ComplianceDocument {
  final String title;
  final String? submittedDate;
  final String? expiryDate;
  final DocumentStatus status;

  ComplianceDocument({
    required this.title,
    this.submittedDate,
    this.expiryDate,
    required this.status,
  });
}

class ComplianceViewScreen extends StatelessWidget {
  const ComplianceViewScreen({Key? key}) : super(key: key);

  // Fake data
  static final List<ComplianceDocument> _fakeDocuments = [
    ComplianceDocument(
      title: 'Tax Identification Document',
      submittedDate: '3/15/2023',
      status: DocumentStatus.verified,
    ),
    ComplianceDocument(
      title: 'Business Registration',
      submittedDate: '2/10/2023',
      expiryDate: '2/10/2024',
      status: DocumentStatus.verified,
    ),
    ComplianceDocument(
      title: 'Proof of Address',
      submittedDate: '6/1/2023',
      status: DocumentStatus.pending,
    ),
    ComplianceDocument(
      title: 'KYC Form',
      status: DocumentStatus.required,
    ),
    ComplianceDocument(
      title: 'Bank Statement',
      submittedDate: '8/22/2023',
      expiryDate: '8/22/2024',
      status: DocumentStatus.verified,
    ),
    ComplianceDocument(
      title: 'Business License',
      submittedDate: '5/30/2023',
      status: DocumentStatus.pending,
    ),
    ComplianceDocument(
      title: 'Insurance Certificate',
      status: DocumentStatus.required,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Compliance',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance Documents',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Build cards from fake data
            ...List.generate(_fakeDocuments.length, (index) {
              final doc = _fakeDocuments[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _fakeDocuments.length - 1 ? 12 : 0,
                ),
                child: ComplianceDocumentCard(
                  title: doc.title,
                  submittedDate: doc.submittedDate,
                  expiryDate: doc.expiryDate,
                  status: doc.status,
                  onDownload: doc.status == DocumentStatus.verified
                      ? () {
                          print('Download ${doc.title}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading ${doc.title}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  onReupload: doc.status == DocumentStatus.pending
                      ? () {
                          print('Re-upload ${doc.title}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Re-uploading ${doc.title}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                  onUpload: doc.status == DocumentStatus.required
                      ? () {
                          print('Upload ${doc.title}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Uploading ${doc.title}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}