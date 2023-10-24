import 'package:booking_system_flutter/component/last_messege_chat.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/chat/user_chat_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class UserItemWidget extends StatefulWidget {
  final String userUid;

  UserItemWidget({required this.userUid});

  @override
  State<UserItemWidget> createState() => _UserItemWidgetState();
}

class _UserItemWidgetState extends State<UserItemWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: userService.singleUser(widget.userUid),
      builder: (context, snap) {
        if (snap.hasData) {
          UserData data = snap.data!;

          return InkWell(
            onTap: () async {
              UserChatScreen(receiverUser: data).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 300.milliseconds);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    padding: EdgeInsets.all(10),
                    color: context.primaryColor.withOpacity(0.2),
                    child: Text(data.displayName.validate()[0].validate().toUpperCase(), style: boldTextStyle(color: context.primaryColor)).center().fit(),
                  ).cornerRadiusWithClipRRect(50),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.firstName.validate(),
                            style: boldTextStyle(size: 16),
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                          ).expand(),
                          StreamBuilder<int>(
                            stream: chatServices.getUnReadCount(senderId: appStore.uid.validate(), receiverId: data.uid.validate()),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                if (snap.data != 0) {
                                  return Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor),
                                    child: Text(
                                      snap.data.validate().toString(),
                                      style: secondaryTextStyle(size: 12, color: white),
                                    ).fit().center(),
                                  );
                                }
                              }
                              return SizedBox(height: 18, width: 18);
                            },
                          ),
                        ],
                      ),
                      4.height,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LastMessageChat(
                            stream: chatServices.fetchLastMessageBetween(senderId: appStore.uid.validate(), receiverId: widget.userUid),
                          ),
                        ],
                      ),
                    ],
                  ).expand(),
                ],
              ),
            ),
          );
        }
        return snapWidgetHelper(snap, errorWidget: Offstage(), loadingWidget: Offstage());
      },
    );
  }
}
