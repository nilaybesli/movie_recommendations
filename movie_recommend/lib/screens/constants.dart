import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static const Color pinkColor = Color(0xFFFE53BB);
  static const Color greenColor = Color(0xFF09FBD3);
  static const Color blackColor = Color(0xFF19191B);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color grayColor = Color(0x80808080);
  static const LinearGradient appColor = LinearGradient(
    colors: [Color(0xff551560), Color(0xFF2E2E2E)],
    stops: [0.0, 0.7],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );
}

class BackgroundWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Positioned(
          top: screenHeight * 0.1,
          left: -88,
          child: Container(
            height: 166,
            width: 166,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Constants.greenColor,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 200,
                sigmaY: 200,
              ),
              child: Container(
                height: 166,
                width: 166,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.3,
          right: -86,
          child: Container(
            height: 200,
            width: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Constants.pinkColor,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 200,
                sigmaY: 200,
              ),
              child: Container(
                height: 200,
                width: 200,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
