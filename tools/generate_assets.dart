// Simple script to generate placeholder PNG assets from base64 strings
import 'dart:convert';
import 'dart:io';

void main() {
  final map = {
    'onboarding1.png':
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8AABfUB/6k3bQAAAABJRU5ErkJggg==',
    'onboarding2.png':
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8AABfUB/6k3bQAAAABJRU5ErkJggg==',
    'onboarding3.png':
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8z8AABfUB/6k3bQAAAABJRU5ErkJggg==',
  };

  final dir = Directory('assets/images');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('Created directory: ${dir.path}');
  }

  map.forEach((name, b64) {
    final bytes = base64.decode(b64);
    final file = File('${dir.path}/$name');
    file.writeAsBytesSync(bytes);
    print('Wrote ${file.path} (${bytes.length} bytes)');
  });
  print('Done.');
}
