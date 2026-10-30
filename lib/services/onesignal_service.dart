import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'tts_service.dart';

class OneSignalService {
  static OneSignalService? _instance;
  static OneSignalService get instance => _instance ??= OneSignalService._();

  OneSignalService._();

  Future<void> init() async {
    try {
      print('OneSignal: Initializing...');
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize('b6cd78e6-da30-4d45-bdec-c92ce5eeec08');

      print('OneSignal: Requesting notification permission...');
      OneSignal.Notifications.requestPermission(true);

      // Get and print the onesignal_id
      final onesignalId = await OneSignal.User.getOnesignalId();
      print('OneSignal: onesignal_id = $onesignalId');

      OneSignal.Notifications.addClickListener((event) {
        print('OneSignal: Notification clicked - ${event.notification.title}');

        // Lire la notification à haute voix quand l'utilisateur clique
        final title = event.notification.title ?? '';
        final body = event.notification.body ?? '';
        final message = '$title. $body';

        print('OneSignal: Attempting to speak notification on click');
        TTSService.instance.speak(message);
      });

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print(
          'OneSignal: Notification received in foreground - ${event.notification.title}',
        );

        // Lire la notification à haute voix quand l'app est ouverte
        final title = event.notification.title ?? '';
        final body = event.notification.body ?? '';
        final message = '$title. $body';

        print('OneSignal: Attempting to speak notification in foreground');
        TTSService.instance.speak(message);
      });

      print('OneSignal: Initialization completed');
    } catch (e) {
      print('OneSignal: Init error - $e');
    }
  }

  void login(String userId) {
    print('OneSignal: Logging in user - userId=$userId');
    OneSignal.login(userId);
    print('OneSignal: User logged in successfully');
  }

  void logout() {
    print('OneSignal: Logging out user');
    OneSignal.logout();
    print('OneSignal: User logged out successfully');
  }

  Future<String?> getOnesignalId() async {
    try {
      final onesignalId = await OneSignal.User.getOnesignalId();
      print('OneSignal: getOnesignalId = $onesignalId');
      return onesignalId;
    } catch (e) {
      print('OneSignal: Error getting onesignal_id - $e');
      return null;
    }
  }
}
