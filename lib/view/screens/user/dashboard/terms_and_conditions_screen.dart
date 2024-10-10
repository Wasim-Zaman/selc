import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: [Date]',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              theme,
              '1. Acceptance of Terms',
              'By accessing and using this application, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              theme,
              '2. Use License',
              'Permission is granted to temporarily download one copy of the materials (information or software) on SELC\'s application for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              theme,
              '3. Disclaimer',
              'The materials on SELC\'s application are provided on an \'as is\' basis. SELC makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            _buildSection(
              theme,
              '4. Limitations',
              'In no event shall SELC or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on SELC\'s application, even if SELC or a SELC authorized representative has been notified orally or in writing of the possibility of such damage.',
            ),
            _buildSection(
              theme,
              '5. Revisions and Errata',
              'The materials appearing on SELC\'s application could include technical, typographical, or photographic errors. SELC does not warrant that any of the materials on its application are accurate, complete or current. SELC may make changes to the materials contained on its application at any time without notice.',
            ),
            _buildSection(
              theme,
              '6. Governing Law',
              'These terms and conditions are governed by and construed in accordance with the laws of [Your Country/State] and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
