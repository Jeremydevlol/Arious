import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/components/app_logo.dart';
import 'package:chat_messenger/screens/auth/signin/controller/signin_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/routes/app_routes.dart';
import 'dart:ui';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1E2746),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF1B1B1B),
                    const Color(0xFF1E2746).withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: controller.emailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo with enhanced glow
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C2FF).withOpacity(0.15),
                              blurRadius: 50,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: const Color(0xFF00C2FF).withOpacity(0.1),
                              blurRadius: 120,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                        child: const AppLogo(width: 160),
                      ),
                      const SizedBox(height: 40),
                      
                      // Title with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00C2FF),
                            Colors.white,
                            Color(0xFF00C2FF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Login to your account',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: controller.emailController,
                          style: const TextStyle(
                            color: Color(0xFF1E2746),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            height: 1.5,
                          ),
                          cursorColor: Color(0xFF00C2FF),
                          validator: (String? value) {
                            if (GetUtils.isEmail(value ?? '')) return null;
                            return 'Please enter a valid email address';
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(24),
                            border: InputBorder.none,
                            hintText: 'Email',
                            fillColor: Colors.white,
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: const TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                            prefixIcon: Icon(
                              IconlyLight.message,
                              color: const Color(0xFF1E2746),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.obscurePassword.value,
                          style: const TextStyle(
                            color: Color(0xFF1E2746),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                            height: 1.5,
                          ),
                          cursorColor: Color(0xFF00C2FF),
                          validator: AppHelper.validatePassword,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(24),
                            border: InputBorder.none,
                            hintText: 'Password',
                            fillColor: Colors.white,
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                            errorStyle: const TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                            prefixIcon: Icon(
                              IconlyLight.lock,
                              color: const Color(0xFF1E2746),
                              size: 24,
                            ),
                            suffixIcon: Obx(
                              () => IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF1E2746),
                                  size: 24,
                                ),
                                onPressed: () => controller.togglePasswordVisibility(),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sign in button with gradient
                      Obx(
                        () => Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF00C2FF),
                                Color(0xFF0080FF),
                                Color(0xFF00C2FF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00C2FF).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.signInWithEmailAndPassword(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                              letterSpacing: 0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.signUpWithEmail),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF00C2FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Privacy and Terms
                      Text(
                        'By signing in you agree with our',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: Color(0xFF00C2FF),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Text(
                            'and',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                color: Color(0xFF00C2FF),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
