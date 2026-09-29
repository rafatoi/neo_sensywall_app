import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neo_sensywall_app/src/core/assets/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('asset manifest records the complete Android inventory', () async {
    final contents = await rootBundle.loadString(AppAssets.assetManifest);
    final manifest = jsonDecode(contents) as Map<String, Object?>;
    final assets = manifest['assets']! as List<Object?>;

    expect(manifest['schemaVersion'], 1);
    expect(manifest['assetCount'], 61);
    expect(assets, hasLength(61));
    expect(AppAssets.allSvg, hasLength(42));

    for (final entry in assets.cast<Map<String, Object?>>()) {
      expect(entry['sourceSha256'], matches(RegExp(r'^[a-f0-9]{64}$')));
      expect(entry['targetSha256'], matches(RegExp(r'^[a-f0-9]{64}$')));
    }
  });

  testWidgets('all converted VectorDrawables render as SVG', (tester) async {
    for (final asset in AppAssets.allSvg) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 96,
              child: SvgPicture.asset(asset),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: asset);
    }
  });

  test('copied media assets are available in the Flutter bundle', () async {
    const copiedMedia = <String>[
      AppAssets.sensyWallDevice,
      AppAssets.darwin,
      AppAssets.bluetoothAnimation,
      AppAssets.bluetoothOffAnimation,
      AppAssets.connectionAudio,
      AppAssets.disconnectionAudio,
    ];

    for (final asset in copiedMedia) {
      final bytes = await rootBundle.load(asset);
      expect(bytes.lengthInBytes, greaterThan(0), reason: asset);
    }
  });
}
