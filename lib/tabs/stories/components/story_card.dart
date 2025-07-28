import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/cached_card_image.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/helpers/date_helper.dart';
import 'package:chat_messenger/models/story/story.dart';
import 'package:chat_messenger/models/story/submodels/story_image.dart';
import 'package:chat_messenger/models/story/submodels/story_text.dart';
import 'package:chat_messenger/models/story/submodels/story_video.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:get/get.dart';

class StoryCard extends StatefulWidget {
  const StoryCard(this.story, {super.key});

  final Story story;

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutBack),
    );

    _elevationAnimation = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start pulse animation for unviewed stories
    final currentUser = AuthController.instance.currentUser;
    final isViewed = widget.story.viewers.contains(currentUser.userId);
    if (!isViewed && !widget.story.isOwner) {
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _tapController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _tapController.reverse();
  }

  void _onTapCancel() {
    _tapController.reverse();
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;

    // Responsive sizing
    final avatarRadius = isLargeScreen ? 32.0 : (isTablet ? 30.0 : 24.0);
    final cardPadding = isLargeScreen ? 12.0 : (isTablet ? 10.0 : 8.0);
    final textPadding = isLargeScreen ? 18.0 : (isTablet ? 16.0 : 14.0);
    final playIconSize = isLargeScreen ? 76.0 : (isTablet ? 70.0 : 56.0);
    final counterIconSize = isLargeScreen ? 20.0 : (isTablet ? 18.0 : 16.0);
    final borderRadius = isLargeScreen ? 24.0 : (isTablet ? 22.0 : 20.0);

    final currentUser = AuthController.instance.currentUser;
    final isViewed = widget.story.viewers.contains(currentUser.userId);
    final isOwner = widget.story.isOwner;

    Widget? storyContent;
    final int total =
        (widget.story.texts.length +
        widget.story.images.length +
        widget.story.videos.length);

    switch (widget.story.type) {
      case StoryType.text:
        final StoryText storyText = widget.story.texts.last;

        storyContent = AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          alignment: Alignment.center,
          padding: EdgeInsets.all(textPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                storyText.bgColor,
                storyText.bgColor.withValues(alpha: 0.85),
                storyText.bgColor.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: storyText.bgColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Shimmer effect for unviewed stories
              if (!isViewed && !isOwner)
                AnimatedBuilder(
                  animation: _shimmerAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(borderRadius),
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment(
                            -1.0 + _shimmerAnimation.value,
                            -1.0,
                          ),
                          end: Alignment(1.0 + _shimmerAnimation.value, 1.0),
                        ),
                      ),
                    );
                  },
                ),
              // Text content
              Center(
                child: Text(
                  storyText.text,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    fontSize: isLargeScreen ? 20 : (isTablet ? 18 : 16),
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                      ),
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
        break;

      case StoryType.image:
        final StoryImage storyImage = widget.story.images.last;
        storyContent = Hero(
          tag: 'story-image-${widget.story.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CachedCardImage(storyImage.imageUrl),
            ),
          ),
        );
        break;

      case StoryType.video:
        final StoryVideo storyVideo = widget.story.videos.last;
        storyContent = Hero(
          tag: 'story-video-${widget.story.id}',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  CachedCardImage(storyVideo.thumbnailUrl),
                  // Play button overlay
                  Center(
                    child: Container(
                      width: playIconSize,
                      height: playIconSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        IconlyBold.play,
                        color: Colors.white,
                        size: playIconSize * 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _elevationAnimation,
        _pulseAnimation,
        _shimmerAnimation,
      ]),
      builder: (context, child) {
        final scale = (_scaleAnimation.value * _pulseAnimation.value).clamp(
          0.8,
          1.2,
        );
        final elevation = _elevationAnimation.value.clamp(0.0, 25.0);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: () {
              Get.toNamed(
                AppRoutes.storyView,
                arguments: {'story': widget.story},
              );
            },
            child: MouseRegion(
              onEnter: (_) => _onHover(true),
              onExit: (_) => _onHover(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: !isViewed && !isOwner
                        ? primaryColor.withValues(alpha: 0.8)
                        : Colors.grey[300]!,
                    width: !isViewed && !isOwner ? 3.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? primaryColor.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                      blurRadius: elevation,
                      offset: Offset(0, elevation * 0.4),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 10,
                        offset: const Offset(-2, -2),
                      ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Stack(
                    children: [
                      // Main story content
                      Positioned.fill(
                        child: storyContent ?? const SizedBox.shrink(),
                      ),

                      // Gradient overlay for better text visibility
                      if (widget.story.type != StoryType.text)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(borderRadius),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ),

                      // User info overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(borderRadius),
                              bottomRight: Radius.circular(borderRadius),
                            ),
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          child: Row(
                            children: [
                              // User avatar with enhanced styling
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CachedCircleAvatar(
                                  radius: avatarRadius,
                                  imageUrl: widget.story.user!.photoUrl,
                                ),
                              ),
                              SizedBox(width: cardPadding),

                              // User name and time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.story.user!.fullname,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: isLargeScreen
                                                ? 16
                                                : (isTablet ? 15 : 14),
                                            fontWeight: FontWeight.w700,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.7,
                                                ),
                                                offset: const Offset(1, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: isTablet ? 4 : 2),
                                    Text(
                                      widget.story.updatedAt!.formatDateTime,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.white70,
                                            fontSize: isLargeScreen
                                                ? 13
                                                : (isTablet ? 12 : 11),
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.7,
                                                ),
                                                offset: const Offset(1, 1),
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // Story counter and status
                              if (total > 1 || isOwner) ...[
                                SizedBox(width: cardPadding),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 10 : 8,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isOwner
                                        ? primaryColor.withValues(alpha: 0.9)
                                        : Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(
                                      isTablet ? 12 : 10,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isOwner
                                            ? IconlyBold.show
                                            : IconlyBold.heart,
                                        color: isOwner
                                            ? Colors.white
                                            : primaryColor,
                                        size: counterIconSize,
                                      ),
                                      SizedBox(width: isTablet ? 6 : 4),
                                      Text(
                                        total > 1
                                            ? total.toString()
                                            : (isOwner ? 'You' : ''),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: isOwner
                                                  ? Colors.white
                                                  : primaryColor,
                                              fontSize: isLargeScreen
                                                  ? 13
                                                  : (isTablet ? 12 : 11),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // New story indicator
                      if (!isViewed && !isOwner)
                        Positioned(
                          top: cardPadding,
                          right: cardPadding,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 10 : 8,
                              vertical: isTablet ? 6 : 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 10,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              'new'.tr.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.white,
                                    fontSize: isLargeScreen
                                        ? 11
                                        : (isTablet ? 10 : 9),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBottomBackground extends StatelessWidget {
  const AnimatedBottomBackground({super.key, required this.isHovered});

  final bool isHovered;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            isHovered
                ? Colors.black.withOpacity(.9)
                : Colors.black.withOpacity(.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class BottomBackground extends StatelessWidget {
  const BottomBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(defaultRadius),
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
