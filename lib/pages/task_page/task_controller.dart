import 'package:base_object/core/api/api.dart';
import 'package:base_object/models/FormModel/FormModel.dart';
import 'package:base_object/models/backModel/TaskModel/TaskModel.dart';
import 'package:base_object/store/store.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  RxString appbarTitle = "任务大厅".obs;

  /// 任务列表
  RxList<TaskModel> taskList = <TaskModel>[].obs;

  /// 获取任务列表
  Future<void> getTaskList() async {
    EasyLoading.show(status: "加载中......");
    // FormModel formModel = FormModel();
    // formModel.channelPackage = Store.instance.getAppUpLoadModel.channelPackage;
    // taskList.value = await Api.to.postTask(formModel);
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));
    EasyLoading.dismiss();
    // 假设从服务器获取到了任务列表
    taskList.value = TaskModel.fromJsonList([
      {
        "taskId": 1,
        "taskStatus": 0,
        "taskName": "签到任务",
        "taskDesc": "签到任务描述",
        "taskType": 1,
        "taskProgress": 0,
        "taskTotal": 100,
      },
      {
        "taskId": 2,
        "taskStatus": 1,
        "taskName": "低保任务",
        "taskDesc": "低保任务描述",
        "taskType": 2,
        "taskProgress": 2,
        "taskTotal": 6,
      },
    ]);
  }

  @override
  void onInit() {
    getTaskList();
    // TODO: implement onInit
    super.onInit();
  }
}
