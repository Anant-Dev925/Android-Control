import 'package:flutter/material.dart';
import 'package:android_control/core/constants/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSection(context, 'App Info', [
            _buildInfoRow(context, 'App Name', AppConstants.appName),
            _buildInfoRow(context, 'Version', '1.0.0'),
            _buildInfoRow(context, 'Build', 'Debug'),
          ]),
          _buildSection(context, 'AI Model', [
            _buildInfoRow(context, 'Model', 'qwen2.5-coder:7b'),
            _buildInfoRow(context, 'Provider', 'Ollama (Local)'),
            _buildInfoRow(context, 'Context Window', '~8K tokens'),
          ]),
          _buildSection(context, 'Capabilities', [
            _buildCapabilityItem(
              context,
              Icons.folder_open,
              'File Management',
              'Read, write, delete files via ADB',
            ),
            _buildCapabilityItem(
              context,
              Icons.description,
              'Document Processing',
              'PDF, DOCX, PPTX creation & editing',
            ),
            _buildCapabilityItem(
              context,
              Icons.school,
              'Train Mode',
              'Learn from files using /train command',
            ),
            _buildCapabilityItem(
              context,
              Icons.terminal,
              'Commands',
              '/train, /forget, and file operations',
            ),
          ]),
          _buildSection(context, 'Developer', [
            _buildInfoRow(context, 'Developer', 'Anant Dev Mishra'),
            _buildInfoRow(context, 'Purpose', 'Personal Project'),
            _buildInfoRow(context, 'Stack', 'Flutter + Node.js + Ollama'),
          ]),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How It Works',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This app connects to a local server running on the user\'s PC. '
                    'The server uses Ollama to run AI models locally, giving the user '
                    'full control over their data.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The AI can access files on the user\'s Android device through ADB '
                    '(Android Debug Bridge) over Tailscale VPN.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Made with ❤️ for learning',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-Powered Android Control',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCapabilityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
