import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../auth/auth_user_services.dart';
import '../main.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/chat/user_chat_list_screen.dart';
import 'common.dart';
import 'constant.dart';

Future<void> initializeOneSignal() async {
  OneSignal.initialize(getStringAsync(ONESIGNAL_API_KEY));
  OneSignal.Notifications.requestPermission(true);
  OneSignal.User.pushSubscription.optIn();

  OneSignal.Notifications.addClickListener((notification) async {
    try {
      if (notification.notification.additionalData == null) return;

      if (notification.notification.additionalData!.containsKey('id')) {
        String? notId = notification.notification.additionalData!["id"].toString();
        if (notId.validate().isNotEmpty) {
          navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: notId.toString().toInt())));
        }
      } else if (notification.notification.additionalData!.containsKey('sender_uid')) {
        String? notId = notification.notification.additionalData!["sender_uid"];
        if (notId.validate().isNotEmpty) {
          navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ChatListScreen()));
        }
      }
    } catch (e) {
      throw errorSomethingWentWrong;
    }
  });

  saveOneSignalPlayerId();
}

Future<void> saveOneSignalPlayerId() async {
  if (appStore.isLoggedIn) {
    await OneSignal.login(appStore.userId.validate().toString()).then((value) {
      if (isUserTypeHandyman) {
        OneSignal.User.addTagWithKey(ONESIGNAL_TAG_KEY, ONESIGNAL_TAG_HANDYMAN_VALUE);
      } else if (isUserTypeProvider) {
        OneSignal.User.addTagWithKey(ONESIGNAL_TAG_KEY, ONESIGNAL_TAG_PROVIDER_VALUE);
      }

      if (OneSignal.User.pushSubscription.id.validate().isNotEmpty) {
        appStore.setPlayerId(OneSignal.User.pushSubscription.id.validate());
        updatePlayerId(playerId: OneSignal.User.pushSubscription.id.validate());
      }
    }).catchError((e) {
      log('Error saving subscription id - $e');
    });
  }
}
