import 'dart:math';

import 'package:context_show/context_show.dart';
import 'package:flutter/material.dart';

final _random = Random();

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          ElevatedButton(
            child: Text('Show Banner with id: 1'),
            onPressed: () => Banner.show(context, '1'),
          ),
          ElevatedButton(
            child: Text('Show Banner with id: 2'),
            onPressed: () => Banner.show(context, '2'),
          ),
          ElevatedButton(
            child: Text('Close all with id: 1'),
            onPressed: () => context.close((overlays) => overlays.byId('1')),
          ),
          ElevatedButton(
            child: Text('Close all with id: 2'),
            onPressed: () => context.close(Overlays.all(id: '2')),
          ),
          ElevatedButton(
            child: Text('Close last'),
            onPressed: () => context.close(),
          ),
          ElevatedButton(
            child: Text('Close first'),
            onPressed: () => context.close((overlays) => overlays.first),
          ),
          ElevatedButton(
            child: Text('Close first'),
            onPressed: () => context.close(Overlays.first()),
          ),
          ElevatedButton(
            child: Text('Close all'),
            onPressed: () => context.close(Overlays.all()),
          ),
        ],
      ),
    ),
  );
}

class Banner<T> {
  Banner._();

  static Future<T?> show<T>(BuildContext context, String id) {
    final randomColor = Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
    final randomAlignment = Alignment(
      _random.nextDouble() * 2 - 1,
      _random.nextDouble() * 2 - 1,
    );
    return context.show<T>(
      (overlay) => Padding(
        padding: EdgeInsets.all(50),
        child: ColoredBox(
          color: randomColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Banner $id', style: TextStyle(color: Colors.white)),
              IconButton(
                onPressed: overlay.close,
                color: Colors.white,
                icon: Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
      id: id,
      duration: Duration.zero,
      alignment: randomAlignment,
    );
  }
}
