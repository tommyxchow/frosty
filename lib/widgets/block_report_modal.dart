import 'package:flutter/widgets.dart';
import 'package:frosty/core/auth/auth_store.dart';
import 'package:frosty/widgets/block_button.dart';
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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            width: double.infinity,
            child: ReportButton(
              userLogin: userLogin,
              name: name,
            ),
          ),
        ],
      ),
    );
  }
}
