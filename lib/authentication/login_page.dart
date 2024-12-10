import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:landify/components/my_button.dart';
import 'package:landify/components/my_textfield.dart';
import 'package:landify/components/square_tile.dart';
import 'package:landify/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

void signUserIn() async {
  // Show loading circle
  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    },
  );

  try {
    // Sign in with Firebase
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // Pop loading circle, check if the widget is still mounted
    if (!mounted) return; // Make sure the widget is still in the widget tree

    Navigator.pop(context);  // Dismiss the loading circle

  } on FirebaseAuthException catch (e) {
    // Pop loading circle, check if the widget is still mounted
    if (!mounted) return; // Make sure the widget is still in the widget tree

    Navigator.pop(context);  // Dismiss the loading circle

    // Show error message
    showErrorMessage(e.code);
  }
}

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 247, 112, 112),
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          // Background with blur and gradient overlay
          Stack(
            children: [
              // Background image
              Image.asset(
                'assets/back.jpeg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Blur effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),

          // Main content
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,  // Shrink-wrap the column
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // Logo
                  Image.asset(
                    'assets/landiBack.png',
                    height: 150,
                  ),

                  const SizedBox(height: 20),

                  // Welcome back text
                  Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),

                  const SizedBox(height: 25),

                  // Email TextField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: MyTextfield(
                      controller: emailController,
                      hintText: "Email",
                      obscureText: false,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Password TextField
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: MyTextfield(
                      controller: passwordController,
                      hintText: "Password",
                      obscureText: true,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot password text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Sign in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: MyButton(
                      text: "Sign in",
                      onTap: signUserIn,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white70,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or continue with, ",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Google or Apple sign-in buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google button
                      SquareTile(
                        imagePath: 'assets/google.png',
                        onTap: () => AuthService().signInWithGoogle(),
                      ),

                      const SizedBox(width: 25),

                      // Apple button
                      SquareTile(
                        imagePath: 'assets/apple.png',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 50),

                  // Not a member, register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Register now",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
