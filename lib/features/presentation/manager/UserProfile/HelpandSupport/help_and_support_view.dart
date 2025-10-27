import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/UserProfile_Views/user_profile_views.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import 'support_history_view.dart';

class HelpAndSupportView extends ConsumerStatefulWidget {
  const HelpAndSupportView({super.key});

  @override
  ConsumerState<HelpAndSupportView> createState() => _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends ConsumerState<HelpAndSupportView> {
  final _searchController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _messageHasText = false;
  bool _subjectHasText = false;
  String _selectedCategory = 'technical';
  String _selectedPriority = 'medium';
  final List<File> _selectedFiles = [];
  final List<_FaqItem> _faqs = const [
    _FaqItem(
      question: 'How do I connect my wallet?',
      answer:
          'Open the Wallet section, choose your provider, and follow the on-screen pairing instructions. Once confirmed, the wallet status will show as connected.',
    ),
    _FaqItem(
      question: 'How are transaction fees calculated?',
      answer:
          'Fees are based on the network cost at the moment of execution. Before you confirm, the estimated fee is shown so you can review the final total.',
    ),
    _FaqItem(
      question: 'Is my data secure?',
      answer:
          'All sensitive information is encrypted at rest and in transit. We use industry-standard security controls and regularly audit our infrastructure.',
    ),
    _FaqItem(
      question: 'How do I generate an invoice?',
      answer:
          'Go to Transactions, tap the payment you need, and select “Generate Invoice.” You can download the PDF or send it directly via email.',
    ),
    _FaqItem(
      question: 'What compliance documents do I need to provide?',
      answer:
          'You will need a government-issued ID, proof of address, and where applicable, business registration documents to complete KYC verification.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF1A1D1F),
          onPressed: () {
            if (Navigator.of(context).canPop()) { 
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const UserProfile(),
                ),
              );
            }
          },
        ),
        title: Text(
          'Help',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            _SectionCard(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF6F4CF5),
              title: 'Frequently Asked Questions',
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search FAQs...',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9AA2B1),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF0F2F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF9AA2B1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._faqs.map(
                    (faq) => _FaqTile(
                      question: faq.question,
                      answer: faq.answer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: const Color(0xFF6F4CF5),
              title: 'Contact Support',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How can we help you?',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6F7787),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _subjectController,
                    onChanged: (value) =>
                        setState(() => _subjectHasText = value.trim().isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Subject',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9AA2B1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E8EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E8EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category',
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6F7787),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE6E8EB),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'technical', child: Text('Technical')),
                                    DropdownMenuItem(value: 'billing', child: Text('Billing')),
                                    DropdownMenuItem(value: 'account', child: Text('Account')),
                                    DropdownMenuItem(value: 'general', child: Text('General')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCategory = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Priority',
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF6F7787),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE6E8EB),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPriority,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'low', child: Text('Low')),
                                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                    DropdownMenuItem(value: 'high', child: Text('High')),
                                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPriority = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    onChanged: (value) =>
                        setState(() => _messageHasText = value.trim().isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Describe your issue or question...',
                      helperText: 'Message must be at least 10 characters long',
                      helperStyle: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF9AA2B1),
                      ),
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9AA2B1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E8EB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE6E8EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attachments (Optional)',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF6F7787),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFiles,
                              icon: const Icon(Icons.attach_file, size: 18),
                              label: const Text('Add Files'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF6F4CF5),
                                side: const BorderSide(color: Color(0xFF6F4CF5)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _selectedFiles.isNotEmpty ? _clearFiles : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      if (_selectedFiles.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ..._selectedFiles.asMap().entries.map((entry) {
                          final index = entry.key;
                          final file = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE6E8EB)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_file, size: 16, color: Color(0xFF6F4CF5)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.path.split('/').last,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF1A1D1F),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _removeFile(index),
                                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canSubmit()
                              ? () => _submitSupportTicket()
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canSubmit()
                                ? const Color(0xFF6F4CF5)
                                : const Color(0xFFD8DAE0),
                            foregroundColor: _canSubmit()
                                ? Colors.white
                                : const Color(0xFF8A94A6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: ref.watch(supportViewModelProvider).isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Send Message'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _navigateToSupportHistory(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6F4CF5),
                          side: const BorderSide(color: Color(0xFF6F4CF5)),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View History'),
                      ),
                    ],
                  ),

                  Builder(
                    builder: (context) {
                      final state = ref.watch(supportViewModelProvider);
                      if (state.errorMessage != null) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.errorMessage!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      if (state.successMessage != null) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline, color: Colors.green[700], size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.successMessage!,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSubmit() {
    final state = ref.watch(supportViewModelProvider);
    return _subjectHasText && _messageHasText && !state.isSubmitting;
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _selectedFiles.add(File(file.path!));
            }
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _submitSupportTicket() async {
    final supportViewModel = ref.read(supportViewModelProvider.notifier);

    supportViewModel.clearMessages();

    final success = await supportViewModel.submitSupportTicket(
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      attachments: _selectedFiles.map((file) => file.path).toList(),
    );

    if (success) {
      _subjectController.clear();
      _messageController.clear();
      _selectedFiles.clear();
      setState(() {
        _subjectHasText = false;
        _messageHasText = false;
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          supportViewModel.clearMessages();
        }
      });
    }
  }

  void _navigateToSupportHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SupportHistoryView(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withValues(alpha: 0.12),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1D1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        trailing: Icon(
          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: const Color(0xFF6F4CF5),
        ),
        onExpansionChanged: (expanded) =>
            setState(() => _expanded = expanded),
        title: Text(
          widget.question,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D1F),
          ),
        ),
        children: [
          Text(
            widget.answer,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F7787),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}