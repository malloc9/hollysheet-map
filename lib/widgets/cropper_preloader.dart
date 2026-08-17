/// Image preloader for web platform.
///
/// This library provides web-specific code to properly wait for image loading
/// before the cropper initializes, fixing the race condition in image_cropper_for_web.
library cropper_preloader;

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Pre-loads an image to ensure it's ready before cropper initialization.
///
/// This is the web implementation.
Future<bool> preloadImageForCropper(String src) async {
  if (src.isEmpty) return false;

  final completer = Completer<bool>();

  // Skip if already loaded (data URLs or cached)
  if (src.startsWith('data:') || src.startsWith('blob:')) {
    // For blob URLs, we need to ensure they're loadable
    // Just give a small delay
    await Future.delayed(const Duration(milliseconds: 100));
    completer.complete(true);
    return completer.future;
  }

  final img = html.ImageElement()
    ..style.setProperty('position', 'absolute')
    ..style.setProperty('left', '-9999px')
    ..style.setProperty('top', '-9999px');

  html.document.body?.append(img);

  img.onLoad.listen((_) {
    img.remove();
    if (!completer.isCompleted) completer.complete(true);
  });

  img.onError.listen((_) {
    img.remove();
    if (!completer.isCompleted) completer.complete(false);
  });

  img.src = src;

  // Timeout after 3 seconds
  return completer.future.timeout(
    const Duration(seconds: 3),
    onTimeout: () {
      img.remove();
      return false;
    },
  );
}