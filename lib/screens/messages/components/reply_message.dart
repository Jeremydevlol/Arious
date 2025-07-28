import 'package:flutter/material.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/message_badge.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:get/get.dart';

class ReplyMessage extends StatelessWidget {
  const ReplyMessage({
    super.key,
    required this.message,
    required this.senderName,
    this.bgColor,
    this.lineColor,
    this.senderColor,
    this.cancelReply,
  });

  final Message message;
  final String senderName;
  final Color? bgColor, lineColor, senderColor;
  final Function()? cancelReply;

  @override
  Widget build(BuildContext context) {
    // For: image, gif video preview box
    bool isMediaMsg() {
      return message.type == MessageType.image ||
          message.type == MessageType.gif ||
          message.type == MessageType.video;
    }

    return Stack(
      children: [
        // Reply container
        Container(
          width: double.maxFinite,
          margin: const EdgeInsets.symmetric(
            horizontal: defaultPadding / 2,
            vertical: defaultPadding / 4,
          ),
          decoration: BoxDecoration(
            color: bgColor ?? Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (lineColor ?? primaryColor).withOpacity(0.15),
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                ReplySeparator(
                  color: lineColor ?? primaryColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sender name
                        Text(
                          message.isSender ? 'you'.tr : senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: senderColor ?? primaryColor,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Message badge
                        MessageBadge(
                          maxLines: 2,
                          type: message.type,
                          textMsg: message.textMsg,
                          textStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Show preview media message
                if (isMediaMsg()) 
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MediaPreview(message),
                  ),
              ],
            ),
          ),
        ),
        // Cancel reply button
        if (cancelReply != null)
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: cancelReply,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MediaPreview extends StatelessWidget {
  const MediaPreview(
    this.message, {
    super.key,
  });

  final Message message;

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    switch (message.type) {
      case MessageType.image:
      case MessageType.gif:
        imageUrl = message.fileUrl;
        break;
      case MessageType.video:
        imageUrl = message.videoThumbnail;
        break;
      default:
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(defaultRadius / 2),
      child: SizedBox(
        width: 75,
        height: 75,
        child: CachedCardImage(imageUrl),
      ),
    );
  }
}

class ReplySeparator extends StatelessWidget {
  const ReplySeparator({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 80,
      decoration: BoxDecoration(
        color: color ?? primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
    );
  }
}
