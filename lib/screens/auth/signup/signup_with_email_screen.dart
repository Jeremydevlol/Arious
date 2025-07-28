import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/screens/auth/signup/controllers/signup_with_email_controller.dart';
import 'package:chat_messenger/helpers/app_helper.dart';
import 'package:chat_messenger/routes/app_routes.dart';

class SignUpWithEmailScreen extends GetView<SignUpWithEmailController> {
  const SignUpWithEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1B1B),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    'Sign Up',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFF00C2FF),
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ─── EMAIL ──────────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,                     // fondo blanco
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: controller.emailController,
                      style: const TextStyle(
                        color: Colors.black,                  // texto negro
                        fontSize: 16,
                      ),
                      validator: (String? value) {
                        if (GetUtils.isEmail(value ?? '')) return null;
                        return 'Please enter a valid email address';
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: InputBorder.none,
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],            // hint gris oscuro
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          IconlyLight.message,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── PASSWORD ─────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextFormField(
                      controller: controller.passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      validator: AppHelper.validatePassword,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(20),
                        border: InputBorder.none,
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          IconlyLight.lock,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── BOTÓN SIGN‑UP ────────────────────────────────────────
                  Obx(
                    () => SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.signUpWithEmailAndPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C2FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Sign Up',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── LINK SIGN‑IN ─────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.signIn),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Color(0xFF00C2FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ─── PRIVACY & TERMS ──────────────────────────────────────
                  const Text(
                    'By signing up you agree with our',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
                          ),
                        ),
                      ),
                      Text(
                        'and',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(
                            color: Color(0xFF00C2FF),
                            fontWeight: FontWeight.w500,
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
    );
  }
}