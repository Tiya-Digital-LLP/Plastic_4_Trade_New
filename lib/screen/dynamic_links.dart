import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<String> createDynamicLink(
    String url, String targetScreen, String data) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://plastic4trade.page.link',
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

  try {
    // Generate a short dynamic link
    final ShortDynamicLink shortLink =
        // ignore: deprecated_member_use
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);

    return shortLink.shortUrl.toString();
  } catch (e) {
    throw Exception("Failed to create dynamic link: $e");
  }
}
