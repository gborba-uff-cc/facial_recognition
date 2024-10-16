import 'package:flutter/material.dart';

class AppDefaultButton extends StatelessWidget {
  static const _menuBtnPadding  = EdgeInsets.all(16.0);
  static const _menuBorderRadii = Radius.circular(8.0);

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
            borderRadius: BorderRadius.all(_menuBorderRadii),
          ),
        ),
        child: Padding(
          padding: _menuBtnPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}
