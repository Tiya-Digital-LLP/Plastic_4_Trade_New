import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<String> dynamicShareApp(
    String url, String targetScreen, String data) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://plastic4trade.page.link/plastic4trade',
    link: Uri.parse('$url?screen=$targetScreen&data=$data'),
    androidParameters: AndroidParameters(
      packageName: 'com.p4t.plastic4trade',
      minimumVersion: 1,
    ),
    iosParameters: IOSParameters(
      bundleId: 'com.p4t.plastic4trade',
      minimumVersion: '1.0.1',
    ),
  );

  final Uri dynamicUrl =
      // ignore: deprecated_member_use
      await FirebaseDynamicLinks.instance.buildLink(parameters);
  return dynamicUrl.toString();
}
