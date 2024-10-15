import 'package:flutter/material.dart';

class DefaultAppScaffold extends StatelessWidget {
  const DefaultAppScaffold({
    super.key,
    Widget? body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  })  : _body = body,
        _appBar = appBar,
        _bottomNavigationBar = bottomNavigationBar;

  final PreferredSizeWidget? _appBar;
  final Widget? _body;
  final Widget? _bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              child: _body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _bottomNavigationBar,
    );
  }
}
