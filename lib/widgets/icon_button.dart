import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final IconData initialIcon;
  final IconData alternateIcon;
  final Color iconColor;
  final Color backgroundColor;
  final double padding;
  final VoidCallback? onPressed;

  const CustomIconButton({
    super.key,
    required this.initialIcon,
    required this.alternateIcon,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.grey,
    this.padding = 8.0,
    this.onPressed,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  late IconData _currentIcon;

  @override
  void initState() {
    super.initState();
    _currentIcon = widget.initialIcon;
  }

  void _toggleIcon() {
    setState(() {
      _currentIcon =
          _currentIcon == widget.initialIcon
              ? widget.alternateIcon
              : widget.initialIcon;
    });
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(_currentIcon, color: widget.iconColor),
        onPressed: _toggleIcon,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
