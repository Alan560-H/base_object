import 'package:base_object/core/components/cu_app_bar.dart';
import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/cu_empty.dart';
import 'package:base_object/core/components/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/core/components/dialogs/Dialogs.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:base_object/models/backModel/TaskModel/TaskModel.dart';
import 'package:base_object/utils/Utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'task_controller.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  /// 任务列表小部件
  /// 任务列表小部件
  Widget get taskListView => ListView.builder(
    padding: EdgeInsets.zero,
    itemCount: controller.taskList.length,
    itemBuilder: (context, index) {
      TaskModel task = controller.taskList[index];
      switch (task.taskType) {
        /// 签到
        case 1:
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: ImageConfig.checkInIcon,
              height: 20.h,
              width: 20.w,
            ),
            title: Text(task.taskName),
            subtitle: Text(task.taskDesc),
            trailing: CuButton(
              fontSize: TextConfig.textSize_12,
              bgColor: TextConfig.primary,
              radius: 10.r,
              text: "签到",
              onPressed: () {
                Dialogs.showCommonDialog(
                  dialogType: "CheckInDialog",
                  dialogTitle: "签到",
                );
              },
            ),
          );
        case 2:
          return ListTile(
            leading: CachedNetworkImage(
              imageUrl: ImageConfig.videoAd,
              height: 20.h,
              width: 20.w,
            ),
            title: Text(task.taskName),
            subtitle: Text(task.taskDesc),
            trailing: CuButton(
              fontSize: TextConfig.textSize_12,
              bgColor: TextConfig.primary,
              radius: 10.r,
              width: 100.w,
              text: "领取${task.taskProgress}/${task.taskTotal}",
              onPressed: () {
                Utils.logError("低保按钮点击事件");
              },
            ),
          );
      }
      return null;
    },
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Column(
          children: [
            CuAppBar(
              title: controller.appbarTitle.value,
              showBackArrow: false,
              backgroundColor: Colors.red[300],
              textColor: Colors.white,
            ),
            Expanded(
              child: controller.taskList.isEmpty ? CuEmpty() : taskListView,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CuNavBarView(),
    );
  }
}
