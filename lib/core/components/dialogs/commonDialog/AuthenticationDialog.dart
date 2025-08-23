import 'package:base_object/core/components/cu_button.dart';
import 'package:base_object/core/components/custom_input_field.dart';
import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AuthenticationDialog extends StatefulWidget {
  /// 实名认证
  const AuthenticationDialog({super.key});


  @override
  State<AuthenticationDialog> createState() => _AuthenticationDialogState();
}

class _AuthenticationDialogState extends State<AuthenticationDialog> {
  /// 实名认证名字控制器
  final TextEditingController nameController = TextEditingController();
  /// 实名认证身份证控制器
  final TextEditingController idNoController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    idNoController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 10.h,
      children: [
        Row(
          spacing: 5.w,
          children: [
            Text("姓    名"),
            Expanded(child: CustomInputField(
              controller: nameController,
              bgColor: TextConfig.inputBgcolor,
              textSize: TextConfig.textSize_12,
              height: 40.h,
              hintText: '输入姓名',
              onChanged: (value) async {
                setState(() {
                });

              },
              validator: (value) {
                return null;
              },
            ),),

          ],
        ),
        Row(
          spacing: 5.w,
          children: [
            Text("身份证"),
            Expanded(child: CustomInputField(
              controller: idNoController,
              bgColor: TextConfig.inputBgcolor,
              textSize: TextConfig.textSize_12,
              height: 40.h,
              hintText: '输入身份证',
              onChanged: (value) async {
                setState(() {
                });

              },
              validator: (value) {
                return null;
              },
            ),),

          ],
        ),
        CuButton(text: "认证",width: 100.w,height: 40.h, onPressed: (){
        },bgImage: ImageConfig.inviteDefault,)
      ],
    );
  }
}
