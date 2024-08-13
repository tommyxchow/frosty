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
      body: Column(
        children: [
          Expanded(
            child: Markdown(
              data: releaseNotes,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(fontSize: 24),
                h2: const TextStyle(fontSize: 20),
                h2Padding: const EdgeInsets.only(top: 16),
                h3: const TextStyle(fontSize: 14),
                p: const TextStyle(fontSize: 14),
                h3Padding: const EdgeInsets.only(top: 16),
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
          ),
        ],
      ),
    );
  }
}
