import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frosty/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScaffold extends StatelessWidget {
  final String header;
  final String? subtitle;
  final String? disclaimer;
  final Widget? content;
  final String? buttonText;
  final Widget? buttonIcon;
  final Widget route;
  final Widget? skipRoute;
  final bool showLogo;
  final bool isLast;

  const OnboardingScaffold({
    Key? key,
    required this.header,
    this.subtitle,
    this.disclaimer,
    this.content,
    this.buttonText,
    this.buttonIcon,
    required this.route,
    this.skipRoute,
    this.showLogo = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (isLast) SharedPreferences.getInstance().then((prefs) => prefs.setBool('first_run', false));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showLogo) ...[
                          SvgPicture.asset(
                            'assets/icons/logo.svg',
                            height: 80,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          header,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 20),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          subtitle!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: content == null ? 20.0 : 0.0),
                  child: content ?? const SizedBox(),
                ),
              ),
              if (disclaimer != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
                  child: Opacity(
                    opacity: 0.5,
                    child: Text(
                      disclaimer!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                child: Button(
                  onPressed: () => isLast
                      ? Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => route),
                          (_) => false,
                        )
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => route,
                          ),
                        ),
                  icon: buttonIcon,
                  child: Text(buttonText ?? 'Next'),
                ),
              ),
              if (skipRoute != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  width: double.infinity,
                  child: Button(
                    color: Colors.grey,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => skipRoute!,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
