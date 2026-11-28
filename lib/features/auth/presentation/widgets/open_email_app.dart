import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's email app (A7, A8).
///
/// Android has no link to the inbox itself, so this opens the email app's
/// compose screen (`mailto:`), from which the inbox is one tap away.
Future<void> openEmailApp() async {
  await launchUrl(Uri(scheme: 'mailto'));
}
