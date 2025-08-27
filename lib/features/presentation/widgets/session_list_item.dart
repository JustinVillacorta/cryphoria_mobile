import 'package:flutter/material.dart';
import '../../domain/entities/user_session.dart';

class SessionListItem extends StatelessWidget {
  final UserSession session;
  final VoidCallback? onApprove;
  final VoidCallback? onRevoke;
  final bool canApprove;

  const SessionListItem({
    super.key,
    required this.session,
    this.onApprove,
    this.onRevoke,
    this.canApprove = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(),
                  color: session.isCurrent ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.deviceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: session.isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (session.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Current',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (!session.isLegacy) ...[
              Text('Device ID: ${session.deviceId}'),
              Text('IP: ${session.ip}'),
              Text('Created: ${_formatDate(session.createdAt)}'),
              if (session.lastSeen != null)
                Text('Last seen: ${_formatDate(session.lastSeen!)}'),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.approved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    session.approved ? 'Approved' : 'Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                if (session.isLegacy)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Legacy',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!session.approved && canApprove && onApprove != null)
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const Spacer(),
                if (!session.isCurrent && onRevoke != null)
                  ElevatedButton.icon(
                    onPressed: onRevoke,
                    icon: const Icon(Icons.close),
                    label: const Text('Revoke'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    if (session.isLegacy) return Icons.computer;
    
    final deviceName = session.deviceName.toLowerCase();
    if (deviceName.contains('iphone') || deviceName.contains('ipad')) {
      return Icons.phone_iphone;
    } else if (deviceName.contains('android')) {
      return Icons.phone_android;
    } else if (deviceName.contains('mac')) {
      return Icons.laptop_mac;
    } else if (deviceName.contains('windows') || deviceName.contains('pc')) {
      return Icons.computer;
    } else {
      return Icons.devices;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
