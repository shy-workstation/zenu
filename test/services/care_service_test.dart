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

  test('logCare records the event and resets the need', () async {
    final care = await makeService();
    await care.startSession();
    clock.advance(const Duration(minutes: 25));

    await care.logCare('eyeRest');

    expect(care.state.events.length, 1);
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

  test('styling is free: colour, pattern, and cosmetics apply instantly',
      () async {
    final care = await makeService();
    await care.choosePet(PetSpecies.pip);
    expect(care.state.pet.color.id, 'sky');

    await care.setPetColor('rose');
    expect(care.state.pet.color.id, 'rose');
    await care.setPetColor(null);
    expect(care.state.pet.color.id, 'sky');

    await care.setPetPattern(PetPattern.spots);
    expect(care.state.pet.pattern, PetPattern.spots);

    await care.wearCosmetic('cozyScarf');
    expect(care.state.pet.worn[CosmeticSlot.neck], 'cozyScarf');
    await care.wearCosmetic('bowTie');
    expect(care.state.pet.worn[CosmeticSlot.neck], 'bowTie');
    await care.wearCosmetic('bowTie');
    expect(care.state.pet.worn.containsKey(CosmeticSlot.neck), isFalse);

    await care.wearCosmetic('halo');
    await care.clearSlot(CosmeticSlot.head);
    expect(care.state.pet.worn, isEmpty);

    // Survives a restart.
    await care.wearCosmetic('topHat');
    final revived = await makeService();
    expect(revived.state.pet.pattern, PetPattern.spots);
    expect(revived.state.pet.species, PetSpecies.pip);
    expect(revived.state.pet.worn[CosmeticSlot.head], 'topHat');
  });

  test('a pre-release blob with sparks and unknown cosmetics loads cleanly',
      () async {
    SharedPreferences.setMockInitialValues({
      AppStore.stateKey: '{"schemaVersion":2,"game":{"species":"luma",'
          '"sparks":120,"owned":["cozyScarf"],'
          '"worn":{"neck":"cozyScarf","head":"gone"}}}',
    });
    final care = await makeService();
    expect(care.state.pet.species, PetSpecies.luma);
    expect(care.state.pet.worn, {CosmeticSlot.neck: 'cozyScarf'});
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

    expect(care.state.pet.onboarded, isFalse);
    expect(care.state.events, isEmpty);
    expect(care.running, isFalse);
  });
}
