import 'package:base_object/app/providers.dart';
import 'package:base_object/data/models/localModels/MenuModel.dart';
import 'package:base_object/shared/config/image_config.dart';
import 'package:base_object/shared/config/text_config.dart';
import 'package:base_object/shared/widgets/Avatar.dart';
import 'package:base_object/shared/widgets/cu_nav_bar/cu_nav_bar_controller.dart';
import 'package:base_object/shared/widgets/cu_nav_bar/cu_nav_bar_view.dart';
import 'package:base_object/shared/widgets/cu_toast.dart';
import 'package:base_object/services/device/oaid_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserPage extends ConsumerStatefulWidget {
  const UserPage({super.key});

  @override
  ConsumerState<UserPage> createState() => _UserPageState();
}

class _UserPageState extends ConsumerState<UserPage> {
  static final List<MenuModel> _menuList = [
    MenuModel(id: 8, menuName: '设备 OAID', icon: Icons.phone_android),
    MenuModel(id: 7, menuName: '清除缓存', icon: Icons.delete),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).getUserInfoFn();
    });
  }

  Widget _statColumn({String value = '', String title = ''}) {
    return Column(
      spacing: 10.h,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: TextConfig.textSize_20,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: TextConfig.textSize_14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.paddingOf(context).top;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final user = ref.watch(userProvider);
    final stats = ref.watch(adStatsProvider);

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          left: 10.w,
          right: 10.w,
          top: topPadding + 10.h,
        ),
        color: TextConfig.commonYellowPageColor,
        child: Column(
          spacing: 10.h,
          children: [
            Row(
              spacing: 20.w,
              children: [
                Avatar(
                  headImage: user.userModel.headImage,
                  size: 30.r,
                ),
                Column(
                  spacing: 10.h,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 10.w,
                      children: [
                        Text(
                          user.userModel.id > 0
                              ? user.userModel.username
                              : '游客',
                          style: TextStyle(
                            fontSize: TextConfig.textSize_20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF6600),
                                Color(0xFFFFC107),
                              ],
                              stops: [0.0, 1],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            user.userLevel,
                            style: TextStyle(
                              fontSize: TextConfig.textSize_14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      user.userModel.id > 0
                          ? '会员ID:${user.userModel.id}'
                          : '游客',
                      style: TextStyle(
                        fontSize: TextConfig.textSize_14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              width: screenWidth,
              constraints: BoxConstraints(
                minHeight: 100.h,
                maxHeight: 130.h,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 10.h,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.center,
                  fit: BoxFit.fill,
                  image: CachedNetworkImageProvider(
                    ImageConfig.userMenoyCardBg,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _statColumn(
                      value: '广告数：${stats.adInfos.length}',
                      title: '累计观看',
                    ),
                  ),
                  Expanded(
                    child: _statColumn(
                      value: stats.adInfosTotal.toString(),
                      title: '总收益(展示)',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _menuList.length,
                itemBuilder: (context, i) {
                  final menu = _menuList[i];
                  return Container(
                    key: menu.menuKey ?? GlobalKey(),
                    margin: EdgeInsets.only(top: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10.w,
                      ),
                      leading: Icon(menu.icon, color: TextConfig.black333),
                      title: Text(
                        menu.menuName,
                        style: TextStyle(
                          color: TextConfig.black333,
                          fontSize: TextConfig.textSize_16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Icon(
                        color: TextConfig.black333,
                        Icons.arrow_forward_ios,
                        size: TextConfig.textSize_14,
                      ),
                      onTap: () async {
                        if (menu.id == 8) {
                          await showOaidDialog();
                          return;
                        }
                        if (menu.id == 7) {
                          EasyLoading.show(status: '正在努力清除中...');
                          await Future.delayed(const Duration(seconds: 3));
                          CuToast.success(msg: '清除成功');
                          EasyLoading.dismiss();
                          CuNavBarController.to.onTabChange(0);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CuNavBarView(),
    );
  }
}
