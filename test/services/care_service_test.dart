import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenu/data/app_store.dart';
import 'package:zenu/domain/pet.dart';
import 'package:zenu/services/care_service.dart';
import 'package:zenu/services/clock.dart';

class FixedClock extends Clock {
  DateTime current;

  FixedClock(this.current);

  @override
  DateTime now() => current;

  void advance(Duration d) => current = current.add(d);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FixedClock clock;

  Future<CareService> makeService() async {
    final store = AppStore(await SharedPreferences.getInstance());
    return CareService.create(store: store, clock: clock);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    clock = FixedClock(DateTime(2026, 9, 1, 9, 0));
  });

  test('startSession anchors every activity at now and persists running',
      () async {
    final care = await makeService();
    await care.startSession();

    expect(care.running, isTrue);
    for (final activity in care.state.activities) {
      expect(care.state.lastDoneMs[activity.id], clock.nowMs());
      expect(care.needFraction(activity), 0.0);
    }

    // The running session survives a full service restart (reboot-safe).
    final revived = await makeService();
    expect(revived.running, isTrue);
    expect(revived.state.lastDoneMs['water'], clock.nowMs());
  });

  test('needs grow with wall clock and the pet voices the worst one',
      () async {
    final care = await makeService();
    await care.startSession();

    clock.advance(const Duration(minutes: 25));
    final water =
        care.state.activities.firstWhere((a) => a.id == 'water');
    final eyeRest =
        care.state.activities.firstWhere((a) => a.id == 'eyeRest');

    // eyeRest (20m) is overdue, water (30m) not yet.
    expect(care.isOverdue(eyeRest), isTrue);
    expect(care.isOverdue(water), isFalse);
    expect(care.mood(), PetMood.tiredEyes);
    expect(care.focusActivity()!.id, 'eyeRest');
  });

  test('logCare records the event, resets the need, and earns sparks',
      () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 25));

    await care.logCare('eyeRest');

    expect(care.state.events.length, 1);
    expect(care.state.game.sparks, 5);
    expect(care.mood(), PetMood.content);
    final eyeRest =
        care.state.activities.firstWhere((a) => a.id == 'eyeRest');
    expect(care.needFraction(eyeRest), 0.0);
  });

  test('early logging works — no waiting for the timer', () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 5));

    await care.logCare('water', qty: 300);

    expect(care.state.events.single.qty, 300);
    expect(care.todayQty('water'), 300);
    expect(care.state.lastDoneMs['water'], clock.nowMs());
  });

  test('snooze pushes the due time out and clears on completion', () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 21));

    final eyeRest =
        care.state.activities.firstWhere((a) => a.id == 'eyeRest');
    expect(care.isOverdue(eyeRest), isTrue);

    await care.snooze('eyeRest');
    expect(care.isOverdue(eyeRest), isFalse);
    expect(care.mood(), PetMood.content);

    await care.logCare('eyeRest');
    expect(care.state.snoozeUntilMs.containsKey('eyeRest'), isFalse);
  });

  test('rapid-fire logging cannot farm sparks (quarter-interval gate)',
      () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 30));
    await care.logCare('water');
    expect(care.state.game.sparks, 5);

    // Ten instant re-taps: events log fine, sparks don't accumulate.
    for (var i = 0; i < 10; i++) {
      await care.logCare('water');
    }
    expect(care.state.events.length, 11);
    expect(care.state.game.sparks, 5);
  });

  test('wardrobe: buying deducts sparks, wearing toggles, no debt possible',
      () async {
    final care = await makeService();
    await care.startSession();
    for (var i = 0; i < 10; i++) {
      clock.advance(const Duration(minutes: 30));
      await care.logCare('water');
    }
    expect(care.state.game.sparks, 50);

    expect(await care.buyCosmetic('cozyScarf'), isTrue); // costs 40
    expect(care.state.game.sparks, 10);
    expect(await care.buyCosmetic('starCharm'), isFalse); // costs 150
    expect(care.state.game.sparks, 10);

    await care.wearCosmetic('cozyScarf');
    expect(care.state.game.worn[CosmeticSlot.neck], 'cozyScarf');
    await care.wearCosmetic('cozyScarf');
    expect(care.state.game.worn.containsKey(CosmeticSlot.neck), isFalse);
  });

  test('pauseSession keeps anchors so nothing resets on resume', () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 10));
    final anchor = care.state.lastDoneMs['water'];

    await care.pauseSession();
    expect(care.mood(), PetMood.resting);
    expect(care.state.lastDoneMs['water'], anchor);
  });

  test('clearAllData returns to a fresh, un-onboarded state', () async {
    final care = await makeService();
    await care.choosePet(PetSpecies.luma);
    await care.startSession();
    await care.logCare('water');

    await care.clearAllData();

    expect(care.state.game.onboarded, isFalse);
    expect(care.state.events, isEmpty);
    expect(care.running, isFalse);
  });
}
