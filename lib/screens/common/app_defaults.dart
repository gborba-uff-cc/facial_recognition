import 'package:flutter/material.dart';

final _appBarPreferredSize = AppBar().preferredSize;

class AppDefaultAppBar extends StatelessWidget implements PreferredSizeWidget{
  const AppDefaultAppBar({
    super.key,
    required String title,
    List<Widget>? actions,
  }): _title = title,
      _actions = actions;

  final String _title;
  final List<Widget>? _actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        _title,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
        overflow: TextOverflow.fade,
      ),
      actions: _actions,
    );
  }

  @override
  Size get preferredSize => _appBarPreferredSize;
}

class AppDefaultScaffold extends StatelessWidget {
  const AppDefaultScaffold({
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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: _body,
      ),
      bottomNavigationBar: _bottomNavigationBar,
    );
  }
}

class AppDefaultMenuScaffold extends StatelessWidget {
  const AppDefaultMenuScaffold({
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

class AppDefaultButton extends StatelessWidget {
  const AppDefaultButton({
    super.key,
    this.onTap,
    required this.child,
  });

  final void Function()? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme:
            Theme.of(context).textTheme.copyWith().apply(fontSizeFactor: 1.2),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

class AppDefaultMenuList extends StatelessWidget {

  factory AppDefaultMenuList({
    Key? key,
    required List<Widget> children,
  }) {
    final List<Widget> aux = [];
    if (children.length < 2) {
      aux.addAll(children);
    }
    else {
      for (int i=0; i<children.length; i++) {
        aux.add(children[i]);
        if (i < children.length-1) {
          aux.add(SizedBox(height: 16.0));
        }
      }
    }
    return AppDefaultMenuList._private(key: key, items: List.unmodifiable(aux),);
}

  const AppDefaultMenuList._private({super.key, required List<Widget> items})
      : _items = items;

  final List<Widget> _items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _items,

    );
  }
}

class AppDefaultMenuTitle extends StatelessWidget {
  const AppDefaultMenuTitle({
    super.key,
    required String title,
  }) : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _title,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
        overflow: TextOverflow.fade,
      ),
    );
  }
}

final _cameraBaseIconSize = 80.0;
final _cameraBackgroundIconColor = Colors.grey.shade300;

class AppDefaultCameraShutter extends StatelessWidget {
  const AppDefaultCameraShutter({
    super.key,
    this.onTap,
  });
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: _cameraBaseIconSize,
        width: _cameraBaseIconSize,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
          color: _cameraBackgroundIconColor,
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Icon(
            Icons.circle_outlined,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class AppDefaultCameraSwitcher extends StatelessWidget {
  const AppDefaultCameraSwitcher({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: _cameraBaseIconSize,
      width: _cameraBaseIconSize,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: _cameraBackgroundIconColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Icon(
                  Icons.cameraswitch_outlined,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
