import 'dart:typed_data';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/face_recognizer.dart';
import 'package:facial_recognition/models/facenet_face_embedder.dart';
import 'package:facial_recognition/models/google_face_detector.dart';
import 'package:facial_recognition/models/image_handler.dart';
import 'package:facial_recognition/screens/attendance_summary_screen.dart';
import 'package:facial_recognition/screens/camera_identification_screen.dart';
import 'package:facial_recognition/screens/create_lesson_screen.dart';
import 'package:facial_recognition/screens/create_student_screen.dart';
import 'package:facial_recognition/screens/create_subject_class_screen.dart';
import 'package:facial_recognition/screens/create_subject_screen.dart';
import 'package:facial_recognition/screens/create_teacher_screen.dart';
import 'package:facial_recognition/screens/fast_view.dart';
import 'package:facial_recognition/screens/grid_student_selector_screen.dart';
import 'package:facial_recognition/screens/landing_screen.dart';
import 'package:facial_recognition/screens/mark_attendance_screen.dart';
import 'package:facial_recognition/screens/placeholder_screen.dart';
import 'package:facial_recognition/screens/select_information_screen.dart';
import 'package:facial_recognition/screens/one_shot_camera.dart';
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
      pkg_camera.availableCameras(),
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

  final List<pkg_camera.CameraDescription> cameras;
  final DomainRepository domainRepository;

  @override
  Widget build(BuildContext context) {
    final IFaceDetector<pkg_camera.CameraImage> faceDetector = GoogleFaceDetector();
    final IImageHandler<pkg_camera.CameraImage, pkg_image.Image, Uint8List> imageHandler = ImageHandler();
    final IFaceEmbedder faceEmbedder = FacenetFaceEmbedder();
    final IFaceRecognizer<Student, List<double>> faceRecognizer = DistanceClassifier(distanceFunction: euclideanDistance);
    final CreateModels createModels = CreateModels(domainRepository, faceDetector, imageHandler);
    return MaterialApp.router(
      theme: ThemeData(useMaterial3: true),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
/*
            // fast view
            builder: (context, state) => FastView(),
            // dev menu
            builder: (context, state) => PlaceholderScreen(
              nextScreens: const ['/select_lesson', '/camera_view', '/mark_attendance', '/attendance_summary', '/create_models'],
              domainRepository: domainRepository,
            ),
*/
            // landing screen
            builder: (context, state) => LandingScreen(
              domainRepository: domainRepository,
            ),
            routes: <RouteBase>[
              GoRoute(
                path: 'select_information',
                builder: (context, state) => SelectInformationScreen(
                    useCase: SelectLesson(
                  domainRepository,
                )),
              ),
              GoRoute(
                path: 'camera_view',
                builder: (context, state) => CameraIdentificationScreen(
                  cameras: cameras,
                  useCase: CameraIdentification(
                    faceDetector,
                    imageHandler,
                    faceEmbedder,
                    faceRecognizer,
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
                path: 'mark_attendance_edit_student',
                builder: (context, state) => gridstudentSelector(
                  state.extra as GridStudentSelectorScreenArguments<MapEntry<Student, FacePicture?>>,
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
/*
              GoRoute(
                path: 'create_models',
                builder: (context, state) => CreateModelsScreen(
                  useCase: CreateModels(domainRepository),
                ),
              ),
*/
              GoRoute(
                path: 'create_subject',
                builder: (context, state) => CreateSubjectScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_subject_class',
                builder: (context, state) => CreateSubjectClassScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_lesson',
                builder: (context, state) => CreateLessonScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_student',
                builder: (context, state) => CreateStudentScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_teacher',
                builder: (context, state) => CreateTeacherScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'take_photo',
                builder: (context, state) => OneShotCamera(
                  camerasAvailable: cameras,
                  imageHandler: imageHandler,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
