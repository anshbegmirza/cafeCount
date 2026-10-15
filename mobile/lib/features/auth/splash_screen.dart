import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HrColors.forest,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 180, height: 180, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(
              'tagline'.tr(),
              style: const TextStyle(color: HrColors.cream, fontSize: 16, letterSpacing: 0.3),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
