import 'package:flutter/material.dart';
import 'package:cryphoria_mobile/features/presentation/manager/UserProfile/UserProfile_Views/userProfile_Views.dart';

class HelpAndSupportView extends StatefulWidget {
  const HelpAndSupportView({super.key});

  @override
  State<HelpAndSupportView> createState() => _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends State<HelpAndSupportView> {
  final _searchController = TextEditingController();
  final _messageController = TextEditingController();
  bool _messageHasText = false;
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
                  builder: (_) => const userProfile(),
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    onChanged: (value) =>
                        setState(() => _messageHasText = value.trim().isNotEmpty),
                    decoration: InputDecoration(
                      hintText: 'Describe your issue or question...',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _messageHasText
                          ? () {
                              // TODO: Submit support message
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _messageHasText
                            ? const Color(0xFF6F4CF5)
                            : const Color(0xFFD8DAE0),
                        foregroundColor: _messageHasText
                            ? Colors.white
                            : const Color(0xFF8A94A6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send Message'),
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
            color: Colors.black.withOpacity(0.02),
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
                backgroundColor: iconColor.withOpacity(0.12),
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
            color: Colors.black.withOpacity(0.01),
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