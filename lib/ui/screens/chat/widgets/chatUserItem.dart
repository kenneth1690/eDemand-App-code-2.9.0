import 'package:e_demand/app/generalImports.dart';
import 'package:flutter/material.dart';

class ChatUserItemWidget extends StatelessWidget {
  final ChatUser chatUser;
  final bool showCount;

  const ChatUserItemWidget({super.key, required this.chatUser, this.showCount = true});

  final double _chatUserContainerHeight = 80;

  Widget _profileImageBuilder({required String imageUrl, required BuildContext context}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf50),
      child: CustomContainer(
        clipBehavior: Clip.antiAlias,
        borderRadius: UiUtils.borderRadiusOf50,
        height: 60,
        width: 60,
        child: imageUrl.trim().isEmpty || imageUrl.toLowerCase() == "null"
            ? const CustomSvgPicture(svgImage: AppAssets.drProfile, width: 60, height: 60)
            : CustomCachedNetworkImage(
                networkImageUrl: imageUrl,
                fit: BoxFit.contain,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, chatMessages, arguments: {
            "chatUser": chatUser,
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: CustomContainer(
          height: _chatUserContainerHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          borderRadius: UiUtils.borderRadiusOf10,
          color: context.colorScheme.secondaryColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _profileImageBuilder(
                imageUrl: chatUser.avatar,
                context: context,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomText(
                      chatUser.userName,
                      maxLines: 1,
                      color: Theme.of(context).secondaryHeaderColor,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    if (chatUser.bookingId == "0") ...[
                      CustomText("preBookingEnquiries".translate(context: context),
                          color: context.colorScheme.lightGreyColor, height: 1, fontSize: 12.0),
                    ] else ...[
                      CustomText(
                          "${"bookingId".translate(context: context)} - ${chatUser.bookingId}",
                          color: context.colorScheme.lightGreyColor,
                          height: 1,
                          fontSize: 12.0),
                      const SizedBox(
                        height: 5,
                      ),
                      CustomText(
                          "${"bookingStatus".translate(context: context)} - ${chatUser.bookingStatus}",
                          color: context.colorScheme.lightGreyColor,
                          height: 1,
                          fontSize: 12.0),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
