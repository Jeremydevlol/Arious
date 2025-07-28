import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/api/report_api.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/components/custom_appbar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/app_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/helpers/routes_helper.dart';
import 'package:chat_messenger/models/app_info.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';

import 'components/action_button.dart';
import 'controllers/profile_view_controller.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({
    super.key,
    required this.user,
    required this.isGroup,
  });

  final User user;
  final bool isGroup;

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (BuildContext context, _, __) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Hero(
              tag: 'profile-${user.userId}',
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(user.photoUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final controller = Get.put(ProfileViewController(user.userId));
    final ReportController reportController = Get.find();

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom Sliver App Bar with profile photo
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDarkMode 
                          ? [
                              primaryColor.withOpacity(0.8),
                              Colors.black,
                            ]
                          : [
                              primaryColor,
                              secondaryColor,
                            ],
                      ),
                    ),
                  ),
                  // Blur overlay
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ),
                  // Profile photo
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => user.photoUrl.isNotEmpty 
                        ? _showFullScreenImage(context)
                        : null,
                      child: Hero(
                        tag: 'profile-${user.userId}',
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: CachedCircleAvatar(
                            radius: 90,
                            iconSize: 80,
                            imageUrl: user.photoUrl,
                            borderColor: Colors.white,
                            borderWidth: 4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: defaultPadding),
                    // Profile name with online status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.fullname,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              FutureBuilder<User?>(
                                future: UserApi.getUser(user.userId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const SizedBox.shrink();
                                  final User? updatedUser = snapshot.data;
                                  if (updatedUser == null) return const SizedBox.shrink();
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: updatedUser.isOnline ? Colors.green : Colors.grey,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (updatedUser.isOnline ? Colors.green : Colors.grey).withOpacity(0.5),
                                          blurRadius: 6,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Username
                          Text(
                            '@${user.username}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: greyColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Last seen with animation
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                ? Colors.black.withOpacity(0.3) 
                                : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDarkMode 
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey[300]!,
                              ),
                            ),
                            child: FutureBuilder<User?>(
                              future: UserApi.getUser(user.userId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) return const SizedBox.shrink();
                                final User? updatedUser = snapshot.data;
                                if (updatedUser == null) return const SizedBox.shrink();
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    updatedUser.isOnline 
                                      ? 'online'.tr
                                      : "${updatedUser.lastActive?.getLastSeenTime}",
                                    key: ValueKey(updatedUser.isOnline),
                                    style: TextStyle(
                                      color: updatedUser.isOnline ? Colors.green : null,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: defaultPadding,
                        horizontal: defaultPadding,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: defaultPadding * 1.5,
                              vertical: defaultPadding * 0.7,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  IconlyBold.chat,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'message'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bio section
                    if (user.bio.isNotEmpty) ...[
                      const Divider(height: 32),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          color: isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDarkMode 
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey[300]!,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                ? Colors.black.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    IconlyBold.infoSquare,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'about'.tr,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              user.bio,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const Divider(height: 32),

                    // Security info
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[300]!,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(IconlyLight.lock, color: primaryColor),
                        ),
                        title: Text(
                          'encrypted_message'.tr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'end_to_end_encrypted'.tr,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: greyColor,
                          ),
                        ),
                      ),
                    ),

                    // Block and Report options
                    const SizedBox(height: defaultPadding),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDarkMode 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Obx(() {
                            final bool isBlocked = controller.isBlocked.value;
                            return ListTile(
                              onTap: () => controller.toggleBlockUser(),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: errorColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(IconlyLight.closeSquare, color: errorColor),
                              ),
                              title: Text(
                                "${isBlocked ? 'unblock'.tr : 'block'.tr} ${user.fullname}",
                                style: const TextStyle(
                                  color: errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                          const Divider(height: 1),
                          ListTile(
                            onTap: () => reportController.reportDialog(
                              type: ReportType.user,
                              userId: user.userId,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: errorColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(IconlyLight.infoSquare, color: errorColor),
                            ),
                            title: Text(
                              "${'report'.tr} ${user.fullname}",
                              style: const TextStyle(
                                color: errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding * 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
