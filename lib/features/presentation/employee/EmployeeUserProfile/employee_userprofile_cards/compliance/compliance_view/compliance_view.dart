import 'package:flutter/material.dart';

class ComplianceScreen extends StatelessWidget {
  const ComplianceScreen({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Compliance Documents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Tax Identification Document
            ComplianceDocumentCard(
              icon: Icons.description,
              iconColor: Color(0xFF9747FF),
              title: 'Tax Identification Document',
              subtitle: 'Submitted: 3/15/2023',
              status: DocumentStatus.verified,
              onActionPressed: () {},
            ),

            const SizedBox(height: 16),

            // Business Registration
            ComplianceDocumentCard(
              icon: Icons.description,
              iconColor: Color(0xFF9747FF),
              title: 'Business Registration',
              subtitle: 'Submitted: 2/10/2023\nExpires: 21/9/2024',
              status: DocumentStatus.verified,
              onActionPressed: () {},
            ),

            const SizedBox(height: 16),

            // Proof of Address
            ComplianceDocumentCard(
              icon: Icons.description,
              iconColor: Color(0xFF9747FF),
              title: 'Proof of Address',
              subtitle: 'Submitted: 6/1/2023',
              status: DocumentStatus.pendingVerification,
              onActionPressed: () {},
            ),

            const SizedBox(height: 16),

            // KYC Form
            ComplianceDocumentCard(
              icon: Icons.description,
              iconColor: Color(0xFF9747FF),
              title: 'KYC Form',
              subtitle: 'Not yet submitted',
              status: DocumentStatus.required,
              onActionPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

enum DocumentStatus { verified, pendingVerification, required }

class ComplianceDocumentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final DocumentStatus status;
  final VoidCallback onActionPressed;

  const ComplianceDocumentCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildStatusIndicator(),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    switch (status) {
      case DocumentStatus.verified:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Verified',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case DocumentStatus.pendingVerification:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                color: Colors.orange[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Pending Verification',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case DocumentStatus.required:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error,
                color: Colors.red[600],
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Required',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildActionButton() {
    switch (status) {
      case DocumentStatus.verified:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Download'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      case DocumentStatus.pendingVerification:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Reupload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9747FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      case DocumentStatus.required:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF9747FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
    }
  }
}

// Example usage:
// To use this screen, simply navigate to it:
// Navigator.push(
//   context,
//   MaterialPageRoute(builder: (context) => const ComplianceScreen()),
// );