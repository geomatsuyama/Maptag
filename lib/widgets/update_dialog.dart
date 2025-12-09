import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_service.dart';

class UpdateDialog extends StatelessWidget {
  final UpdateInfo updateInfo;
  final VoidCallback onDismiss;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.system_update, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('新しいバージョンが利用可能です'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Version info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '現在のバージョン',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      Text(
                        'v${UpdateService.currentVersion}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最新バージョン',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                      Text(
                        'v${updateInfo.version}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Release date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'リリース日: ${_formatDate(updateInfo.publishedAt)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Release notes
            Text(
              'リリースノート',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                updateInfo.releaseNotes,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Web update instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Web版の更新方法',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. ブラウザのキャッシュをクリア\n'
                    '2. ページを再読み込み (Ctrl+F5 / Cmd+Shift+R)\n'
                    '3. または、GitHubから最新版をダウンロード',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss();
          },
          child: const Text('後で'),
        ),
        FilledButton.icon(
          onPressed: () async {
            final uri = Uri.parse(updateInfo.downloadUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.download, size: 18),
          label: const Text('ダウンロードページへ'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}

// Helper function to show update dialog
Future<void> showUpdateDialogIfAvailable(BuildContext context) async {
  final updateService = UpdateService();

  // Check if we should check for updates
  final shouldCheck = await updateService.shouldCheckForUpdates();
  if (!shouldCheck) return;

  // Check for updates
  final updateInfo = await updateService.checkForUpdates();
  await updateService.saveLastUpdateCheck();

  if (updateInfo != null && context.mounted) {
    // Check if this update was dismissed
    final wasDismissed = await updateService.wasUpdateDismissed(updateInfo.version);
    if (wasDismissed) return;

    // Show update dialog
    showDialog(
      context: context,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        onDismiss: () async {
          await updateService.dismissUpdate(updateInfo.version);
        },
      ),
    );
  }
}
