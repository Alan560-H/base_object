// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'circular_progress_controller.dart';
//
// class CuCircularProgressView extends StatelessWidget {
//   final CuCircularProgressView controller;
//   final String imagePath;
//   final double size;
//   final double strokeWidth;
//   final Color progressColor;
//   final Color backgroundColor;
//
//   const SimpleCircularProgressWidget({
//     super.key,
//     required this.controller,
//     required this.imagePath,
//     this.size = 200.0,
//     this.strokeWidth = 8.0,
//     this.progressColor = Colors.blue,
//     this.backgroundColor = Colors.grey[200]!,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//           () => Stack(
//         alignment: Alignment.center,
//         children: [
//           // 使用系统圆形进度条
//           SizedBox(
//             width: size,
//             height: size,
//             child: CircularProgressIndicator(
//               value: controller.progressPercentage,
//               strokeWidth: strokeWidth,
//               valueColor: AlwaysTween<Color?>(value: progressColor).animate(
//                 const AlwaysStoppedAnimation(0),
//               ),
//               backgroundColor: backgroundColor,
//             ),
//           ),
//
//           // 中间的图片
//           ClipOval(
//             child: Image.asset(
//               imagePath,
//               width: size - strokeWidth * 2 - 20,
//               height: size - strokeWidth * 2 - 20,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[300],
//                   child: const Icon(Icons.error, color: Colors.red),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
