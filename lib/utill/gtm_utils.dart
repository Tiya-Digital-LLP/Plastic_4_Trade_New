import 'package:flutter/services.dart';
import 'package:gtm/gtm.dart';

class GtmUtil {
  static Future<void> initGtm() async {
    try {
      final gtm = await Gtm.instance;
      gtm.setCustomTagTypes([
        CustomTagType(
          'amplitude',
          handler: (eventName, parameters) {
            print('amplitude!');
            print(eventName);
            print(parameters);
          },
        ),
      ]);
    } on PlatformException {
      print('exception occurred during GTM initialization!');
    }
  }

  static Future<void> logScreenView(String eventName, String screenName) async {
    try {
      final gtm = await Gtm.instance;
      gtm.push(
        eventName,
        parameters: {
          'screen_name': screenName,
        },
      );
    } on PlatformException {
      print('exception occurred while logging screen view!');
    }
  }
}
