import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_journal/src/common/common.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomFormTextField<T> extends StatefulWidget {
  final TextInputType textInputType;
  final String? hintText;
  final bool autoFocus;
  final bool obscurable;
  final bool readOnly;
  final Widget? suffix;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefix;
  final double borderRadius;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Map<String, String> validationMessages;
  final FormControl<dynamic>? formControl;
  final BorderRadius? shape;
  final String? name;
  final TextCapitalization textCapitalization;
  final void Function(FormControl<T>)? onSubmitted;
  final FocusNode? focusNode;
  final Future<T?> Function()? onTap;
  final List<String>? autofillHints;
  final ControlValueAccessor<T, String>? valueAccessor;
  final bool busy;
  final bool _noLabel;
  final bool showError;
  final String? prefixText;
  final String? suffixText;
  final TextEditingController? controller;
  final T Function(T?)? onChanged;
  final bool filled;
  final Color? fillColor;
  final bool isUnderlined;

  const CustomFormTextField({
    required this.name,
    this.textInputType = TextInputType.text,
    this.autoFocus = false,
    this.maxLength,
    this.hintText,
    this.suffix,
    this.shape,
    this.prefix,
    this.maxLines,
    this.formControl,
    this.obscurable = false,
    this.readOnly = false,
    this.inputFormatters,
    this.textInputAction,
    this.validationMessages = const {},
    this.borderRadius = 16.0,
    this.textCapitalization = TextCapitalization.words,
    this.onSubmitted,
    this.focusNode,
    this.onTap,
    this.autofillHints,
    this.valueAccessor,
    this.busy = false,
    this.showError = true,
    super.key,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.onChanged,
    this.filled = false,
    this.isUnderlined = false,
    this.fillColor,
  }) : _noLabel = false;

  const CustomFormTextField.noLabel({
    super.key,
    required this.name,
    this.textInputType = TextInputType.text,
    this.autoFocus = false,
    this.maxLength,
    this.suffix,
    this.shape,
    this.prefix,
    this.maxLines,
    this.formControl,
    this.obscurable = false,
    this.readOnly = false,
    this.inputFormatters,
    this.textInputAction,
    this.validationMessages = const {},
    this.borderRadius = 16.0,
    this.textCapitalization = TextCapitalization.words,
    this.onSubmitted,
    this.focusNode,
    this.onTap,
    this.autofillHints,
    this.valueAccessor,
    this.busy = false,
    this.showError = true,
    this.prefixText,
    this.suffixText,
    this.controller,
    this.onChanged,
    this.filled = false,
    this.isUnderlined = false,
    this.fillColor,
  })  : _noLabel = true,
        hintText = null;

  @override
  State<CustomFormTextField<T>> createState() => _CustomFormTextFieldState<T>();
}

class _CustomFormTextFieldState<T> extends State<CustomFormTextField<T>> {
  late bool _obscurable;
  late FocusNode _focusNode;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _obscurable = widget.obscurable;
    _focusNode = widget.focusNode ?? FocusNode();

    if (widget.suffixText != null) {
      _controller.addListener(() {
        String text = _controller.text.replaceAll(widget.suffixText!, '');
        if (text.isNotEmpty) {
          text = '$text${widget.suffixText!}';
          _controller.value = _controller.value.copyWith(text: text);
        } else {
          _controller.value = _controller.value.copyWith(text: '');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap != null) {
      return GestureDetector(
        onTap: () async {
          /// If the pages is busy, we don't want to do anything.
          if (widget.busy) return;

          FocusScope.of(context).unfocus();

          final formGroup = context.reactiveFormGroup;

          final result = await widget.onTap?.call();

          if (result != null) {
            final Map<String, dynamic> value = {};
            value.addAll(
              formGroup!.controls.map((key, value) {
                return MapEntry(key, value.value);
              }),
            );
            value[widget.name!] = result;

            formGroup.updateValue(value);
          }
        },
        child: AbsorbPointer(child: _buildTextField()),
      );
    }
    return _buildTextField();
  }

  InputBorder _buildBorder(Color color) {
    if (widget.isUnderlined) {
      return UnderlineInputBorder(borderSide: BorderSide(color: color));
    } else {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(color: color),
      );
    }
  }

  Widget _buildTextField() {
    final validationMessages = {
      ValidationMessage.required: (_) {
        return 'Cannot be empty';
      },
      ValidationMessage.email: (_) {
        return 'Invalid email';
      },
    };

    final manualValidationMessages = widget.validationMessages.map((
      key,
      value,
    ) {
      return MapEntry(key, (_) => value);
    });

    validationMessages.addAll(manualValidationMessages);
    final isDisabled = context.isFormDisabled(widget.name!);

    return AnimatedBuilder(
      animation: _focusNode,
      builder: (_, __) {
        final isFocused = _focusNode.hasFocus;

        //final Color activeLabelColor = isFocused
        //? Colors.blueGrey
        //: context.theme.textTheme.bodyLarge!.color!;
        //final Color labelColor = isDisabled ? Colors.grey : activeLabelColor;
        final Color valueColor =
            isDisabled ? Colors.grey : context.textTheme.bodyLarge!.color!;

        final iconColor = isFocused ? Colors.blueGrey : valueColor;

        final double verticalPadding = context.isMobile ? 9.0 : 12.5;
        final double labelHeight = context.isMobile ? 21 / 16 : 0.7;

        final hasError = context.formValueHasError(widget.name!);

        return ReactiveTextField<T>(
          controller: _controller,
          focusNode: _focusNode,
          valueAccessor: widget.valueAccessor,
          autofillHints: widget.autofillHints,
          readOnly: widget.readOnly,
          formControl: widget.formControl as FormControl<T>?,
          formControlName: widget.name,
          validationMessages: validationMessages,
          textAlignVertical: TextAlignVertical.center,
          autofocus: widget.autoFocus,
          onSubmitted: widget.onSubmitted?.call,
          keyboardType: widget.textInputType,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.grey.shade900,
          ),
          obscureText: _obscurable,
          cursorColor: context.theme.primaryColor,
          inputFormatters: [
            LengthLimitingTextInputFormatter(widget.maxLength),
            ...widget.inputFormatters ?? [],
          ],
          maxLines: widget.maxLines ?? 1,
          minLines: 1,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          onChanged: (FormControl<T> control) {
            widget.onChanged?.call(control.value);
          },
          decoration: InputDecoration(
            prefixText: widget.prefixText,
            hoverColor: Colors.transparent,
            fillColor: widget.fillColor ?? context.theme.cardColor,
            filled: widget.filled,
            errorMaxLines: 2,
            contentPadding: widget._noLabel
                ? null
                : EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: verticalPadding,
                  ),
            counterStyle: const TextStyle(height: double.minPositive),
            counterText: '',
            suffixIcon: widget.suffix != null || widget.obscurable
                ? IconTheme(
                    data: IconThemeData(color: iconColor),
                    child: _buildSuffixIcon() ?? const SizedBox.shrink(),
                  )
                : null,
            prefixIcon: widget.prefix != null
                ? IconTheme(
                    data: IconThemeData(color: iconColor),
                    child: widget.prefix!,
                  )
                : null,
            border: _buildBorder(
              widget.filled ? Colors.transparent : Colors.grey.shade400,
            ),
            enabledBorder: _buildBorder(
              widget.filled ? Colors.transparent : Colors.grey.shade400,
            ),
            focusedBorder: _buildBorder(
              widget.filled ? Colors.transparent : context.theme.primaryColor,
            ),
            focusedErrorBorder:
                _buildBorder(widget.filled ? Colors.transparent : Colors.red),

            hintText: widget.hintText ?? widget.name,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            //labelText: pages._noLabel ? null : pages.hintText ?? pages.name,
            // labelStyle: size15weight500.copyWith(
            //   color: labelColor,
            //   height: labelHeight,
            // ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          showErrors: (control) =>
              widget.showError &&
              control.invalid &&
              (control.dirty || control.touched),
          obscuringCharacter: '*',
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.busy) {
      return const SizedBox(
        width: 32.0,
        height: 32.0,
        child: CircularProgressIndicator(),
      );
    } else if (widget.suffix != null) {
      return widget.suffix;
    } else if (widget.obscurable) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _obscurable = !_obscurable;
          });
        },
        child: Container(
          width: 32.0,
          margin: const EdgeInsets.only(right: 8.0),
          alignment: Alignment.center,
          child: Icon(
            _obscurable ? Icons.visibility_off : Icons.visibility,
            size: 20.0,
          ),
        ),
      );
    }

    return null;
  }
}
