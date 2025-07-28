import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:chat_messenger/components/no_data.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

import 'components/story_card.dart';
import 'controller/story_controller.dart';

class StoriesScreen extends GetView<StoryController> {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withValues(alpha: 0.05), Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header moderno
              _buildModernHeader(context, isTablet),
              const SizedBox(height: 16),
              // Stories grid
              const Expanded(child: BuildStories()),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedFloatingButtons(isTablet: isTablet),
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono principal
          Container(
            width: isTablet ? 56 : 48,
            height: isTablet ? 56 : 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              IconlyBold.video,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          // Título y descripción
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stories'.tr,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 24 : 20,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Obx(() {
                  final totalStories = controller.stories.length;
                  return Text(
                    totalStories > 0
                        ? '$totalStories ${'active_stories'.tr}'
                        : 'no_active_stories'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 16 : 14,
                    ),
                  );
                }),
              ],
            ),
          ),
          // Estadísticas
          Obx(() {
            if (controller.stories.isNotEmpty) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 10 : 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.hasUnviewedStories
                          ? IconlyBold.show
                          : IconlyLight.show,
                      color: primaryColor,
                      size: isTablet ? 18 : 16,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Text(
                      controller.hasUnviewedStories ? 'new'.tr : 'viewed'.tr,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}

class AnimatedFloatingButtons extends GetView<StoryController> {
  const AnimatedFloatingButtons({super.key, required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final animationValue = value.clamp(0.0, 1.0).toDouble();
        final offsetY = (60 * (1 - animationValue)).clamp(0.0, 60.0).toDouble();
        final scale = (0.5 + 0.5 * animationValue).clamp(0.5, 1.0).toDouble();

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: animationValue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Upload text story button with enhanced styling
                  Tooltip(
                    message: 'create_text_story'.tr,
                    child: Container(
                      width: isTablet ? 58 : 48,
                      height: isTablet ? 58 : 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 14),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.9),
                            primaryColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.2),
                            blurRadius: 5,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 14,
                          ),
                          onTap: () => Get.toNamed(AppRoutes.writeStory),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 14 : 12),
                            child: Icon(
                              IconlyBold.editSquare,
                              size: isTablet ? 26 : 22,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 20 : 16),
                  // Upload file story button with enhanced styling
                  Tooltip(
                    message: 'create_media_story'.tr,
                    child: Container(
                      width: isTablet ? 64 : 56,
                      height: isTablet ? 64 : 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(-3, -3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 18,
                          ),
                          onTap: () => controller.uploadFileStory(),
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 16 : 14),
                            child: Icon(
                              IconlyBold.camera,
                              size: isTablet ? 30 : 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BuildStories extends GetView<StoryController> {
  const BuildStories({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine responsive grid parameters
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;
    EdgeInsets padding;

    if (screenWidth > 900) {
      // Large tablets/desktop
      crossAxisCount = 4;
      childAspectRatio = 0.7;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
      padding = const EdgeInsets.all(24);
    } else if (screenWidth > 600) {
      // Tablets
      crossAxisCount = 3;
      childAspectRatio = 0.72;
      crossAxisSpacing = 14;
      mainAxisSpacing = 14;
      padding = const EdgeInsets.all(20);
    } else if (screenWidth > 400) {
      // Large phones
      crossAxisCount = 2;
      childAspectRatio = 0.71;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
      padding = const EdgeInsets.all(defaultPadding);
    } else {
      // Small phones
      crossAxisCount = 2;
      childAspectRatio = 0.68;
      crossAxisSpacing = 10;
      mainAxisSpacing = 10;
      padding = const EdgeInsets.all(12);
    }

    return Obx(() {
      // Check loading status
      if (controller.isLoading.value) {
        return AnimatedLoadingGrid(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          padding: padding,
          childAspectRatio: childAspectRatio,
        );
      } else if (controller.stories.isEmpty) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: NoData(iconData: IconlyBold.video, text: 'no_stories'.tr),
        );
      }

      return AnimatedStoriesGrid(
        stories: controller.stories,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        padding: padding,
        childAspectRatio: childAspectRatio,
      );
    });
  }
}

class AnimatedStoriesGrid extends StatelessWidget {
  const AnimatedStoriesGrid({
    super.key,
    required this.stories,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.padding,
    required this.childAspectRatio,
  });

  final List stories;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: stories.length,
      physics: const BouncingScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(
            milliseconds: (600 + (index * 100)).clamp(100, 2000),
          ),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            final animationValue = value.clamp(0.0, 1.0).toDouble();
            return Transform.scale(
              scale: animationValue,
              child: Opacity(
                opacity: animationValue,
                child: StoryCard(stories[index]),
              ),
            );
          },
        );
      },
    );
  }
}

class AnimatedLoadingGrid extends StatelessWidget {
  const AnimatedLoadingGrid({
    super.key,
    required this.crossAxisCount,
    required this.crossAxisSpacing,
    required this.mainAxisSpacing,
    required this.padding,
    required this.childAspectRatio,
  });

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 6, // Show 6 skeleton items
      physics: const BouncingScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(
            milliseconds: (300 + (index * 100)).clamp(100, 1000),
          ),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            final animationValue = value.clamp(0.0, 1.0).toDouble();
            return Transform.scale(
              scale: animationValue,
              child: Opacity(
                opacity: animationValue,
                child: const ShimmerStoryCard(),
              ),
            );
          },
        );
      },
    );
  }
}

class ShimmerStoryCard extends StatefulWidget {
  const ShimmerStoryCard({super.key});

  @override
  State<ShimmerStoryCard> createState() => _ShimmerStoryCardState();
}

class _ShimmerStoryCardState extends State<ShimmerStoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        final animationValue = _shimmerAnimation.value
            .clamp(-2.0, 3.0)
            .toDouble();
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(defaultRadius),
            gradient: LinearGradient(
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + animationValue, 0.0),
              end: Alignment(-0.5 + animationValue, 0.0),
            ),
          ),
        );
      },
    );
  }
}
