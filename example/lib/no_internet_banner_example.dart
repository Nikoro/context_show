import 'dart:async';

import 'package:context_show/context_show.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        Stream.periodic(Duration(seconds: 5), (count) => count.isEven).listen((
      hasNoInternet,
    ) {
      if (!mounted) return;

      if (hasNoInternet) {
        NoInternetBanner.show(context);
      } else {
        NoInternetBanner.close(context);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold();
}

class NoInternetBanner {
  NoInternetBanner._();

  static const _id = 'some_no_internet_banner_id';

  static Future<void> show<T>(BuildContext context) => context.show(
        id: _id,
        duration: Duration.zero,
        safeArea: false,
        alignment: Alignment.bottomCenter,
        (_) => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30),
          color: Colors.yellow,
          child: Text('No internet', textAlign: TextAlign.center),
        ),
      );

  static void close(BuildContext context) =>
      context.close((overlays) => overlays.byId(_id));
}
