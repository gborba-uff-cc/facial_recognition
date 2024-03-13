import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, this.nextScreens = const []});

  final List<String> nextScreens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: const [], title: const Text('AppBar')),
      body: ListView.builder(
        itemBuilder: (buildContext, i) => OutlinedButton(
          onPressed: () => GoRouter.of(context).go(nextScreens[i]),
          child: Text(
            'go ${nextScreens[i]}',
            maxLines: 1,
          ),
        ),
        itemCount: nextScreens.length,
      ),
      endDrawer: const Drawer(child: Text('EndDrawer')),
      floatingActionButton: const FloatingActionButton.extended(
          onPressed: null,
          label: Text('FAB'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.thumb_down), label: 'BNBI1'),
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'BNBI2'),
        ],
      ),
    );
  }
}
