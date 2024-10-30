import 'dart:typed_data';

import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:flutter/material.dart';

class FastView extends StatelessWidget {
  const FastView({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: 350,
          child: AppDefaultTotenIdentificationCard(
            faceJpg: Uint8List(0),
            name: 'aReallyReallyReallyReallyReallyReallyLongName',
            registration: 'aVeryLongRegistrationValue',
            onAccept: () {},
            onRevise: () {},
          ),
        ),
      ),
    );
  }
}
