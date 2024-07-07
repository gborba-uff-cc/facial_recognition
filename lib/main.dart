import 'package:camera/camera.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/face_recognizer.dart';
import 'package:facial_recognition/models/facenet_face_embedder.dart';
import 'package:facial_recognition/models/google_face_detector.dart';
import 'package:facial_recognition/models/image_handler.dart';
import 'package:facial_recognition/screens/attendance_summary_screen.dart';
import 'package:facial_recognition/screens/camera_identification_screen.dart';
import 'package:facial_recognition/screens/create_models_screen.dart';
import 'package:facial_recognition/screens/mark_attendance_screen.dart';
import 'package:facial_recognition/screens/landing_screen.dart';
// import 'package:facial_recognition/screens/placeholder_screen.dart';
import 'package:facial_recognition/screens/select_lesson_screen.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:facial_recognition/use_case/select_lesson.dart';
import 'package:facial_recognition/utils/distance.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  final domainRepository = DomainRepositoryForTests();
  // sync code goes under here
  projectLogger.fine(availableCams);
  //
  runApp(MainApp(
    cameras: availableCams,
    domainRepository: domainRepository,
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({
    super.key,
    required this.cameras,
    required this.domainRepository,
  });

  final List<CameraDescription> cameras;
  final DomainRepository domainRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
/*
            builder: (context, state) => PlaceholderScreen(
              nextScreens: const ['/select_lesson', '/camera_view', '/mark_attendance', '/attendance_summary', '/create_models'],
              domainRepository: domainRepository,
            ),
*/
            builder: (context, state) => LandingScreen(
              domainRepository: domainRepository,
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'select_lesson',
                builder: (context, state) => SelectLessonScreen(
                    useCase: SelectLesson(
                  domainRepository,
                )),
              ),
              GoRoute(
                path: 'camera_view',
                builder: (context, state) => CameraIdentificationScreen(
                  cameras: cameras,
                  useCase: CameraIdentification(
                    GoogleFaceDetector(),
                    ImageHandler(),
                    FacenetFaceEmbedder(),
                    DistanceClassifier(distanceFunction: euclideanDistance),
                    domainRepository,
                    null,
                    state.extra as Lesson,
                  ),
                ),
              ),
              GoRoute(
                path: 'mark_attendance',
                builder: (context, state) => MarkAttendanceScreen(
                  useCase: MarkAttendance(
                    domainRepository,
                    state.extra as Lesson,
                  ),
                ),
              ),
              GoRoute(
                path: 'attendance_summary',
                builder: (context, state) => AttendanceSummaryScreen(
                  useCase: AttendanceSummary(
                    domainRepository,
                    state.extra as SubjectClass,
                  ),
                ),
              ),
              GoRoute(
                path: 'create_models',
                builder: (context, state) => CreateModelsScreen(
                  useCase: CreateModels(domainRepository),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
