import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenu/domain/pet.dart';
import 'package:zenu/domain/pet_profile.dart';
import 'package:zenu/ui/pet/pet_painter.dart';

/// Every mood, colour, pattern, and accessory paints without throwing.
/// Set PET_SNAPSHOT_DIR to also write PNGs for eyeballing the art.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final snapshotDir = Platform.environment['PET_SNAPSHOT_DIR'];

  Future<void> render(String name, PetPainter painter) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final h = PetPainter.designHeight.ceil();
    canvas.drawRect(Rect.fromLTWH(0, 0, 200, h.toDouble()),
        Paint()..color = const Color(0xFFF2F6F4));
    painter.paint(canvas, Size(200, h.toDouble()));
    final image = await recorder.endRecording().toImage(200, h);
    if (snapshotDir != null) {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('$snapshotDir/$name.png').writeAsBytes(
          bytes!.buffer.asUint8List());
    }
  }

  test('all moods x species, at several idle phases', () async {
    for (final species in PetSpecies.values) {
      for (final mood in PetMood.values) {
        for (final t in [0.0, 0.31, 0.62, 0.97]) {
          await render(
            '${species.name}_${mood.name}_$t',
            PetPainter(
              profile: PetProfile(species: species),
              mood: mood,
              t: t,
            ),
          );
        }
      }
    }
  });

  test('all colours and patterns', () async {
    for (final color in PetColors.palette) {
      for (final pattern in PetPattern.values) {
        await render(
          'look_${color.id}_${pattern.name}',
          PetPainter(
            profile: PetProfile(
              species: PetSpecies.pip,
              colorId: color.id,
              pattern: pattern,
            ),
            mood: PetMood.content,
            t: 0.1,
          ),
        );
      }
    }
  });

  test('every cosmetic, alone and the tap reaction', () async {
    for (final cosmetic in Cosmetics.catalog) {
      await render(
        'wear_${cosmetic.id}',
        PetPainter(
          profile: PetProfile(
            species: PetSpecies.luma,
            worn: {cosmetic.slot: cosmetic.id},
          ),
          mood: PetMood.content,
          t: 0.2,
        ),
      );
    }
    await render(
      'react_happy',
      PetPainter(
        profile: const PetProfile(
          species: PetSpecies.miro,
          worn: {
            CosmeticSlot.head: 'topHat',
            CosmeticSlot.face: 'roundGlasses',
            CosmeticSlot.neck: 'bowTie',
            CosmeticSlot.charm: 'balloon',
          },
        ),
        mood: PetMood.content,
        t: 0.2,
        react: 0.5,
        happy: true,
      ),
    );
  });
}
