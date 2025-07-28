import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat_messenger/api/user_api.dart';
import 'package:chat_messenger/components/badge_indicator.dart';
import 'package:chat_messenger/controllers/preferences_controller.dart';
import 'package:chat_messenger/controllers/report_controller.dart';
import 'package:chat_messenger/tabs/stories/controller/story_controller.dart';
import 'package:chat_messenger/theme/app_theme.dart';
import 'package:chat_messenger/controllers/auth_controller.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/helpers/ads/ads_helper.dart';
import 'package:chat_messenger/helpers/ads/banner_ad_helper.dart';
import 'package:chat_messenger/models/user.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/components/cached_circle_avatar.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/services/firebase_messaging_service.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/widgets/wallet_status_indicator.dart';

import 'components/search_chat_input.dart';
import 'controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Init other controllers
    Get.put(ReportController(), permanent: true);
    Get.put(PreferencesController(), permanent: true);

    // Load Ads
    AdsHelper.loadAds(interstitial: false);

    // Listen to incoming firebase push notifications
    FirebaseMessagingService.initFirebaseMessagingUpdates();

    // Update user presence
    UserApi.updateUserPresenceInRealtimeDb();

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // <-- Handle the user presence -->
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only update presence if state changes to resumed or inactive/paused
    if (state == AppLifecycleState.resumed) {
      UserApi.updateUserPresence(true);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      UserApi.updateUserPresence(false);
    }
  }
  // END

  @override
  Widget build(BuildContext context) {
    // Get Controllers
    final HomeController homeController = Get.find();
    final ChatController chatController = Get.find();
    final StoryController storyController = Get.find();

    // Others
    final bool isDarkMode = AppTheme.of(context).isDarkMode;

    return Obx(() {
      // Get page index
      final int pageIndex = homeController.pageIndex.value;
      // Get current user
      final User currentUer = AuthController.instance.currentUser;

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: pageIndex == 0 ? 95 : 80,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                const Color(0xFF1A1A2E).withOpacity(0.95),
                                const Color(0xFF16213E).withOpacity(0.95),
                                const Color(0xFF0F0F23).withOpacity(0.95),
                              ]
                            : [
                                const Color(
                                  0xFF00BFFF,
                                ).withOpacity(0.95), // Sky Blue
                                const Color(
                                  0xFF40E0D0,
                                ).withOpacity(0.95), // Turquoise
                                const Color(
                                  0xFF87CEEB,
                                ).withOpacity(0.95), // Light Sky Blue
                              ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App name with blue color (company's primary color)
                Text(
                  AppConfig.appName,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: isDarkMode
                        ? primaryColor
                        : Colors
                              .white, // White in light mode, blue in dark mode
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Wallet Status Indicator
            const WalletStatusIndicator(),

            // Woop Wallet Button
            if (pageIndex == 0)
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(
                        AppRoutes.ethDashboard,
                      ); // Navigate to ETH dashboard
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C2FF), Color(0xFF0047FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00C2FF).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: const Color(0xFF0047FF).withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -2,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'WOOP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Go to session page (with improved design)
            if (pageIndex == 2)
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(AppRoutes.session);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        IconlyLight.logout,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color(0xFF0F0F23),
                      const Color(0xFF1A1A2E),
                      darkThemeBgColor,
                    ]
                  : [
                      const Color(0xFFE6F7FF), // Very light sky blue
                      const Color(0xFFB3E5FC), // Light blue
                      lightThemeBgColor,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                // Search Chats with improved design
                if (pageIndex == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildModernSearchInput(isDarkMode),
                  ),
                // Show Banner Ad
                if (pageIndex != 0)
                  BannerAdHelper.showBannerAd(margin: pageIndex == 1 ? 8 : 0),
                // Show the body content
                Expanded(child: homeController.pages[pageIndex]),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [darkThemeBgColor.withOpacity(0.95), darkThemeBgColor]
                  : [lightThemeBgColor.withOpacity(0.95), lightThemeBgColor],
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: pageIndex,
            onTap: (int index) {
              HapticFeedback.selectionClick();
              homeController.pageIndex.value = index;
              // View stories
              if (index == 1) {
                storyController.viewStories();
              }
            },
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            items: [
              // Chats
              BottomNavigationBarItem(
                label: 'chats'.tr,
                icon: BadgeIndicator(
                  icon: pageIndex == 0 ? IconlyBold.chat : IconlyLight.chat,
                  isNew: chatController.newMessage,
                ),
              ),
              // Stories
              BottomNavigationBarItem(
                label: 'stories'.tr,
                icon: BadgeIndicator(
                  icon: IconlyBold.play,
                  isNew: storyController.hasUnviewedStories,
                  iconSize: 45,
                  iconColor: primaryColor,
                ),
              ),
              // Profile account
              BottomNavigationBarItem(
                label: 'profile'.tr,
                icon: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: pageIndex == 2
                          ? primaryColor
                          : primaryColor.withOpacity(0.3),
                      width: pageIndex == 2 ? 2.5 : 1.5,
                    ),
                  ),
                  child: CachedCircleAvatar(
                    imageUrl: currentUer.photoUrl,
                    iconSize: currentUer.photoUrl.isEmpty ? 18 : null,
                    radius: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr;
    } else if (hour < 17) {
      return 'good_afternoon'.tr;
    } else {
      return 'good_evening'.tr;
    }
  }

  Widget _buildModernSearchInput(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  Colors.grey[800]!.withOpacity(0.3),
                  Colors.grey[900]!.withOpacity(0.5),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.grey[50]!.withOpacity(0.8),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.7),
          width: 1,
        ),
      ),
      child: const SearchChatInput(),
    );
  }
}
