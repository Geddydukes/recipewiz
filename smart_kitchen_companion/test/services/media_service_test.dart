import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_kitchen_companion/services/media_service.dart';

// Generate mocks
@GenerateMocks([
  ImagePicker,
  Record,
  stt.SpeechToText,
  CameraController,
  File,
  XFile,
  TextRecognizer,
  InputImage,
  RecognizedText
])
import 'media_service_test.mocks.dart';

void main() {
  late MediaService mediaService;
  late MockImagePicker mockImagePicker;
  late MockRecord mockRecord;
  late MockSpeechToText mockSpeechToText;
  late MockCameraController mockCameraController;
  late MockTextRecognizer mockTextRecognizer;
  late MockFile mockFile;
  late MockXFile mockXFile;
  late MockInputImage mockInputImage;
  late MockRecognizedText mockRecognizedText;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockRecord = MockRecord();
    mockSpeechToText = MockSpeechToText();
    mockCameraController = MockCameraController();
    mockTextRecognizer = MockTextRecognizer();
    mockFile = MockFile();
    mockXFile = MockXFile();
    mockInputImage = MockInputImage();
    mockRecognizedText = MockRecognizedText();

    // Setup common stubs
    when(mockXFile.path).thenReturn('/test/image.jpg');
    when(mockFile.path).thenReturn('/test/image.jpg');

    when(mockSpeechToText.initialize()).thenAnswer((_) async => true);
    when(mockRecord.hasPermission()).thenAnswer((_) async => true);
    when(mockRecord.isRecording()).thenReturn(false);
    
    when(mockRecognizedText.text).thenReturn('Recognized text from image');
    when(mockTextRecognizer.processImage(any)).thenAnswer((_) async => mockRecognizedText);

    // Create MediaService with mocked dependencies
    mediaService = MediaService.withDependencies(
      imagePicker: mockImagePicker,
      audioRecorder: mockRecord,
      speechToText: mockSpeechToText,
      textRecognizer: mockTextRecognizer,
    );
    mediaService.setCameraController(mockCameraController);
  });

  group('MediaService', () {
    test('takePhoto should return file when photo is taken', () async {
      // Arrange
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        previewSize: const Size(100, 100),
        isRecordingVideo: false,
      ));
      when(mockCameraController.takePicture()).thenAnswer((_) async => mockXFile);

      // Act
      final result = await mediaService.takePhoto();

      // Assert
      expect(result, isNotNull);
      expect(result!.path, '/test/image.jpg');
      verify(mockCameraController.takePicture()).called(1);
    });

    test('pickImage should return file when image is picked', () async {
      // Arrange
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
        imageQuality: anyNamed('imageQuality'),
      )).thenAnswer((_) async => mockXFile);

      // Act
      final result = await mediaService.pickImage();

      // Assert
      expect(result, isNotNull);
      expect(result!.path, '/test/image.jpg');
      verify(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: anyNamed('maxWidth'),
        maxHeight: anyNamed('maxHeight'),
        imageQuality: anyNamed('imageQuality'),
      )).called(1);
    });

    test('startVideoRecording should call camera controller', () async {
      // Arrange
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        previewSize: const Size(100, 100),
        isRecordingVideo: false,
      ));
      when(mockCameraController.startVideoRecording()).thenAnswer((_) async {});

      // Act
      await mediaService.startVideoRecording();

      // Assert
      verify(mockCameraController.startVideoRecording()).called(1);
    });

    test('stopVideoRecording should return file when recording is stopped', () async {
      // Arrange
      when(mockCameraController.value).thenReturn(CameraValue(
        isInitialized: true,
        previewSize: const Size(100, 100),
        isRecordingVideo: true,
      ));
      when(mockCameraController.stopVideoRecording()).thenAnswer((_) async => mockXFile);

      // Act
      final result = await mediaService.stopVideoRecording();

      // Assert
      expect(result, isNotNull);
      expect(result!.path, '/test/image.jpg');
      verify(mockCameraController.stopVideoRecording()).called(1);
    });

    test('performOCR should return recognized text', () async {
      // Arrange
      when(mockInputImage.fromFile(any)).thenReturn(mockInputImage);

      // Act
      final result = await mediaService.performOCR(mockFile);

      // Assert
      expect(result, 'Recognized text from image');
      verify(mockTextRecognizer.processImage(any)).called(1);
    });

    test('startAudioRecording should call audio recorder', () async {
      // Act
      await mediaService.startAudioRecording('/test/audio.m4a');

      // Assert
      verify(mockRecord.start(path: '/test/audio.m4a')).called(1);
    });

    test('stopAudioRecording should call audio recorder stop', () async {
      // Act
      await mediaService.stopAudioRecording();

      // Assert
      verify(mockRecord.stop()).called(1);
    });

    test('initializeSpeechToText should initialize speech recognition', () async {
      // Act
      final result = await mediaService.initializeSpeechToText();

      // Assert
      expect(result, true);
      verify(mockSpeechToText.initialize()).called(1);
    });
  });
} 