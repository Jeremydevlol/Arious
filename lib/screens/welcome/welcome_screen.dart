import 'package:flutter/material.dart';
import 'package:chat_messenger/config/app_config.dart';
import 'package:chat_messenger/config/theme_config.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'package:get/get.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // Responsive icon size based on screen size
    final iconSize = screenWidth < 400 
        ? screenWidth * 0.6  // Small phones
        : screenWidth < 600 
            ? screenWidth * 0.5  // Medium phones
            : screenWidth * 0.4; // Large phones/tablets
    
    // Responsive font sizes
    final titleFontSize = screenWidth < 400 ? 24.0 : 28.0;
    final descriptionFontSize = screenWidth < 400 ? 16.0 : 18.0;
    final buttonFontSize = screenWidth < 400 ? 16.0 : 18.0;
    
    // Responsive spacing
    final verticalSpacing = screenHeight * 0.03;
    final buttonHeight = screenWidth < 400 ? 45.0 : 50.0;
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    children: [
                      // Flexible spacer that adapts to screen height
                      SizedBox(height: screenHeight * 0.1),
                      
                      // App Icon with responsive sizing
                      Container(
                        height: iconSize,
                        width: iconSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(iconSize / 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: screenWidth * 0.05,
                              offset: Offset(0, screenHeight * 0.01),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(iconSize / 2),
                          child: Image.asset(
                            "assets/images/app_icon_welcome.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: verticalSpacing * 1.5),
                      
                      // App name with responsive font size
                      Text(
                        AppConfig.appName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontSize: titleFontSize,
                            ),
                      ),
                      
                      SizedBox(height: verticalSpacing),
                      
                      // Description with responsive padding and font size
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                        ),
                        child: Text(
                          "app_short_description".tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                color: greyColor, 
                                fontSize: descriptionFontSize,
                                height: 1.4,
                              ),
                        ),
                      ),
                      
                      SizedBox(height: verticalSpacing * 2),
                      
                      // Responsive button
                      Container(
                        width: screenWidth * 0.8,
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: () =>
                              Future(() => Get.offAllNamed(AppRoutes.signInOrSignUp)),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(buttonHeight / 2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "get_started".tr,
                                style: TextStyle(
                                    fontSize: buttonFontSize, 
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: buttonFontSize * 0.8,
                                color: Colors.white70,
                              )
                            ],
                          ),
                        ),
                      ),
                      
                      // Bottom spacer that adapts to screen height
                      SizedBox(height: screenHeight * 0.08),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
