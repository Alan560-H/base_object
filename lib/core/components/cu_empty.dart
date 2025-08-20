import 'package:base_object/core/config/image_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CuEmpty extends StatelessWidget {
  const CuEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CachedNetworkImage(imageUrl: ImageConfig.empty),
    );
  }
}
