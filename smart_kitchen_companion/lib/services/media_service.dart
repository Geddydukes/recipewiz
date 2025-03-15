import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MediaService {
  final ImagePicker _imagePicker;
  final Record _audioRecorder;
  final stt.SpeechToText _speechToText;
  final TextRecognizer _textRecognizer;
  CameraController? _cameraController;

  // Default constructor
  MediaService() 
    : _imagePicker = ImagePicker(),
      _audioRecorder = Record(),
      _speechToText = stt.SpeechToText(),
      _textRecognizer = GoogleMlKit.vision.textRecognizer();
  
  // Constructor with dependency injection for testing
  MediaService.withDependencies({
    required ImagePicker imagePicker,
    required Record audioRecorder,
    required stt.SpeechToText speechToText,
    required TextRecognizer textRecognizer,
  })  : _imagePicker = imagePicker,
        _audioRecorder = audioRecorder,
        _speechToText = speechToText,
        _textRecognizer = textRecognizer;

  // Set camera controller (useful for testing)
  void setCameraController(CameraController cameraController) {
    _cameraController = cameraController;
  }

  // Initialize camera
  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController?.initialize();
  }

  // Dispose resources
  Future<void> dispose() async {
    await _cameraController?.dispose();
    await _textRecognizer.close();
  }

  // Take a photo
  Future<File?> takePhoto() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized');
      }

      final XFile? photo = await _cameraController?.takePicture();
      return photo != null ? File(photo.path) : null;
    } catch (e) {
      rethrow;
    }
  }

  // Pick image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      rethrow;
    }
  }

  // Record video
  Future<void> startVideoRecording() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized');
      }

      await _cameraController?.startVideoRecording();
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> stopVideoRecording() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        throw Exception('Camera not initialized');
      }

      final XFile video = await _cameraController!.stopVideoRecording();
      return File(video.path);
    } catch (e) {
      rethrow;
    }
  }

  // Pick video from gallery
  Future<File?> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
      return video != null ? File(video.path) : null;
    } catch (e) {
      rethrow;
    }
  }

  // Audio recording
  Future<void> startAudioRecording(String filePath) async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(path: filePath);
      } else {
        throw Exception('Audio recording permission not granted');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopAudioRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      rethrow;
    }
  }

  // Speech to text
  Future<bool> initializeSpeechToText() async {
    try {
      return await _speechToText.initialize();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startListening(Function(String) onResult) async {
    try {
      await _speechToText.listen(
        onResult: (result) => onResult(result.recognizedWords),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      rethrow;
    }
  }

  // OCR
  Future<String> performOCR(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      rethrow;
    }
  }

  // Get camera preview widget
  CameraController? get cameraController => _cameraController;

  // Check if recording
  bool get isRecording => _audioRecorder.isRecording();

  // Check if speech recognition is available
  bool get isSpeechAvailable => _speechToText.isAvailable;
}
