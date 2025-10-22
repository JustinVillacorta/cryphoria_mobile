import 'package:flutter/material.dart';

// Document Status Enum
enum DocumentStatus {
  verified,
  pending,
  required,
}

// Compliance Document Card Widget
class ComplianceDocumentCard extends StatelessWidget {
  final String title;
  final String? submittedDate;
  final String? expiryDate;
  final DocumentStatus status;
  final VoidCallback? onDownload;
  final VoidCallback? onUpload;
  final VoidCallback? onReupload;

  const ComplianceDocumentCard({
    Key? key,
    required this.title,
    this.submittedDate,
    this.expiryDate,
    required this.status,
    this.onDownload,
    this.onUpload,
    this.onReupload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Colors.deepPurple[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            if (submittedDate != null || expiryDate != null) ...[
              const SizedBox(height: 12),
              if (submittedDate != null)
                Text(
                  'Submitted: $submittedDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              if (expiryDate != null)
                Text(
                  'Expires: $expiryDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
            ],
            if (status == DocumentStatus.required) ...[
              const SizedBox(height: 8),
              Text(
                'Not yet submitted',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
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
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Verified',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case DocumentStatus.pending:
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
                Icons.access_time,
                color: Colors.orange[700],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Pending Verification',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[800],
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
                Icons.error_outline,
                color: Colors.red[600],
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Required',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildActionButton() {
    if (status == DocumentStatus.verified && onDownload != null) {
      return OutlinedButton(
        onPressed: onDownload,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_outlined, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              'Download',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    } else if (status == DocumentStatus.pending && onReupload != null) {
      return ElevatedButton(
        onPressed: onReupload,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_outlined, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Re-upload',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (status == DocumentStatus.required && onUpload != null) {
      return ElevatedButton(
        onPressed: onUpload,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          backgroundColor: Colors.deepPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_outlined, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Upload',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}