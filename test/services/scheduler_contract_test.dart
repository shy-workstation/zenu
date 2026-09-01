import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenu/data/app_store.dart';
import 'package:zenu/domain/care_activity.dart';
import 'package:zenu/domain/zenu_state.dart';
import 'package:zenu/services/care_service.dart';
import 'package:zenu/services/clock.dart';
import 'package:zenu/services/notification_scheduler.dart';
import 'package:zenu/services/notification_texts.dart';

/// Records every resync so the "every mutation re-derives the OS queue"
/// invariant is actually asserted, not assumed.
class FakeScheduler implements NotificationScheduler {
  final List<bool> resyncRunningStates = [];
  int showNowCalls = 0;

  @override
  Future<void> resync(ZenuState state, NotificationTexts texts) async {
    resyncRunningStates.add(state.running);
  }

  @override
  Future<void> showNow(CareActivity activity, NotificationTexts texts) async {
    showNowCalls++;
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> notificationsEnabled() async => true;
}

NotificationResponse _response({String? payload, String? actionId}) =>
    NotificationResponse(
      notificationResponseType:
          NotificationResponseType.selectedNotificationAction,
      payload: payload,
      actionId: actionId,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseCareResponse (per-platform contracts)', () {
    test('Android tap: payload only, null actionId', () {
      final r = parseCareResponse(_response(payload: 'care:water'));
      expect(r, (activityId: 'water', action: 'tap'));
    });

    test('Android button: payload + distinct actionId', () {
      final r = parseCareResponse(
          _response(payload: 'care:water', actionId: actionDoneId));
      expect(r, (activityId: 'water', action: actionDoneId));
    });

    test('Windows body tap: actionId mirrors the payload', () {
      final r = parseCareResponse(
          _response(payload: 'care:water', actionId: 'care:water'));
      expect(r, (activityId: 'water', action: 'tap'));
    });

    test('Windows button: composite arguments arrive as payload AND actionId',
        () {
      final composite = 'care:eyeRest|$actionSnoozeId';
      final r = parseCareResponse(
          _response(payload: composite, actionId: composite));
      expect(r, (activityId: 'eyeRest', action: actionSnoozeId));
    });

    test('foreign payloads are ignored', () {
      expect(parseCareResponse(_response(payload: 'zenu_done')), isNull);
      expect(parseCareResponse(_response(payload: null)), isNull);
    });
  });

  test('notification id slots are stable across versions (golden)', () {
    expect(Activities.notificationSlot('water'), 0);
    expect(Activities.notificationSlot('eyeRest'), 1);
    expect(Activities.notificationSlot('move'), 2);
    expect(Activities.notificationSlot('stretch'), 3);
    expect(Activities.notificationSlot('strength'), 4);
  });

  group('CareService x scheduler invariants', () {
    late FakeScheduler scheduler;

    Future<CareService> makeService() async {
      SharedPreferences.setMockInitialValues({});
      scheduler = FakeScheduler();
      final store = AppStore(await SharedPreferences.getInstance());
      return CareService.create(
        store: store,
        scheduler: scheduler,
        clock: const Clock(),
      );
    }

    test('every mutation resyncs the OS queue', () async {
      final care = await makeService();
      final baseline = scheduler.resyncRunningStates.length;

      await care.startSession();
      await care.logCare('water');
      await care.snooze('eyeRest');
      await care.setActivityInterval('move', const Duration(minutes: 50));
      await care.pauseSession();

      expect(scheduler.resyncRunningStates.length, baseline + 5);
      // The pause resync must see running=false so it clears the queue.
      expect(scheduler.resyncRunningStates.last, isFalse);
    });

    test('clearAllData disarms the queue with a fresh, stopped state',
        () async {
      final care = await makeService();
      await care.startSession();
      final baseline = scheduler.resyncRunningStates.length;

      await care.clearAllData();

      expect(scheduler.resyncRunningStates.length, baseline + 1);
      expect(scheduler.resyncRunningStates.last, isFalse);
    });
  });
}
