import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenu/data/app_store.dart';
import 'package:zenu/domain/zenu_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppStore> storeWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return AppStore(await SharedPreferences.getInstance());
  }

  group('AppStore', () {
    test('fresh install loads defaults', () async {
      final store = await storeWith({});
      final result = store.load();
      expect(result.state.activities.length, 5);
      expect(result.state.running, isFalse);
      expect(result.migratedFromV1, isFalse);
      expect(result.recoveredFromBackup, isFalse);
    });

    test('round-trips state, including running session', () async {
      final store = await storeWith({});
      final state = ZenuState()
        ..running = true
        ..sessionStartMs = 123456
        ..lastDoneMs['water'] = 111;
      expect(await store.save(state), isTrue);

      final reloaded = store.load().state;
      expect(reloaded.running, isTrue);
      expect(reloaded.sessionStartMs, 123456);
      expect(reloaded.lastDoneMs['water'], 111);
    });

    test('corrupt blob: preserved for forensics, backup restored, '
        'original never overwritten by the load', () async {
      final store = await storeWith({});
      final good = ZenuState()..lastDoneMs['water'] = 42;
      await store.save(good);
      await store.save(good); // second save populates the backup slot

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppStore.stateKey, '{"schemaVersion": 2, brok');

      final result = store.load();
      expect(result.recoveredFromBackup, isTrue);
      expect(result.state.lastDoneMs['water'], 42);
      // Forensic copy kept; primary untouched by the load itself.
      expect(prefs.getString(AppStore.corruptKey), contains('brok'));
      expect(prefs.getString(AppStore.stateKey), contains('brok'));
    });

    test('one malformed event does not take down the rest', () async {
      final store = await storeWith({});
      final raw = jsonEncode({
        'schemaVersion': 2,
        'events': [
          {'a': 'water', 't': 1000, 'q': 2},
          {'bogus': true},
          {'a': 'move', 't': 2000},
        ],
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppStore.stateKey, raw);

      final state = store.load().state;
      expect(state.events.length, 2);
      expect(state.events.first.activityId, 'water');
    });

    test('clearAll wipes v2 keys and the legacy blob', () async {
      final store = await storeWith({AppStore.legacyKey: '[]'});
      await store.save(ZenuState());
      await store.clearAll();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppStore.stateKey), isNull);
      expect(prefs.getString(AppStore.legacyKey), isNull);
    });
  });
}
