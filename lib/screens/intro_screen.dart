import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart'; // আপনার রুট ফাইলের সঠিক পাথ দিন

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ১. এনিমেশন কন্ট্রোলার সেটআপ (২ সেকেন্ড সময় নেবে)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // ২. Opacity (স্বচ্ছতা) এনিমেশন সেটআপ
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn, // স্মুথ এনিমেশনের জন্য
      ),
    );

    // ৩. অ্যাপ ওপেন হওয়ার ১ সেকেন্ড পর এনিমেশন শুরু হবে
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });

    // ৪. ৪ সেকেন্ড পর স্ট্যাটাস অনুযায়ী সঠিক স্ক্রিনে নেভিগেট হবে
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.needsMfaVerification) {
          Navigator.pushReplacementNamed(context, AppRoutes.mfaChallenge);
        } else if (authProvider.isAuthenticated || authProvider.isGuest) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // মেমরি লিক এড়াতে কন্ট্রোলার ডিসপোজ করুন
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ১. ব্যাকগ্রাউন্ড ইমেজ
          Image.asset(
            'assets/images/wedding_hero.jpg', // আপনার ইমেজের পাথ ঠিক আছে কিনা নিশ্চিত করুন
            fit: BoxFit.cover,
          ),

          // ২. ইমেজের ওপর হালকা কালো শেড (টেক্সট ফুটে ওঠার জন্য)
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),

          // ৩. মাঝখানে 'vowora' টেক্সট সাথে এনিমেশন
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                'vowora',
                style: TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.w300, // অ্যাপলের মতো পাতলা ফন্ট
                  color: Colors.white,
                  letterSpacing: 10.0, // অক্ষরগুলোর মাঝে দূরত্ব
                  // fontFamily: 'Serif', // আপনি চাইলে কাস্টম ফন্ট ব্যবহার করতে পারেন
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}