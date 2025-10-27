import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String searchQuery = '';

  final List<FAQItem> faqItems = [
    FAQItem(
      question: "How do I connect my wallet?",
      answer: "To connect your wallet:\n\n1. Click on the 'Connect Wallet' button in the top right corner\n2. Select your preferred wallet provider (MetaMask, WalletConnect, etc.)\n3. Follow the prompts in your wallet app to authorize the connection\n4. Once connected, you'll see your wallet address displayed\n\nSupported wallets include MetaMask, Trust Wallet, Coinbase Wallet, and any WalletConnect-compatible wallet.",
    ),
    FAQItem(
      question: "How are transaction fees calculated?",
      answer: "Transaction fees are calculated based on several factors:\n\n• Network Gas Fees: The current network congestion and gas price\n• Transaction Complexity: Simple transfers cost less than smart contract interactions\n• Priority Level: Higher priority transactions cost more but process faster\n\nOur platform shows you the estimated fees before confirming any transaction. Fees are paid in the native currency of the blockchain (ETH for Ethereum, BNB for BSC, etc.).",
    ),
    FAQItem(
      question: "Is my data secure?",
      answer: "Yes, we take data security very seriously:\n\n• End-to-end encryption for all sensitive data\n• We never store your private keys or seed phrases\n• All data is encrypted both in transit and at rest\n• Regular security audits by third-party firms\n• SOC 2 Type II compliance\n• Two-factor authentication (2FA) available\n\nWe follow industry best practices and regulatory requirements to ensure your data remains safe and private.",
    ),
    FAQItem(
      question: "How do I generate an invoice?",
      answer: "To generate an invoice:\n\n1. Navigate to the 'Invoices' section in your dashboard\n2. Click 'Create New Invoice'\n3. Fill in the required details:\n   - Customer information\n   - Invoice items and amounts\n   - Due date\n   - Payment terms\n4. Select your preferred cryptocurrency for payment\n5. Click 'Generate Invoice'\n\nYou can then share the invoice link with your customer, who can pay directly using their crypto wallet.",
    ),
    FAQItem(
      question: "What compliance documents do I need to provide?",
      answer: "Required compliance documents vary by region and account type:\n\n• Individual Accounts:\n  - Government-issued ID (passport, driver's license)\n  - Proof of address (utility bill, bank statement)\n  - KYC form completion\n\n• Business Accounts:\n  - Business registration certificate\n  - Tax identification documents\n  - Proof of business address\n  - Beneficial ownership information\n  - Directors/shareholders information\n\nAll documents should be clear, recent (within 3 months), and in accepted formats (PDF, JPG, PNG).",
    ),
  ];

  List<FAQItem> get filteredFAQItems {
    if (searchQuery.isEmpty) return faqItems;
    return faqItems.where((item) =>
    item.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
        item.answer.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
          'Help',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF9747FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Color(0xFF9747FF),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Frequently Asked Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF9747FF)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            ...filteredFAQItems.map((faq) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ExpandableFAQCard(faq: faq),
            )),

            if (filteredFAQItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No FAQs found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search terms',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFF9747FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent,
                    color: Color(0xFF9747FF),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact Support',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _contactController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Describe your issue or question...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300] ?? Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF9747FF)),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _sendMessage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9747FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_contactController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your message'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Sent'),
          content: const Text('Thank you for contacting us! We\'ll get back to you within 24 hours.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _contactController.clear();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class ExpandableFAQCard extends StatefulWidget {
  final FAQItem faq;

  const ExpandableFAQCard({super.key, required this.faq});

  @override
  State<ExpandableFAQCard> createState() => _ExpandableFAQCardState();
}

class _ExpandableFAQCardState extends State<ExpandableFAQCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _animation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.faq.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}