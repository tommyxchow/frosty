import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frosty/widgets/blurred_container.dart';

class SettingsTileRoute extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget child;
  final bool useScaffold;

  const SettingsTileRoute({
    super.key,
    required this.leading,
    required this.title,
    required this.child,
    this.useScaffold = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => useScaffold
              ? _BlurredSettingsPage(title: title, child: child)
              : child,
        ),
      ),
    );
  }
}

class _BlurredSettingsPage extends StatelessWidget {
  final String title;
  final Widget child;

  const _BlurredSettingsPage({
    required this.title,
    required this.child,
  });

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
        title: Text(title),
      ),
      body: Stack(
        children: [
          // Main scrollable content
          Positioned.fill(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: child,
            ),
          ),
          // Blurred app bar overlay - positioned AFTER content so it renders on top
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
