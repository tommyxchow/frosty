import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ReleaseNotes extends StatefulWidget {
  const ReleaseNotes({super.key});

  @override
  State<ReleaseNotes> createState() => _ReleaseNotesState();
}

class _ReleaseNotesState extends State<ReleaseNotes> {
  String releaseNotes = '';

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/release-notes.md').then(
      (changelog) {
        setState(() {
          releaseNotes = changelog;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Release notes'),
      ),
      body: Markdown(
        data: releaseNotes,
        styleSheet: MarkdownStyleSheet(
          h2: const TextStyle(fontSize: 20),
          h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          h3Padding: const EdgeInsets.only(top: 16),
          h4: const TextStyle(fontSize: 14),
          h4Padding: const EdgeInsets.only(top: 16),
          p: const TextStyle(fontSize: 14),
          horizontalRuleDecoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.transparent,
                width: 32,
              ),
            ),
          ),
        ),
        onTapLink: (text, href, title) {
          if (href != null) {
            launchUrlString(
              href,
              mode: context.read<SettingsStore>().launchUrlExternal
                  ? LaunchMode.externalApplication
                  : LaunchMode.inAppBrowserView,
            );
          }
        },
      ),
    );
  }
}
