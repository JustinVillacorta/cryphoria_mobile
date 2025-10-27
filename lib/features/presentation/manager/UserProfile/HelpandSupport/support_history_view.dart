import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cryphoria_mobile/dependency_injection/riverpod_providers.dart';
import '../../../../domain/entities/support_ticket.dart';

class SupportHistoryView extends ConsumerStatefulWidget {
  const SupportHistoryView({super.key});

  @override
  ConsumerState<SupportHistoryView> createState() => _SupportHistoryViewState();
}

class _SupportHistoryViewState extends ConsumerState<SupportHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportViewModelProvider).loadSupportMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final supportViewModel = ref.watch(supportViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF1A1D1F),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Support History',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF1A1D1F),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => supportViewModel.refreshSupportMessages(),
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFF6F4CF5),
          ),
        ],
      ),
      body: supportViewModel.isLoadingMessages
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6F4CF5)),
              ),
            )
          : supportViewModel.supportMessages.isEmpty
              ? _buildEmptyState(textTheme)
              : RefreshIndicator(
                  onRefresh: () => supportViewModel.refreshSupportMessages(),
                  color: const Color(0xFF6F4CF5),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    itemCount: supportViewModel.supportMessages.length,
                    itemBuilder: (context, index) {
                      final message = supportViewModel.supportMessages[index];
                      return _buildSupportTicketCard(message, textTheme);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.support_agent_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Support Tickets Yet',
            style: textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF1A1D1F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You haven\'t submitted any support tickets yet.\nTap the back button to create your first ticket.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F7787),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTicketCard(SupportMessage message, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Text(
                  message.subject,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF1A1D1F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStatusChip(message.status),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            message.message,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6F7787),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildDetailChip(
                Icons.category_outlined,
                _getCategoryDisplayName(message.category),
                const Color(0xFF6F4CF5),
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                Icons.priority_high,
                _getPriorityDisplayName(message.priority),
                _getPriorityColor(message.priority),
              ),
              const Spacer(),
              Text(
                _formatDate(message.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF9AA2B1),
                ),
              ),
            ],
          ),

          if (message.attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16, color: Color(0xFF6F4CF5)),
                const SizedBox(width: 4),
                Text(
                  '${message.attachments.length} attachment(s)',
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6F4CF5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;

    switch (status.toLowerCase()) {
      case 'open':
        backgroundColor = Colors.blue[50]!;
        break;
      case 'in_progress':
        backgroundColor = Colors.orange[50]!;
        break;
      case 'resolved':
        backgroundColor = Colors.green[50]!;
        break;
      case 'closed':
        backgroundColor = Colors.grey[50]!;
        break;
      default:
        backgroundColor = Colors.grey[50]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusDisplayName(status),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return 'Technical';
      case 'billing':
        return 'Billing';
      case 'account':
        return 'Account';
      case 'general':
        return 'General';
      default:
        return category;
    }
  }

  String _getPriorityDisplayName(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Low';
      case 'medium':
        return 'Medium';
      case 'high':
        return 'High';
      case 'urgent':
        return 'Urgent';
      default:
        return priority;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}