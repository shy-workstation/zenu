import 'package:flutter/material.dart';
import '../models/reminder.dart';

class ReminderTemplateService {
  static const Map<ReminderType, ReminderTemplate> _builtInTemplates = {
    ReminderType.eyeRest: ReminderTemplate(
      name: 'Eye Rest',
      description: 'Look away from your screen',
      icon: Icons.visibility_outlined,
      color: Colors.cyan,
      minQuantity: 10,
      maxQuantity: 120,
      stepSize: 5,
      unit: 'seconds',
      defaultInterval: Duration(minutes: 20),
    ),
    ReminderType.standUp: ReminderTemplate(
      name: 'Stand Up',
      description: 'Get up and move around',
      icon: Icons.accessibility_new,
      color: Colors.orange,
      minQuantity: 1,
      maxQuantity: 15,
      stepSize: 1,
      unit: 'minutes',
      defaultInterval: Duration(minutes: 30),
    ),
    ReminderType.pullUps: ReminderTemplate(
      name: 'Pull Ups',
      description: 'Time for some pull ups!',
      icon: Icons.fitness_center,
      color: Colors.red,
      minQuantity: 1,
      maxQuantity: 20,
      stepSize: 1,
      unit: 'reps',
      defaultInterval: Duration(hours: 2),
    ),
    ReminderType.pushUps: ReminderTemplate(
      name: 'Push Ups',
      description: 'Drop and give me 20!',
      icon: Icons.sports_gymnastics,
      color: Colors.green,
      minQuantity: 1,
      maxQuantity: 50,
      stepSize: 1,
      unit: 'reps',
      defaultInterval: Duration(hours: 2),
    ),
    ReminderType.water: ReminderTemplate(
      name: 'Drink Water',
      description: 'Stay hydrated!',
      icon: Icons.local_drink,
      color: Colors.blue,
      minQuantity: 100,
      maxQuantity: 1000,
      stepSize: 25,
      unit: 'ml',
      defaultInterval: Duration(minutes: 60),
    ),
    ReminderType.stretch: ReminderTemplate(
      name: 'Stretch',
      description: 'Stretch your muscles',
      icon: Icons.self_improvement,
      color: Colors.purple,
      minQuantity: 1,
      maxQuantity: 15,
      stepSize: 1,
      unit: 'minutes',
      defaultInterval: Duration(hours: 1),
    ),
  };

  static List<ReminderTemplate> getBuiltInTemplates() {
    return _builtInTemplates.values.toList();
  }

  static ReminderTemplate? getTemplate(ReminderType type) {
    return _builtInTemplates[type];
  }

  static List<IconData> getAvailableIcons() {
    return [
      // Exercise icons
      Icons.fitness_center,
      Icons.sports_gymnastics,
      Icons.self_improvement,
      Icons.accessibility_new,
      Icons.directions_run,
      Icons.sports_martial_arts,
      Icons.pool,
      Icons.sports_tennis,
      Icons.sports_basketball,
      Icons.sports_soccer,

      // Health icons
      Icons.local_drink,
      Icons.visibility_outlined,
      Icons.healing,
      Icons.favorite,
      Icons.psychology,
      Icons.spa,
      Icons.bedtime,
      Icons.restaurant,
      Icons.medication,
      Icons.medical_services,

      // Time/Activity icons
      Icons.timer,
      Icons.alarm,
      Icons.schedule,
      Icons.watch_later,
      Icons.notification_important,
      Icons.lightbulb_outline,
      Icons.work_outline,
      Icons.home,
      Icons.school,
      Icons.computer,

      // General icons
      Icons.star,
      Icons.check_circle,
      Icons.flag,
      Icons.trending_up,
      Icons.dashboard,
      Icons.emoji_events,
      Icons.celebration,
      Icons.bolt,
      Icons.flash_on,
      Icons.sunny,
    ];
  }

  static List<Color> getAvailableColors() {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
      Colors.grey,
    ];
  }
}
