import 'dart:async';
import 'dart:io';

import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/svg_icon.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/helpers/dialog_helper.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/location.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/screens/messages/components/emoji_media.dart';
import 'package:chat_messenger/screens/messages/components/reply_message.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:chat_messenger/media/helpers/media_helper.dart';
import 'package:flutter/material.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import '../controllers/block_controller.dart';
import 'attachment/attachment_menu.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    this.user,
    this.group,
  });

  final User? user;
  final Group? group;

  @override
  ChatInputFieldState createState() => ChatInputFieldState();
}

class ChatInputFieldState extends State<ChatInputField> {
  // Get Controllers
  final MessageController controller = Get.find();
  final BlockController blockCrl = Get.find();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    final bool isIOS = Platform.isIOS;
    final String currentUserId = AuthController.instance.currentUser.userId;

    return Obx(
      () {
        String senderName = '';
        if (widget.group != null) {
          final Message? message = controller.replyMessage.value;
          if (message != null) {
            final member = widget.group!.getMemberProfile(message.senderId);
            senderName = member.fullname;
          }
        } else {
          senderName = widget.user!.fullname;
        }

        final bool isGroup = widget.group != null;
        final TextStyle style =
            Theme.of(context).textTheme.bodyLarge!.copyWith(color: errorColor);
        final Radius replyBorderRadius = controller.isReplying
            ? const Radius.circular(16)
            : const Radius.circular(30);

        // Check removed member status
        if (isGroup && widget.group!.isRemoved(currentUserId)) {
          return Container(
            padding: const EdgeInsets.all(defaultPadding / 2),
            child: Text('not_participant_message'.tr,
                textAlign: TextAlign.center, style: style),
          );
        }

        final bool isAdmin = widget.group?.isAdmin(currentUserId) ?? false;

        // Check Admin messages
        if (!isAdmin) {
          if (isGroup && !widget.group!.sendMessages) {
            return Container(
              padding: const EdgeInsets.all(defaultPadding / 2),
              child: Text('only_admins_can_send_messages'.tr,
                  textAlign: TextAlign.center, style: style),
            );
          }
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool value, _) {
            if (value) return;
            
            // Check emoji picker
            if (controller.showEmoji.value) {
              controller.showEmoji.value = false;
              return;
            }
            Get.back();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // <--- Chat Input --->
              Padding(
                padding: EdgeInsets.only(
                    left: 16, top: 8, right: 16, bottom: isIOS ? 32 : 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900]!.withOpacity(0.7) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: isDarkMode 
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Attachment button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {
                            _showAttachmentMenu();
                            controller.scrollToBottom();
                            controller.chatFocusNode.unfocus();
                            controller.showEmoji.value = false;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.add_circle_outline,
                              color: isDarkMode ? Colors.white70 : Colors.grey[700],
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                      // Text input field
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: TextFormField(
                            focusNode: controller.chatFocusNode,
                            controller: controller.textController,
                            minLines: 1,
                            maxLines: 4,
                            onTap: () => controller.showEmoji.value = false,
                            onChanged: (String text) {
                              controller.isTextMsg.value = text.trim().isNotEmpty;
                            },
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black87,
                              height: 1.3,
                            ),
                            decoration: InputDecoration(
                              hintText: 'message'.tr,
                              hintStyle: TextStyle(
                                color: isDarkMode 
                                  ? Colors.grey[400] 
                                  : Colors.grey[600],
                                fontSize: 16,
                              ),
                              filled: false,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Emoji button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () => controller.handleEmojiPicker(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: SvgIcon(
                                  controller.showEmoji.value
                                    ? 'assets/icons/keyboard.svg'
                                    : 'assets/icons/emoji_very_happy.svg',
                                  color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[700],
                                  width: 26,
                                  height: 26,
                                ),
                              ),
                            ),
                          ),
                          // GIF button
                          if (!controller.isTextMsg.value)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(25),
                                onTap: () async {
                                  final gif = await MediaHelper.getGif();
                                  if (gif == null) return;
                                  await controller.sendMessage(
                                    MessageType.gif,
                                    gifUrl: gif.images?.original?.url,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.gif_box,
                                    size: 26,
                                    color: isDarkMode
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          // Camera button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () async {
                                controller.scrollToBottom();
                                controller.chatFocusNode.unfocus();
                                controller.showEmoji.value = false;
                                await _handleCameraScreen();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  IconlyBold.camera,
                                  size: 26,
                                  color: isDarkMode
                                    ? Colors.white70
                                    : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          // Send button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(25),
                              onTap: () async {
                                final String text = controller.textController.text;
                                if (text.trim().isEmpty) return;
                                controller.sendMessage(MessageType.text, text: text);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
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
                                child: const SvgIcon(
                                  'assets/icons/send.svg',
                                  color: Colors.white,
                                  width: 26,
                                  height: 26,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Emoji picker
              Offstage(
                offstage: !controller.showEmoji.value,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: EmojiMedia(
                    textController: controller.textController,
                    onSelected: (category, emoji) {
                      controller.isTextMsg.value = true;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Handle Attachment Menu
  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AttachmentMenu(
        sendDocs: (List<File>? files) async {
          if (files == null) return;
          // Hold futures
          List<Future> futures = [];

          // Handle docs...
          for (File file in files) {
            // Get file path
            final String path = file.path;

            // Check comomn file types
            if (MediaHelper.isImage(path)) {
              // Send image file
              futures.add(
                controller.sendMessage(MessageType.image, file: file),
              );
            } else if (MediaHelper.isVideo(path)) {
              // Send video file
              futures.add(
                controller.sendMessage(MessageType.video, file: file),
              );
            } else {
              // Send this file as document
              futures.add(controller.sendMessage(MessageType.doc, file: file));
            }
          }

          // Send all the files once
          await Future.wait(futures);
        },
        sendImage: (File? file) {
          if (file == null) return;
          // Send image message
          controller.sendMessage(MessageType.image, file: file);
        },
        sendVideo: (File? file) {
          // Send video message
          controller.sendMessage(MessageType.video, file: file);
        },
        sendLocation: (Location? location) {
          // Send location message
          controller.sendMessage(MessageType.location, location: location);
        },
      ),
    );
  }

  Future<void> _handleCameraScreen() async {
    // Get image from camera
    final File? file = await MediaHelper.getImageFromCamera();
    if (file == null) return;

    // Send message
    if (isImage(file.path)) {
      controller.sendMessage(MessageType.image, file: file);
    } else {
      controller.sendMessage(MessageType.video, file: file);
    }
  }

  bool isImage(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType?.startsWith('image/') ?? false;
  }
}
