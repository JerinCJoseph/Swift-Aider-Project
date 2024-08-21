import 'package:flutter/material.dart';

class ScaffoldCustomised extends StatelessWidget {
  const ScaffoldCustomised({super.key, required this.child});
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Swift Aider',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 57, 38, 61)
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset('assets/images/screenbg4.jpeg',
          fit:BoxFit.fill,
          width:double.maxFinite,
          height:double.maxFinite,
          ),
          Positioned(
            child: Container(
              height: MediaQuery.of(context).padding.top, //statusbar height
              color: Colors.black.withOpacity(0.5), //opaque overlay
            ),
          ),
          SafeArea(
            child: child!,
          )
        ],
      ),
    );
  }
}

 