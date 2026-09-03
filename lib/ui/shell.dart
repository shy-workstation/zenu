import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/care_service.dart';
import 'home/pet_home_screen.dart';
import 'onboarding/choose_pet_screen.dart';

/// One screen: the pet. Everything else (style, journey, settings) lives
/// behind the gear in the corner, so the home stays calm and option-free.
class ZenuShell extends StatelessWidget {
  const ZenuShell({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarded =
        context.select<CareService, bool>((care) => care.state.pet.onboarded);
    if (!onboarded) return const ChoosePetScreen();
    return const Scaffold(body: PetHomeScreen());
  }
}
