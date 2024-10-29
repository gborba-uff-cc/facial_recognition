import 'dart:typed_data';

import 'package:facial_recognition/screens/common/grid_selector.dart';
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

const _cardOptionInnerPadding = EdgeInsets.all(16.0);
const _cardOptionBorderRadius = Radius.circular(8.0);

class AppDefaultSingleOptionCard extends StatelessWidget {
  const AppDefaultSingleOptionCard({
    super.key,
    required this.child,
    String? option,
    void Function()? onOptionTap,
  })  : _actionName = option,
        _action = onOptionTap;

  final Widget child;
  final String? _actionName;
  final void Function()? _action;

  @override
  Widget build(BuildContext context) {
    final name = _actionName;
    final action = _action;
    final bottomBannerTextStyle = Theme.of(context)
        .textTheme
        .copyWith()
        .apply(
          fontSizeFactor: 1.2,
          bodyColor: Theme.of(context).colorScheme.onSecondary,
        )
        .labelLarge;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3.0,
      child: InkWell(
        onTap: action,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            child,
            if (name != null)
              Container(
                padding: _cardOptionInnerPadding,
                decoration: BoxDecoration(
                  color: action != null
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: _cardOptionBorderRadius,
                    bottomRight: _cardOptionBorderRadius,
                  ),
                ),
                child: Center(
                  child: Text(
                    name,
                    style: bottomBannerTextStyle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppDefaultTripleOptionsCard extends StatelessWidget {
  const AppDefaultTripleOptionsCard({
    super.key,
    required this.child,
    required this.leftOption,
    this.centerOption,
    required this.rightOption,
    this.leftOptionColor,
    this.centerOptionColor,
    this.rightOptionColor,
    this.onLeftOptionTap,
    this.onCenterOptionTap,
    this.onRightOptionTap,
  });

  final Widget child;
  final Widget leftOption;
  final Widget? centerOption;
  final Widget rightOption;
  final Color? leftOptionColor;
  final Color? centerOptionColor;
  final Color? rightOptionColor;
  final void Function()? onLeftOptionTap;
  final void Function()? onCenterOptionTap;
  final void Function()? onRightOptionTap;

  @override
  Widget build(BuildContext context) {
    final optionsSpace = 2.0;
    final List<Widget> widgetsForCenterOption = [
      SizedBox(
        width: optionsSpace,
      ),
      Flexible(
        fit: FlexFit.tight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            padding: _cardOptionInnerPadding,
            decoration: BoxDecoration(
              color: onCenterOptionTap != null
                  ? centerOptionColor ?? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
            ),
            child: InkWell(
              onTap: onCenterOptionTap,
              child: centerOption,
            ),
          ),
        ),
      ),
      SizedBox(
        width: optionsSpace,
      ),
    ];
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  padding: _cardOptionInnerPadding,
                  decoration: BoxDecoration(
                    color: onLeftOptionTap != null
                        ? leftOptionColor ?? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: _cardOptionBorderRadius,
                    ),
                  ),
                  child: InkWell(
                    onTap: onLeftOptionTap,
                    child: leftOption,
                  ),
                ),
              ),
              if (centerOption != null)
                ...widgetsForCenterOption,
              if (centerOption == null)
                SizedBox(width: optionsSpace),
              Flexible(
                fit: FlexFit.tight,
                child: Container(
                  padding: _cardOptionInnerPadding,
                  decoration: BoxDecoration(
                    color: onRightOptionTap != null
                        ? rightOptionColor ?? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                      bottomRight: _cardOptionBorderRadius,
                    ),
                  ),
                  child: InkWell(
                    onTap: onRightOptionTap,
                    child: rightOption,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppDefaultTotenIdentificationCard extends StatelessWidget {
  const AppDefaultTotenIdentificationCard({
    super.key,
    required this.faceJpg,
    required this.name,
    required this.registration,
    this.onAccept,
    this.onRevise,
    this.onDiscard,
  });

  final Uint8List faceJpg;
  final String name;
  final String registration;
  final void Function()? onAccept;
  final void Function()? onRevise;
  final void Function()? onDiscard;

  @override
  Widget build(BuildContext context) {
    final optionsTextStyle = Theme.of(context).textTheme.titleMedium?.apply(
          // fontSizeFactor: 1.2,
          color: Theme.of(context).colorScheme.onSecondary,
        );
    return AppDefaultTripleOptionsCard(
      leftOption: Center(child: Text('Descartar',style: optionsTextStyle,softWrap: false,),),
      centerOption: Center(child: Text('Corrigir',style: optionsTextStyle,softWrap: false,),),
      rightOption: Center(child: Text('Aceitar',style: optionsTextStyle,softWrap: false,),),
      leftOptionColor: Colors.red.shade600,
      rightOptionColor: Colors.green.shade600,
      onLeftOptionTap: onDiscard,
      onCenterOptionTap: onRevise,
      onRightOptionTap: onAccept,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.memory(
                  faceJpg,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.person),
                ),
              ),
            ),
            SizedBox(width: 2.0,),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Column(
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    registration,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
