import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frosty/screens/settings/stores/settings_store.dart';
import 'package:frosty/widgets/blurred_container.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.adaptive.arrow_back_rounded),
          onPressed: Navigator.of(context).pop,
        ),
        title: const Text('Release notes'),
      ),
      body: Stack(
        children: [
          // Main scrollable content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              child: Markdown(
                data: releaseNotes,
                styleSheet: MarkdownStyleSheet(
                  h2: const TextStyle(fontSize: 20),
                  h3: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
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
            ),
          ),
          // Blurred app bar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: BlurredContainer(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: MediaQuery.of(context).padding.left,
                right: MediaQuery.of(context).padding.right,
              ),
              child: const SizedBox(height: kToolbarHeight),
            ),
          ),
        ],
      ),
    );
  }
}
