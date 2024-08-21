import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:first_aid_project/widgets/user_state_check.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  get splash => null;

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash: 
    Wrap(
      children: [
        Center(
          child: LottieBuilder.asset( 
            "assets/lottie/FirstAiderAnimation.json",
            fit: BoxFit.fill,),
        )
      ], 
    ), 
    backgroundColor: Colors.black,
    splashTransition: SplashTransition.fadeTransition,
    duration: 3500, 
    nextScreen: const UserStateCheck(),   //navigates to UserSTate Check    
    );
  }
}