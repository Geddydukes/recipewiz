import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_kitchen_companion/services/notification_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseMessaging,
  FlutterLocalNotificationsPlugin,
  AndroidNotificationChannel,
  NotificationDetails,
  InitializationSettings,
])
import 'notification_service_test.mocks.dart';

void main() {
  late NotificationService notificationService;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late MockAndroidNotificationChannel mockAndroidChannel;
  late MockNotificationDetails mockNotificationDetails;
  late MockInitializationSettings mockInitSettings;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    mockAndroidChannel = MockAndroidNotificationChannel();
    mockNotificationDetails = MockNotificationDetails();
    mockInitSettings = MockInitializationSettings();

    // Setup common stubs
    when(mockFirebaseMessaging.requestPermission()).thenAnswer((_) async => NotificationSettings());
    when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => 'mock-token');
    when(mockLocalNotifications.initialize(any, onSelectNotification: anyNamed('onSelectNotification')))
        .thenAnswer((_) async => true);

    // Create NotificationService with mocked dependencies
    notificationService = NotificationService.withDependencies(
      firebaseMessaging: mockFirebaseMessaging,
      localNotifications: mockLocalNotifications,
      androidChannel: mockAndroidChannel,
      notificationDetails: mockNotificationDetails,
      initSettings: mockInitSettings,
    );
  });

  group('NotificationService', () {
    test('initialize should request permissions and get token', () async {
      // Act
      await notificationService.initialize();

      // Assert
      verify(mockFirebaseMessaging.requestPermission()).called(1);
      verify(mockFirebaseMessaging.getToken()).called(1);
      verify(mockLocalNotifications.initialize(any, onSelectNotification: anyNamed('onSelectNotification')))
          .called(1);
    });

    test('showLocalNotification should show notification', () async {
      // Act
      await notificationService.showLocalNotification(
        title: 'Test Title',
        body: 'Test Body',
        payload: 'test-payload',
      );

      // Assert
      verify(mockLocalNotifications.show(
        any,
        'Test Title',
        'Test Body',
        any,
        payload: 'test-payload',
      )).called(1);
    });

    test('scheduleNotification should schedule notification', () async {
      // Arrange
      final scheduledDate = DateTime.now().add(const Duration(hours: 1));

      // Act
      await notificationService.scheduleNotification(
        title: 'Test Title',
        body: 'Test Body',
        scheduledDate: scheduledDate,
        payload: 'test-payload',
      );

      // Assert
      verify(mockLocalNotifications.zonedSchedule(
        any,
        'Test Title',
        'Test Body',
        any,
        any,
        payload: 'test-payload',
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      )).called(1);
    });

    test('cancelNotification should cancel notification', () async {
      // Act
      await notificationService.cancelNotification(1);

      // Assert
      verify(mockLocalNotifications.cancel(1)).called(1);
    });

    test('cancelAllNotifications should cancel all notifications', () async {
      // Act
      await notificationService.cancelAllNotifications();

      // Assert
      verify(mockLocalNotifications.cancelAll()).called(1);
    });

    test('getToken should return FCM token', () async {
      // Act
      final token = await notificationService.getToken();

      // Assert
      expect(token, 'mock-token');
      verify(mockFirebaseMessaging.getToken()).called(1);
    });
  });
} 