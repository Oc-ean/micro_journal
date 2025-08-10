import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:micro_journal/src/common/common.dart';

class CustomButton extends StatefulWidget {
  final String? text;
  final Color? textColor;
  final double boxRadius;
  final double? height;
  final double? width;
  final Widget? icon;
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final bool loading;
  final FontWeight? fontWeight;
  final double? fontSize;
  final VoidCallback? onTap;
  final bool? isBottomBorder;
  final MainAxisAlignment? alignment;
  final Widget? rightICon;
  final bool enableGradient;
  final int? textMaxLine;
  final double? widthSpace;
  final Color? firstGradientColor;
  final Color? secondGradientColor;

  const CustomButton({
    super.key,
    this.text,
    this.boxRadius = 30,
    this.width,
    this.icon,
    this.textColor = Colors.white,
    this.color,
    this.onTap,
    this.height,
    this.loading = false,
    this.borderColor,
    this.fontWeight,
    this.fontSize,
    this.alignment,
    this.isBottomBorder = false,
    this.borderWidth,
    this.rightICon,
    this.enableGradient = false,
    this.textMaxLine,
    this.widthSpace,
    this.firstGradientColor,
    this.secondGradientColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = context.screenSize.width;

    final double responsiveFontSize =
        widget.fontSize ?? (screenWidth * 0.04).clamp(14, 20);

    return MouseRegion(
      onEnter: (PointerEnterEvent event) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (PointerExitEvent event) {
        setState(() {
          _isHovering = false;
        });
      },
      cursor: _isHovering ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: widget.height ?? 48,
          width: widget.width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.boxRadius),
            border: widget.isBottomBorder!
                ? Border(
                    bottom: BorderSide(
                      color: widget.borderColor ?? Colors.black,
                      width: 5,
                    ),
                  )
                : Border.all(
                    color: widget.borderColor ?? Colors.transparent,
                    width: widget.borderWidth ?? 1.0,
                  ),
            color: widget.color ?? context.theme.primaryColor,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.loading
                  ? SpinKitThreeBounce(
                      color: widget.textColor ?? Colors.white,
                      size: 20,
                    )
                  : Row(
                      mainAxisAlignment:
                          widget.alignment ?? MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: widget.icon != null && widget.text != null
                              ? 0
                              : 0,
                        ),
                        if (widget.icon != null) ...[
                          widget.icon!,
                          SizedBox(
                            width: widget.text != null
                                ? (widget.widthSpace ?? 10)
                                : 0,
                          ),
                        ],
                        if (widget.text != null) ...[
                          Flexible(
                            child: Text(
                              widget.text!,
                              maxLines: widget.textMaxLine ?? 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontSize: widget.fontSize ?? 16,
                                color: widget.textColor,
                                fontWeight:
                                    widget.fontWeight ?? FontWeight.w500,
                              ),
                            ),
                          ),
                          if (widget.rightICon != null) ...[
                            SizedBox(
                              width: widget.text != null
                                  ? (widget.widthSpace ?? 10)
                                  : 0,
                            ),
                            widget.rightICon!,
                          ],
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
