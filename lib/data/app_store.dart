import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/zenu_state.dart';
import 'legacy_migration.dart';

class LoadResult {
  final ZenuState state;

  /// True when the primary blob failed to parse. The raw blob is kept
  /// under [AppStore.corruptKey] and the state comes from the last good
  /// backup (or defaults) — the user's data is never overwritten by a
  /// failed load.
  final bool recoveredFromBackup;
  final bool migratedFromV1;

  const LoadResult(
    this.state, {
    this.recoveredFromBackup = false,
    this.migratedFromV1 = false,
  });
}

/// Versioned persistence with non-destructive loads:
/// - every successful save refreshes a last-known-good backup,
/// - a corrupt primary blob is preserved for forensics and the backup is
///   loaded instead,
/// - the legacy v1 blob is read once for migration and left untouched.
class AppStore {
  static const stateKey = 'zenu.v2.state';
  static const backupKey = 'zenu.v2.state.backup';
  static const corruptKey = 'zenu.v2.state.corrupt';
  static const legacyKey = 'reminders';

  final SharedPreferences _prefs;

  AppStore(this._prefs);

  static Future<AppStore> open() async =>
      AppStore(await SharedPreferences.getInstance());

  LoadResult load() {
    final raw = _prefs.getString(stateKey);
    if (raw == null) {
      final legacy = _prefs.getString(legacyKey);
      if (legacy != null) {
        final migrated = LegacyMigration.migrate(legacy);
        if (migrated != null) {
          return LoadResult(migrated, migratedFromV1: true);
        }
      }
      return LoadResult(ZenuState());
    }

    final parsed = _tryParse(raw);
    if (parsed != null) return LoadResult(parsed);

    // Primary blob is corrupt: preserve it, then fall back to the backup.
    _prefs.setString(corruptKey, raw);
    final backupRaw = _prefs.getString(backupKey);
    if (backupRaw != null) {
      final backup = _tryParse(backupRaw);
      if (backup != null) {
        return LoadResult(backup, recoveredFromBackup: true);
      }
    }
    return LoadResult(ZenuState(), recoveredFromBackup: true);
  }

  ZenuState? _tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return ZenuState.fromJson(decoded);
    } catch (e) {
      debugPrint('AppStore: failed to parse state: $e');
      return null;
    }
  }

  Future<bool> save(ZenuState state) async {
    try {
      final encoded = jsonEncode(state.toJson());
      final previous = _prefs.getString(stateKey);
      final ok = await _prefs.setString(stateKey, encoded);
      if (ok) {
        // The backup slot must always hold a known-GOOD generation: the
        // previous blob when it parses, else the state just written —
        // never a corrupt blob that happened to sit in the primary slot.
        final backupCandidate =
            (previous != null && _tryParse(previous) != null)
                ? previous
                : encoded;
        if (_prefs.getString(backupKey) != backupCandidate) {
          await _prefs.setString(backupKey, backupCandidate);
        }
      }
      return ok;
    } catch (e) {
      debugPrint('AppStore: save failed: $e');
      return false;
    }
  }

  String? exportJson() => _prefs.getString(stateKey);

  Future<void> clearAll() async {
    await _prefs.remove(stateKey);
    await _prefs.remove(backupKey);
    await _prefs.remove(corruptKey);
    await _prefs.remove(legacyKey);
  }
}
