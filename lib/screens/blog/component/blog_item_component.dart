import 'package:booking_system_flutter/component/cached_image_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/blog/model/blog_response_model.dart';
import 'package:booking_system_flutter/screens/blog/view/blog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogItemComponent extends StatefulWidget {
  final BlogData? blogData;

  BlogItemComponent({this.blogData});

  @override
  State<BlogItemComponent> createState() => _BlogItemComponentState();
}

class _BlogItemComponentState extends State<BlogItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlogDetailScreen(blogId: widget.blogData!.id.validate()).launch(context);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(),
          backgroundColor: context.cardColor,
          border: appStore.isDarkMode ? Border.all(color: context.dividerColor) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedImageWidget(
              url: widget.blogData!.imageAttachments.validate().isNotEmpty ? widget.blogData!.imageAttachments!.first.validate() : '',
              fit: BoxFit.cover,
              height: 80,
              width: 80,
              radius: defaultRadius,
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.blogData!.title.validate(),
                  style: boldTextStyle(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.height,
                Text(widget.blogData!.description.validate(), style: secondaryTextStyle(size: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                4.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${language.authorBy}: ', style: secondaryTextStyle(weight: FontWeight.w600, size: 12)),
                    Text(widget.blogData!.authorName.validate(), style: primaryTextStyle(size: 12), maxLines: 1, overflow: TextOverflow.ellipsis).expand(),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
