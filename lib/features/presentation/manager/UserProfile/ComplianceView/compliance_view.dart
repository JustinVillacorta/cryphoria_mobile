import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../dependency_injection/riverpod_providers.dart';
import '../../../../domain/entities/document.dart';

class ComplianceViewScreen extends ConsumerStatefulWidget {
  const ComplianceViewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ComplianceViewScreen> createState() => _ComplianceViewScreenState();
}

class _ComplianceViewScreenState extends ConsumerState<ComplianceViewScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers for business information
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessRegistrationNumberController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _businessPhoneController = TextEditingController();
  final TextEditingController _businessEmailController = TextEditingController();

  // File upload states
  File? _dtiDocument;
  File? _birForm;
  File? _managerId;
  
  bool _isUploading = false;
  List<Document> _myDocuments = [];
  bool _isLoadingDocuments = false;

  @override
  void initState() {
    super.initState();
    _loadMyDocuments();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessRegistrationNumberController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    super.dispose();
  }


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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              _buildMyDocumentsSection(),
              const SizedBox(height: 24),
              // Business Information Section
              _buildSectionHeader(
                'Business Information',
                Icons.business,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildBusinessInfoForm(),
              
              const SizedBox(height: 32),
              
              // Document Upload Section
              _buildSectionHeader(
                'Required Documents',
                Icons.upload_file,
                Colors.deepPurple,
              ),
              const SizedBox(height: 16),
              _buildDocumentUploads(),
              
              const SizedBox(height: 32),
              
              // Submit Button
              _buildSubmitButton(),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyDocumentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.folder_open,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'My Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isLoadingDocuments)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: _loadMyDocuments,
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh documents',
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingDocuments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_myDocuments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No documents uploaded yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Upload your compliance documents below',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _myDocuments.map((document) => _buildDocumentCard(document)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getDocumentTypeColor(document.documentType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              _getDocumentTypeIcon(document.documentType),
              color: _getDocumentTypeColor(document.documentType),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDocumentTypeDisplayName(document.documentType),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  document.fileName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(document.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getStatusDisplayName(document.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(document.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(document.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (document.fileUrl != null)
            IconButton(
              onPressed: () {
                // TODO: Implement document preview/download
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document preview not implemented yet'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 18),
              tooltip: 'View document',
            ),
        ],
      ),
    );
  }

  IconData _getDocumentTypeIcon(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'business_registration':
        return Icons.business;
      case 'tax_id':
        return Icons.receipt;
      case 'company_license':
        return Icons.badge;
      default:
        return Icons.description;
    }
  }

  Color _getDocumentTypeColor(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'business_registration':
        return Colors.blue;
      case 'tax_id':
        return Colors.orange;
      case 'company_license':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getDocumentTypeDisplayName(String documentType) {
    switch (documentType.toLowerCase()) {
      case 'business_registration':
        return 'Business Registration';
      case 'tax_id':
        return 'Tax ID (BIR Form)';
      case 'company_license':
        return 'Company License (Manager ID)';
      default:
        return documentType;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under Review';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
              style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _businessNameController,
            label: 'Business Name',
            hint: 'Enter your business name',
            icon: Icons.business,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessTypeController,
            label: 'Business Type',
            hint: 'e.g., Corporation, Partnership, Sole Proprietorship',
            icon: Icons.category,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business type is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessRegistrationNumberController,
            label: 'Business Registration Number',
            hint: 'Enter your DTI/SEC registration number',
            icon: Icons.assignment,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business registration number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessAddressController,
            label: 'Business Address',
            hint: 'Enter your complete business address',
            icon: Icons.location_on,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessPhoneController,
            label: 'Business Phone Number',
            hint: 'Enter your business phone number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _businessEmailController,
            label: 'Business Email Address',
            hint: 'Enter your business email address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business email address is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildDocumentUploads() {
    return Column(
      children: [
        _buildFileUploadCard(
          title: 'DTI Business Registration Document',
          subtitle: 'PDF, JPG, PNG, DOC, DOCX - Max 5MB',
          icon: Icons.description,
          file: _dtiDocument,
          onUpload: () => _pickFile('DTI Document'),
        ),
        const SizedBox(height: 16),
        _buildFileUploadCard(
          title: 'BIR Form',
          subtitle: 'PDF, JPG, PNG, DOC, DOCX - Max 5MB',
          icon: Icons.receipt,
          file: _birForm,
          onUpload: () => _pickFile('BIR Form'),
        ),
        const SizedBox(height: 16),
        _buildFileUploadCard(
          title: 'Manager Government ID',
          subtitle: 'PDF, JPG, PNG, DOC, DOCX - Max 5MB',
          icon: Icons.badge,
          file: _managerId,
          onUpload: () => _pickFile('Manager ID'),
        ),
      ],
    );
  }

  Widget _buildFileUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    File? file,
    required VoidCallback onUpload,
  }) {
    final bool isUploaded = file != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isUploaded 
            ? Border.all(color: Colors.green, width: 2)
            : Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUploaded 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isUploaded ? Colors.green : Colors.deepPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploaded)
                Container(
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
                        'Uploaded',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            ),
            const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: Icon(
                isUploaded ? Icons.refresh : Icons.upload,
                size: 18,
              ),
              label: Text(isUploaded ? 'Re-upload' : 'Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded ? Colors.orange : Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (isUploaded) ...[
            const SizedBox(height: 8),
            Text(
              'File: ${file.path.split('/').last}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final bool dtiDocumentValid = _dtiDocument != null;
    final bool birFormValid = _birForm != null;
    final bool managerIdValid = _managerId != null;

    final bool canSubmit = dtiDocumentValid &&
        birFormValid &&
        managerIdValid;


    return Column(
      children: [
        // Debug info (only show when not all fields are complete)
        if (!canSubmit) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Upload all required documents:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (!dtiDocumentValid) _buildMissingFieldChip('DTI Document'),
                    if (!birFormValid) _buildMissingFieldChip('BIR Form'),
                    if (!managerIdValid) _buildMissingFieldChip('Manager ID'),
                  ],
                ),
              ],
            ),
          ),
        ],
        
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSubmit && !_isUploading ? _submitCompliance : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canSubmit ? Colors.deepPurple : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canSubmit ? 2 : 0,
            ),
            child: _isUploading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Submitting...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    canSubmit ? 'Upload Documents' : 'Upload All Documents',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissingFieldChip(String fieldName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        fieldName,
        style: TextStyle(
          fontSize: 10,
          color: Colors.red[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _pickFile(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final pickedFile = result.files.first;
        
        // Check file size (10MB limit)
        if (pickedFile.size > 10 * 1024 * 1024) {
          if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size exceeds 10MB limit'),
                backgroundColor: Colors.red,
                            ),
                          );
                        }
          return;
        }

        setState(() {
          switch (documentType) {
            case 'DTI Document':
              _dtiDocument = File(pickedFile.path ?? pickedFile.name);
              break;
            case 'BIR Form':
              _birForm = File(pickedFile.path ?? pickedFile.name);
              break;
            case 'Manager ID':
              _managerId = File(pickedFile.path ?? pickedFile.name);
              break;
          }
        });

        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
              content: Text('$documentType uploaded successfully'),
              backgroundColor: Colors.green,
                            ),
                          );
                        }
      }
    } catch (e) {
      if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
            content: Text('Error uploading file: ${e.toString()}'),
            backgroundColor: Colors.red,
                            ),
                          );
                        }
    }
  }

  Future<void> _submitCompliance() async {
    if (_dtiDocument == null || _birForm == null || _managerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      print("🚀 Starting document upload...");
      
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Uploading documents...'),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we upload your documents',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
      
      final uploadUseCase = ref.read(uploadBusinessDocumentsUseCaseProvider);
      
      await uploadUseCase.execute(
        businessName: '', // Not sending business info for now
        businessType: '',
        businessRegistrationNumber: '',
        businessAddress: '',
        businessPhone: '',
        businessEmail: '',
        dtiDocument: _dtiDocument!,
        birForm: _birForm!,
        managerId: _managerId!,
      );

      // Update progress dialog to show submitting
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Submitting for approval...'),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we submit your documents',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        );
      }

      // Submit documents for approval
      await uploadUseCase.submitDocumentsForApproval();

      // Close progress dialog
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documents uploaded and submitted for approval successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Clear the form after successful submission
        _clearForm();
        
        // Reload documents to show the newly uploaded ones
        _loadMyDocuments();
      }
    } catch (e) {
      // Close progress dialog if it's open
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading documents: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
      ),
    );
  }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _clearForm() {
    setState(() {
      _dtiDocument = null;
      _birForm = null;
      _managerId = null;
    });
  }

  Future<void> _loadMyDocuments() async {
    setState(() {
      _isLoadingDocuments = true;
    });

    try {
      final uploadUseCase = ref.read(uploadBusinessDocumentsUseCaseProvider);
      final documents = await uploadUseCase.getMyDocuments();
      
      if (mounted) {
        setState(() {
          _myDocuments = documents;
          _isLoadingDocuments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDocuments = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading documents: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

}