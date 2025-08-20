import 'package:base_object/core/config/image_config.dart';
import 'package:base_object/core/config/text_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 只有头像
class Avatar extends StatelessWidget {
  final String headImage;
  final double size;

  const Avatar({super.key, required this.headImage, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return // 头像组件
    CircleAvatar(
      radius: size.h,
      // backgroundColor: Colors.grey.withValues(alpha: .5),
      // backgroundImage:
      //     headImage.isEmpty
      //         ? CachedNetworkImageProvider(ImageConfig.defaultUser)
      //         : CachedNetworkImageProvider(
      //           headImage,
      //           errorListener: (e) {
      //             Utils.logError("图片错误$e");
      //           },
      //         ),
      child: LimitedBox(
        maxHeight: size.h,
        maxWidth: size.w,
        child: Container(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          // 启用裁剪并应用抗锯齿
          constraints: BoxConstraints(
            maxHeight: size.h * 2,
            maxWidth: size.w * 2,
          ),
          decoration: BoxDecoration(
            color: TextConfig.grey,
            borderRadius: BorderRadius.circular(size.h),
          ),
          child: CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: headImage,
            errorWidget:
                (context, url, error) =>
                    CircleAvatar(radius: 25.r, child: Icon(Icons.person)),
          ),
        ),
      ),
    );
  }
}
