import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/face_recognizer.dart';
import 'package:facial_recognition/models/facenet_face_embedder.dart';
import 'package:facial_recognition/models/google_face_detector.dart';
import 'package:facial_recognition/models/image_handler.dart';
import 'package:facial_recognition/models/recognition_pipeline.dart';
import 'package:facial_recognition/screens/attendance_summary_screen.dart';
import 'package:facial_recognition/screens/camera_identification_screen.dart';
import 'package:facial_recognition/screens/create_attendance_from_spreadsheet_screen.dart';
import 'package:facial_recognition/screens/create_enrollment_screen.dart';
import 'package:facial_recognition/screens/create_information_manually_screen.dart';
import 'package:facial_recognition/screens/create_information_spreadsheet_screen.dart';
import 'package:facial_recognition/screens/create_lesson_from_batch_screen.dart';
import 'package:facial_recognition/screens/create_lesson_menu_screen.dart';
import 'package:facial_recognition/screens/create_lesson_screen.dart';
import 'package:facial_recognition/screens/create_student_from_batch_screen.dart';
import 'package:facial_recognition/screens/create_student_menu_screen.dart';
import 'package:facial_recognition/screens/create_student_screen.dart';
import 'package:facial_recognition/screens/create_subject_class_screen.dart';
import 'package:facial_recognition/screens/create_subject_screen.dart';
import 'package:facial_recognition/screens/create_teacher_screen.dart';
import 'package:facial_recognition/screens/fast_view.dart';
import 'package:facial_recognition/screens/grid_student_selector_screen.dart';
import 'package:facial_recognition/screens/landing_screen.dart';
import 'package:facial_recognition/screens/mark_attendance_screen.dart';
import 'package:facial_recognition/screens/common/one_shot_camera.dart';
import 'package:facial_recognition/screens/select_information_screen.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:facial_recognition/use_case/spreadsheet_read.dart';
import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:facial_recognition/use_case/select_lesson.dart';
import 'package:facial_recognition/utils/distance.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as pkg_image;
import 'package:path/path.dart' as pkg_path;
import 'package:path_provider/path_provider.dart' as pkg_path_provider;

import 'models/domain_repository.dart';

void main() async {
  const relativeSqlStatementsJsonPath = 'assets/sqlStatements_v2.json';
  const relativeDatabasePath = 'database.sqlite3';

  // hide async code with a splash screen
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
  );

  // start async code as soon as possible
  final futures = Future.wait(
    [
      pkg_camera.availableCameras(),
      pkg_path_provider.getApplicationDocumentsDirectory(),
      rootBundle.loadStructuredData<SqlStatementsLoader>(
        relativeSqlStatementsJsonPath,
        (content) => Future.value(SqlStatementsLoader(jsonDecode(content))),
      ),
    ],
    eagerError: true,
  );
  List<Object> completed = [];
  dynamic errorOrEception;
  try {
    completed = await futures;
  }
  on pkg_camera.CameraException catch (e) {
    errorOrEception = e;
  }
  on pkg_path_provider.MissingPlatformDirectoryException catch (e) {
    errorOrEception = e;
  }
  on FlutterError catch (e) {
    errorOrEception = e;
  }
  if (errorOrEception != null) {
    projectLogger.severe(errorOrEception);
    runApp(MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text('Falha ao carregar alguns componentes cruciais.'),
          ),
        ),
      ),
    ));
    return;
  }

  // sync code goes under here
  final List<pkg_camera.CameraDescription> availableCams =
      completed[0] as List<pkg_camera.CameraDescription>;
  final Directory appDocuments = completed[1] as Directory;
  final SqlStatementsLoader sqlStatementsLoader = completed[2] as SqlStatementsLoader;
  final String databasePath = pkg_path.canonicalize(
    pkg_path.join(appDocuments.path, relativeDatabasePath),
  );

  // final domainRepository = kDebugMode || kProfileMode ? InMemoryDomainRepositoryForTests() : InMemoryDomainRepository();
  final domainRepository = SQLite3DomainRepository(
    databasePath: databasePath,
    statementsLoader: sqlStatementsLoader,
  );

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
  final IDomainRepository domainRepository;

  @override
  Widget build(BuildContext context) {
    final IFaceDetector faceDetector = GoogleFaceDetectorForCamerawesome();
    final IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription, pkg_image.Image, Uint8List> imageHandler = ImageHandler();
    final IFaceEmbedder faceEmbedder = FacenetFaceEmbedder();
    final IFaceRecognizer<Student, List<double>> faceRecognizer = DistanceClassifier(distanceFunction: euclideanDistance);
    final IRecognitionPipeline<
        pkg_camera.CameraImage,
        pkg_camera.CameraController,
        pkg_image.Image,
        Uint8List,
        Student,
        FaceEmbedding> recognitionPipeline = RecognitionPipeline(
      faceDetector: faceDetector,
      imageHandler: imageHandler,
      faceEmbedder: faceEmbedder,
      faceRecognizer: faceRecognizer,
    );
    final CreateModels createModels = CreateModels(
      domainRepository,
      imageHandler,
      recognitionPipeline
    );
    final spreadsheetRead = SpreadsheetRead();
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
                  ),
                  hideLesson:
                      state.uri.queryParameters['hideLesson'] == '${true}',
                  hideSubjectClasses:
                      state.uri.queryParameters['hideSubjectClass'] == '${true}',
                ),
              ),
              GoRoute(
                path: 'camera_view',
                builder: (context, state) => CameraIdentificationScreen(
                  cameras: cameras,
                  useCase: CameraIdentification(
                    recognitionPipeline,
                    imageHandler,
                    domainRepository,
                    // null, // showFaceImages
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
                    domainRepository: domainRepository,
                    subjectClass: state.extra as SubjectClass,
                    minimumAttendanceRatio: 0.75,
                  ),
                ),
              ),
              GoRoute(
                path: 'create_information_manually',
                builder: (context, state) => CreateInformationManuallyScreen(),
              ),
              GoRoute(
                path: 'create_information_from_spreadsheet',
                builder: (context, state) => CreateInformationFromSpreadsheetScreen(),
              ),
              GoRoute(
                path: 'create_attendance_from_spreadsheet',
                builder: (context, state) => CreateAttendanceFromSpreadsheetScreen(
                  createModelsUseCase: createModels,
                  spreadsheetReadUseCase: spreadsheetRead,
                ),
              ),
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
                builder: (context, state) => CreateLessonMenuScreen(),
              ),
              GoRoute(
                path: 'create_lesson_manually',
                builder: (context, state) => CreateLessonScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_lesson_from_spreadsheet',
                builder: (context, state) => CreateLessonFromBatchScreen(
                  batchReadUseCase: spreadsheetRead,
                  createModelsUseCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_student',
                builder: (context, state) => CreateStudentMenuScreen(),
              ),
              GoRoute(
                path: 'create_student_manually',
                builder: (context, state) => CreateStudentScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_student_from_spreadsheet',
                builder: (context, state) => CreateStudentFromBatchScreen(
                  batchReadUseCase: spreadsheetRead,
                  createModelsUseCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_teacher',
                builder: (context, state) => CreateTeacherScreen(
                  useCase: createModels,
                ),
              ),
              GoRoute(
                path: 'create_enrollment',
                builder: (context, state) => CreateEnrollmentScreen(
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
