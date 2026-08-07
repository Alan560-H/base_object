import 'package:base_object/shared/config/ace_ui_strings.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 无权限进入：不可关闭，仅「退出应用」。
Future<void> showAceAppBlockedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (BuildContext ctx) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 28.h),
                    child: Text(
                      AceUiStrings.blockedNetworkMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w500,
                        color: TextConfig.black333,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Color(0xFFE5E5E5),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: TextButton(
                      onPressed: () => SystemNavigator.pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: TextConfig.primary,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        AceUiStrings.blockedExit,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
