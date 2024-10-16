import 'package:flutter/material.dart';

class SingleActionCard extends StatelessWidget {
  const SingleActionCard({
    super.key,
    required this.children,
    String? actionName,
    void Function()? action,
  })  : _actionName = actionName,
        _action = action;

  static const _menuBtnPadding = EdgeInsets.all(16.0);
  static const _menuBorderRadii = Radius.circular(8.0);
  final List<Widget> children;
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
            if (name != null)
              Container(
                padding: _menuBtnPadding,
                decoration: BoxDecoration(
                  color: action != null
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: _menuBorderRadii,
                    bottomRight: _menuBorderRadii,
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
