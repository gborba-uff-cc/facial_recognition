import 'package:facial_recognition/screens/camera_view/camera_view.dart';
import 'package:facial_recognition/screens/mark_attendance.dart';
import 'package:facial_recognition/screens/placeholder/placeholder_screen.dart';
import 'package:facial_recognition/screens/select_lesson_screen.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';

void main() async {
  // hide async code with a splash screen
  runApp(const Placeholder());
  // start async code as soon as possible
  final futures = await Future.wait(
    [
      availableCameras(),
    ],
  );
  final availableCams = futures[0];
  // sync code goes under here
  projectLogger.fine(availableCams);
  //
  runApp(MainApp(cameras: availableCams));
}

class MainApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MainApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => PlaceholderScreen(
              nextScreens: const ['/select_lesson', '/camera_view', '/mark_attendance'],
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'select_lesson',
                builder: (context, state) => const SelectLessonScreen(),
              ),
              GoRoute(
                path: 'camera_view',
                builder: (context, state) => CameraView(cameras: cameras),
              ),
              GoRoute(
                path: 'mark_attendance',
                builder: (context, state) => const MarkAttendance(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
