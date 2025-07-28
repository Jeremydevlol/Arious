import 'package:flutter/material.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/models/group.dart';
import 'package:chat_messenger/models/message.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/plugins/swipeto/swipe_to.dart';
import 'package:chat_messenger/screens/messages/components/bubbles/location_message.dart';
import 'package:chat_messenger/screens/messages/components/reply_message.dart';
import 'package:chat_messenger/screens/messages/components/reaction_panel.dart';
import 'package:chat_messenger/screens/messages/components/message_reactions.dart';
import 'package:chat_messenger/screens/messages/controllers/message_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:get/get.dart';

import 'bubbles/audio_message.dart';
import 'bubbles/document_message.dart';
import 'bubbles/gif_message.dart';
import 'bubbles/image_message.dart';
import 'bubbles/text_message.dart';
import 'bubbles/video_message.dart';
import 'forwarded_badge.dart';
import 'read_time_status.dart';

class EnhancedBubbleMessage extends StatefulWidget {
  const EnhancedBubbleMessage({
    super.key,
    required this.message,
    required this.onTapProfile,
    required this.onReplyMessage,
    required this.user,
    required this.group,
    required this.onReactionTap,
  });

  final Message message;
  final User? user;
  final Group? group;
  final Function()? onTapProfile;
  final Function()? onReplyMessage;
  final Function(String emoji) onReactionTap;

  @override
  State<EnhancedBubbleMessage> createState() => _EnhancedBubbleMessageState();
}

class _EnhancedBubbleMessageState extends State<EnhancedBubbleMessage>
    with TickerProviderStateMixin {
  late AnimationController _bubbleAnimationController;
  late AnimationController _reactionAnimationController;
  late Animation<double> _bubbleSlideAnimation;
  late Animation<double> _bubbleOpacityAnimation;
  late Animation<Offset> _reactionSlideAnimation;
  
  bool _showReactionPanel = false;
  OverlayEntry? _reactionOverlay;

  @override
  void initState() {
    super.initState();
    
    _bubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _reactionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _bubbleSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleAnimationController,
      curve: Curves.easeOut,
    ));
    
    _bubbleOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleAnimationController,
      curve: Curves.easeOut,
    ));
    
    _reactionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _reactionAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Start animation
    _bubbleAnimationController.forward();
  }

  @override
  void dispose() {
    _bubbleAnimationController.dispose();
    _reactionAnimationController.dispose();
    _hideReactionPanel();
    super.dispose();
  }

  void _showReactionPanelOverlay() {
    if (_reactionOverlay != null) return;
    
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    _reactionOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: widget.message.isSender ? null : position.dx,
        right: widget.message.isSender ? MediaQuery.of(context).size.width - position.dx - size.width : null,
        top: position.dy - 60,
        child: SlideTransition(
          position: _reactionSlideAnimation,
          child: ReactionPanel(
            message: widget.message,
            onReactionTap: (emoji) {
              widget.onReactionTap(emoji);
              _hideReactionPanel();
            },
            onReactionLongPress: () {
              // Show more emoji options
              _hideReactionPanel();
            },
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_reactionOverlay!);
    _reactionAnimationController.forward();
    setState(() => _showReactionPanel = true);
  }
  
  void _hideReactionPanel() {
    if (_reactionOverlay != null) {
      _reactionAnimationController.reverse().then((_) {
        _reactionOverlay?.remove();
        _reactionOverlay = null;
      });
      setState(() => _showReactionPanel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.of(context).isDarkMode;
    final bool isGroup = widget.group != null;

    final User senderUser = isGroup 
        ? widget.group!.getMemberProfile(widget.message.senderId) 
        : widget.user!;

    final String profileUrl = widget.message.isSender
        ? AuthController.instance.currentUser.photoUrl
        : senderUser.photoUrl;

    final bool isSender = widget.message.isSender;
    final Color backgroundColor = isSender
        ? primaryColor
        : isDarkMode
            ? greyColor.withOpacity(0.5)
            : greyLight;
    final Color senderColor = isDarkMode
        ? Colors.white
        : ColorGenerator.getColorForSender(widget.message.senderId);

    return AnimatedBuilder(
      animation: _bubbleAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _bubbleSlideAnimation.value)),
          child: Opacity(
            opacity: _bubbleOpacityAnimation.value,
            child: SwipeTo(
              iconColor: primaryColor,
              onRightSwipe: widget.onReplyMessage,
              child: GestureDetector(
                onTap: _showReactionPanel ? _hideReactionPanel : null,
                onLongPress: widget.message.type == MessageType.groupUpdate 
                    ? null 
                    : _showReactionPanelOverlay,
                child: Column(
                  crossAxisAlignment: isSender 
                      ? CrossAxisAlignment.end 
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          top: defaultPadding,
                          left: isSender ? 50 : 0,
                          right: isSender ? 0 : 50,
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(!isSender ? 4 : 18),
                            topRight: const Radius.circular(18),
                            bottomLeft: const Radius.circular(18),
                            bottomRight: Radius.circular(!isSender ? 18 : 4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Forwarded badge
                                if (widget.message.isForwarded && !widget.message.isDeleted)
                                  ForwardedBadge(isSender: isSender),
                                
                                // Show sender name
                                if (isGroup && !isSender && !widget.message.isDeleted)
                                  GestureDetector(
                                    onTap: widget.onTapProfile,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        isSender ? 'you'.tr : "~ ${senderUser.fullname}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: senderColor,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                
                                // Reply message
                                if (widget.message.replyMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: ReplyMessage(
                                      message: widget.message.replyMessage!,
                                      senderName: isGroup
                                          ? widget.group!
                                              .getMemberProfile(widget.message.replyMessage!.senderId)
                                              .fullname
                                          : widget.user!.fullname,
                                      bgColor: widget.message.isSender
                                          ? isDarkMode
                                              ? Colors.black.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.3)
                                          : null,
                                      lineColor: widget.message.isSender ? Colors.white : primaryColor,
                                    ),
                                  ),
                                
                                // Main message content
                                _showMessageContent(profileUrl),
                              ],
                            ),
                            
                            // Show sent time
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: ReadTimeStatus(
                                message: widget.message, 
                                isGroup: isGroup,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Message reactions
                    MessageReactions(
                      message: widget.message,
                      onReactionTap: widget.onReactionTap,
                      isSender: isSender,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _showMessageContent(String profileUrl) {
    switch (widget.message.type) {
      case MessageType.text:
        return TextMessage(widget.message);
      case MessageType.image:
        return ImageMessage(widget.message);
      case MessageType.gif:
        return GifMessage(widget.message);
      case MessageType.audio:
        return AudioMessage(widget.message, profileUrl: profileUrl);
      case MessageType.video:
        return VideoMessage(widget.message);
      case MessageType.doc:
        return DocumentMessage(message: widget.message);
      case MessageType.location:
        return LocationMessage(widget.message);
      default:
        return const SizedBox.shrink();
    }
  }
}

// Color generator for sender names
class ColorGenerator {
  static final List<Color> _colors = [
    const Color(0xFF1F8B4C),
    const Color(0xFF206694),
    const Color(0xFF71368A),
    const Color(0xFFAD1457),
    const Color(0xFFC53030),
    const Color(0xFFD97706),
    const Color(0xFF9D4EDD),
    const Color(0xFF2B6CB0),
  ];

  static Color getColorForSender(String senderId) {
    final hash = senderId.hashCode;
    return _colors[hash.abs() % _colors.length];
  }
} 