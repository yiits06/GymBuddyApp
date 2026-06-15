import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'help.title'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            'help.faq'.tr(),
            style: const TextStyle(
              color: AppTheme.neonLime,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildFaqTile(
            'help.q1'.tr(),
            'help.a1'.tr(),
          ),
          _buildFaqTile(
            'help.q2'.tr(),
            'help.a2'.tr(),
          ),
          _buildFaqTile(
            'help.q3'.tr(),
            'help.a3'.tr(),
          ),
          _buildFaqTile(
            'help.q4'.tr(),
            'help.a4'.tr(),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 48),
          Text(
            'help.need_more_help'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.mail_outline, color: AppTheme.neonLime),
            label: Text('help.contact_us'.tr(), style: const TextStyle(color: Colors.white)),
            onPressed: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'destek@gymbuddy.com',
                query: encodeQueryParameters(<String, String>{
                  'subject': 'GymBuddy Destek Talebi',
                }),
              );
              if (await canLaunchUrl(emailLaunchUri)) {
                await launchUrl(emailLaunchUri);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('help.email_error'.tr())));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        iconColor: AppTheme.neonLime,
        collapsedIconColor: Colors.grey,
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(answer, style: const TextStyle(color: Colors.grey, height: 1.5)),
          ),
        ],
      ),
    );
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}