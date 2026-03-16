import 'package:flutter/material.dart';

/// Build a screen with fake dependencies.
Widget screenBuilder(
  Widget Function() builder, {
  void Function()? init,
  Locale? locale,
}) {
  /* final dependencies = $initializeFakeDependencies(user: user); */
  init?.call(/* dependencies */);

  final builderKey = GlobalKey();
  final widget = builder();

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    locale: locale ?? const Locale('ru'),
    onGenerateTitle: (context) => 'Integration test screen',
    builder: (context, _) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      key: builderKey,
      child: widget,
    ),
  );
}
