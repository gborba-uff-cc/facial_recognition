import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceholderScreen extends StatelessWidget {
  final String displayText;
  final String nextScreen;

  const PlaceholderScreen({super.key, this.displayText = '', this.nextScreen = ''});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [], title: const Text('AppBar')),
      // drawer: const Drawer(child: Text('LeftDrawer')),
      body: Center(
        child: Text(displayText),
      ),
      endDrawer: const Drawer(child: Text('EndDrawer')),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (nextScreen.isNotEmpty) {
              GoRouter.of(context).go(nextScreen);
            }
          },
          label: const Text('FAB Next Screen')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.thumb_down), label: 'BNBI1'),
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'BNBI2'),
        ],
      ),
    );
  }
}
