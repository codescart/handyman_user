import 'package:booking_system_flutter/component/base_scaffold_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/blog/blog_repository.dart';
import 'package:booking_system_flutter/screens/blog/component/blog_detail_header_component.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_detail_response.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../component/empty_error_state_widget.dart';
import '../../../utils/drop_cap.dart';
import '../shimmer/blog_detail_shimmer.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Future<BlogDetailResponse>? future;
  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);

    future = getBlogDetailAPI({BlogKey.blogId: widget.blogId.validate()});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SnapHelperWidget<BlogDetailResponse>(
        future: future,
        loadingWidget: BlogDetailShimmer(),
        onSuccess: (data) {
          return AnimatedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            padding: EdgeInsets.only(bottom: 120),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlogDetailHeaderComponent(blogData: data.blogDetail!),
              16.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.blogDetail!.title.validate(), style: boldTextStyle(size: 24)),
                  8.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (data.blogDetail!.createdAt.validate().isNotEmpty)
                        Row(
                          children: [
                            Text('${language.published}: ', style: secondaryTextStyle()),
                            Text(data.blogDetail!.createdAt.validate(), style: primaryTextStyle(size: 14), maxLines: 2, overflow: TextOverflow.ellipsis).expand(),
                          ],
                        ),
                      if (data.blogDetail!.totalViews != 0)
                        Row(
                          children: [
                            Icon(Icons.remove_red_eye, size: 24, color: context.iconColor),
                            8.width,
                            Text('${data.blogDetail!.totalViews.validate()} ', style: boldTextStyle()),
                            Text(language.views, style: boldTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                    ],
                  ),
                  16.height,
                  DropCapText(
                    data.blogDetail!.description.validate(),
                    style: primaryTextStyle(),
                  ),
                  24.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('${language.authorBy}: ', style: secondaryTextStyle()),
                      Text(data.blogDetail!.authorName.validate(), style: primaryTextStyle(size: 20), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ).center(),
                ],
              ).paddingSymmetric(horizontal: 16),
            ],
          );
        },
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: language.reload,
            onRetry: () {
              page = 1;
              appStore.setLoading(true);

              init();
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
