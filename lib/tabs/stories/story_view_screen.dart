import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/circle_button.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/tabs/stories/controller/story_view_controller.dart';
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';

class StoryViewScreen extends StatelessWidget {
  const StoryViewScreen({super.key, required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StoryViewController(story: story));
    final ReportController reportController = Get.find();
    final User user = story.user!;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    
    // Responsive sizing
    final topMargin = MediaQuery.of(context).padding.top + (isTablet ? 20 : 16);
    final avatarRadius = isLargeScreen ? 24.0 : (isTablet ? 22.0 : 18.0);
    final iconSize = isLargeScreen ? 28.0 : (isTablet ? 26.0 : 24.0);
    final chatIconSize = isLargeScreen ? 36.0 : (isTablet ? 34.0 : 30.0);
    final textFontSize = isLargeScreen ? 18.0 : (isTablet ? 16.0 : 14.0);
    final timeFontSize = isLargeScreen ? 14.0 : (isTablet ? 13.0 : 12.0);
    final horizontalPadding = isTablet ? 16.0 : 12.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom + (isTablet ? 24 : 16);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // <-- Story View -->
          StoryView(
            storyItems: controller.storyItems,
            controller: controller.storyController,
            onComplete: () => Get.back(),
            onStoryShow: (StoryItem item, index) {
              controller.getStoryItemIndex(index);
              controller.markSeen();
            },
          ),
          // Other info
          Container(
            margin: EdgeInsets.only(top: topMargin),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: GestureDetector(
              onTap: () {
                RoutesHelper.toProfileView(user, false).then(
                  (value) => Get.back(),
                );
              },
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      IconlyLight.arrowLeft2,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: isTablet ? 12 : 8),
                  // Profile avatar
                  CachedCircleAvatar(
                    radius: avatarRadius,
                    borderColor: primaryColor,
                    imageUrl: user.photoUrl,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  // Other info
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile name
                        Text(
                          user.fullname,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                            fontSize: textFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isTablet ? 6 : 4),
                        // Created at time
                        Obx(
                          () => Text(
                            controller.createdAt.formatDateTime,
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: timeFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Send message
                  if (!story.isOwner)
                    Padding(
                      padding: EdgeInsets.only(right: isTablet ? 12 : 8),
                      child: IconButton(
                        onPressed: () => RoutesHelper.toMessages(user: user),
                        icon: Icon(
                          IconlyLight.chat,
                          color: Colors.white,
                          size: chatIconSize,
                        ),
                      ),
                    ),
                  // <-- More options -->
                  PopupMenuButton(
                    color: Colors.white,
                    iconSize: iconSize,
                    onOpened: () => controller.storyController.pause(),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        onTap: () => reportController.reportDialog(
                          type: ReportType.story,
                          story: controller.reportStoryItemData,
                        ),
                        child: Text('report_this_story'.tr),
                      ),
                      if (story.isOwner)
                        PopupMenuItem(
                          onTap: () => _deleteStoryItem(controller),
                          child: Text('delete_this_story'.tr),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Show seen by modal
          if (story.isOwner)
            Obx(() {
              return Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: CircleButton(
                  color: Colors.transparent,
                  onPress: () {
                    // Pause story
                    controller.storyController.pause();

                    // Show bottom modal
                    DialogHelper.showStorySeenByModal(
                      seenByList: controller.seenByList,
                      onDelete: () {
                        // Close modal
                        Get.back();
                        // Delete story item
                        _deleteStoryItem(controller);
                      },
                    );
                  },
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconlyBold.show, 
                        color: Colors.white,
                        size: isTablet ? 20 : 18,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        '${controller.seenByList.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  void _deleteStoryItem(StoryViewController controller) {
    // Confirm delete story item
    DialogHelper.showAlertDialog(
      titleColor: errorColor,
      title: Text('delete_this_story'.tr),
      content: Text('this_action_cannot_be_reversed'.tr),
      actionText: 'DELETE'.tr.toUpperCase(),
      action: () {
        Get.back(); // Close confirm dialog
        Get.back(); // Close story view page
        controller.deleteStoryItem();
      },
    );
  }
}
