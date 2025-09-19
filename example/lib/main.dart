import 'package:flutter/material.dart';
import 'package:context_show/context_show.dart';

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          ElevatedButton(
            child: Text('Show a blue toast from the top left corner'),
            onPressed: () => context.show(
              (overlay) => Toast.blue(overlay.close),
              alignment: Alignment.topLeft,
            ),
          ),
          ElevatedButton(
            child: Text('Show a red toast from the bottom for 1 minute'),
            onPressed: () => context.show(
              (overlay) => Toast.red(overlay.close),
              alignment: Alignment.bottomCenter,
              duration: Duration(minutes: 1),
            ),
          ),
          ElevatedButton(
            child: Text(
              'Show a green toast in the center on a yellowish background',
            ),
            onPressed: () => context.show(
              (overlay) => Toast.green(overlay.close),
              alignment: Alignment.center,
              fullScreen: true,
              background: (_) => Container(color: Colors.yellow.withAlpha(100)),
            ),
          ),
          ElevatedButton(
            child: Text(
              'Show Flutter logo in the center with a rotation animation, on a dimmed, dismissible background',
            ),
            onPressed: () => context.show(
              (_) => FlutterLogo(size: 200),
              duration: Duration.zero,
              dismissible: true,
              alignment: Alignment.center,
              background: (_) => Container(color: Colors.black.withAlpha(100)),
              transition: TransitionBuilders.rotation,
            ),
          ),
        ],
      ),
    ),
  );
}

class Toast extends StatelessWidget {
  const Toast({required this.color, required this.onClose, super.key});

  const Toast.blue(VoidCallback onClose, {Key? key})
    : this(onClose: onClose, key: key, color: Colors.blue);

  const Toast.red(VoidCallback onClose, {Key? key})
    : this(onClose: onClose, key: key, color: Colors.red);

  const Toast.green(VoidCallback onClose, {Key? key})
    : this(onClose: onClose, key: key, color: Colors.green);

  final VoidCallback onClose;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          const Text('My custom toast', style: TextStyle(color: Colors.white)),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
            color: Colors.white,
          ),
        ],
      ),
    ),
  );
}
