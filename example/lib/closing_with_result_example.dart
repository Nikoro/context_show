import 'package:context_show/context_show.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Closing with Result Example')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text('Show'),
              onPressed: () async {
                // Show overlay and await the result
                final result = await context.show<String>(
                  (_) => Container(
                      padding: EdgeInsets.all(20),
                      color: Colors.orange[100],
                      child: const Text('Banner')),
                  duration: Duration.zero,
                );
                debugPrint('$result'); // user_confirmed
              },
            ),
            ElevatedButton(
              child: const Text('Close with Result'),
              onPressed: () {
                // Close overlay from a different callback and return a string
                context.close('user_confirmed');
              },
            ),
          ],
        ),
      ),
    );
  }
}
