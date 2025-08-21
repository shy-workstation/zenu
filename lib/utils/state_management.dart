import 'package:flutter/material.dart';

// Provider and Consumer classes for state management
class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({super.key, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    final inheritedNotifier =
        context.findAncestorWidgetOfExactType<_InheritedNotifier<T>>();
    if (inheritedNotifier == null || inheritedNotifier.notifier == null) {
      throw Exception('Consumer used without Provider');
    }

    return ListenableBuilder(
      listenable: inheritedNotifier.notifier!,
      builder: (context, child) {
        final notifier = inheritedNotifier.notifier!;
        return builder(context, notifier, this.child);
      },
      child: child,
    );
  }
}

class Provider<T extends ChangeNotifier> extends StatelessWidget {
  final T value;
  final Widget child;

  const Provider({super.key, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return _InheritedNotifier<T>(notifier: value, child: child);
  }

  static T of<T extends ChangeNotifier>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inheritedNotifier =
        listen
            ? context
                .dependOnInheritedWidgetOfExactType<_InheritedNotifier<T>>()
            : context.findAncestorWidgetOfExactType<_InheritedNotifier<T>>();

    if (inheritedNotifier == null || inheritedNotifier.notifier == null) {
      throw Exception('Provider.of<$T> used without Provider<$T>');
    }

    return inheritedNotifier.notifier!;
  }
}

class _InheritedNotifier<T extends ChangeNotifier>
    extends InheritedNotifier<T> {
  const _InheritedNotifier({
    super.key,
    required super.notifier,
    required super.child,
  });
}
