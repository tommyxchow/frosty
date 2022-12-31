import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frosty/screens/settings/stores/auth_store.dart';
import 'package:frosty/widgets/block_button.dart';
import 'package:frosty/widgets/bottom_sheet.dart';
import 'package:frosty/widgets/report_button.dart';

class BlockReportModal extends StatelessWidget {
  final AuthStore authStore;
  final String name;
  final String userLogin;
  final String userId;

  const BlockReportModal({
    Key? key,
    required this.authStore,
    required this.name,
    required this.userLogin,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrostyBottomSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (authStore.isLoggedIn)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              width: double.infinity,
              child: BlockButton(
                authStore: authStore,
                targetUser: name,
                targetUserId: userId,
                simple: false,
              ),
            ),
          const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            width: double.infinity,
            child: ReportButton(
              userLogin: userLogin,
              displayName: name,
            ),
          ),
          if (Platform.isAndroid) const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
