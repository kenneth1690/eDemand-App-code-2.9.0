import 'package:e_demand/app/generalImports.dart';

class NotificationService {

  static FirebaseMessaging messagingInstance = FirebaseMessaging.instance;
  static LocalAwesomeNotification localNotification = LocalAwesomeNotification();
  static late StreamSubscription<RemoteMessage> foregroundStream;
  static late StreamSubscription<RemoteMessage> onMessageOpen;

  static Future<void> requestPermission() async {
    //
    await messagingInstance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    //
  }

  static Future<void> init(final context) async {
    try {

      await ChatNotificationsUtils.initialize();

      await requestPermission();
      await registerListeners(context);
    } catch (_) {}
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(final RemoteMessage message) async {

    if (message.data["type"] == "chat") {
      //background chat message storing
      final List<ChatNotificationData> oldList =
          await ChatNotificationsRepository().getBackgroundChatNotificationData();
      final messageChatData = ChatNotificationData.fromRemoteMessage(remoteMessage: message);
      oldList.add(messageChatData);
      ChatNotificationsRepository().setBackgroundChatNotificationData(data: oldList);
      if (Platform.isAndroid) {
        ChatNotificationsUtils.createChatNotification(chatData: messageChatData, message: message);
      }
    } else {

      if (message.data["image"] == null) {
        localNotification.createNotification(isLocked: false, notificationData: message);
      } else {
        localNotification.createImageNotification(isLocked: false, notificationData: message);
      }
    }
  }

  static Future foregroundNotificationHandler() async {
    foregroundStream = FirebaseMessaging.onMessage.listen((final RemoteMessage message) {


      if (message.data["type"] == "chat") {
        ChatNotificationsUtils.addChatStreamAndShowNotification(message: message);
      } else {
        if (message.data.isEmpty) {
          localNotification.createNotification(isLocked: false, notificationData: message);
        } else if (message.data["image"] == null) {
          localNotification.createNotification(isLocked: false, notificationData: message);
        } else {
          localNotification.createImageNotification(isLocked: false, notificationData: message);
        }
      }
    });
  }

  static Future terminatedStateNotificationHandler() async {
    FirebaseMessaging.instance.getInitialMessage().then(
      (final RemoteMessage? message) {
        if (message == null) {
          return;
        }
        if (message.data["image"] == null) {
          localNotification.createNotification(isLocked: false, notificationData: message);
        } else {
          localNotification.createImageNotification(isLocked: false, notificationData: message);
        }
      },
    );
  }

  static Future<void> onTapNotificationHandler() async {
    onMessageOpen = FirebaseMessaging.onMessageOpenedApp.listen(
      (final message) async {
        if (message.data["type"] == "chat") {
          //get off the route if already on it
          if (Routes.currentRoute == chatMessages) {
            UiUtils.rootNavigatorKey.currentState?.pop();
          }
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(chatMessages, arguments: {
            "chatUser": ChatUser.fromNotificationData(message.data)
          });
        } else if (message.data["type"] == "category") {
          if (message.data["parent_id"] == "0") {
            await UiUtils.rootNavigatorKey.currentState?.pushNamed(
              subCategoryRoute,
              arguments: {
                'subCategoryId': '',
                'categoryId': message.data["category_id"],
                'appBarTitle': message.data["category_name"],
                'type': CategoryType.category
              },
            );
          } else {
            await UiUtils.rootNavigatorKey.currentState?.pushNamed(
              subCategoryRoute,
              arguments: {
                'subCategoryId': message.data["category_id"],
                'categoryId': '',
                'appBarTitle': message.data["category_name"],
                'type': CategoryType.subcategory
              },
            );
          }
        } else if (message.data["type"] == "provider") {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(
            providerRoute,
            arguments: {'providerId': message.data["provider_id"]},
          );
        } else if (message.data["type"] == "order") {
          //navigate to booking tab

          //    bottomNavigationBarGlobalKey.currentState?.selectedIndexOfBottomNavigationBar.value = 1;
        } else if (message.data["type"] == "url") {
          final url = message.data["url"].toString();
          try {
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $url';
            }
          } catch (e) {
            throw 'Something went wrong';
          }
        }
      },
    );
  }

  static Future<void> registerListeners(final context) async {

    await terminatedStateNotificationHandler();

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);

    await foregroundNotificationHandler();
    await onTapNotificationHandler();
  }

  static void disposeListeners() {
    ChatNotificationsUtils.dispose();

    onMessageOpen.cancel();
    foregroundStream.cancel();
  }
}
