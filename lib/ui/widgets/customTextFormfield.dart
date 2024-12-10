import 'package:flutter/material.dart';

import '../../app/generalImports.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.textInputAction,
    this.currNode,
    this.nextFocus,
    this.textInputType = TextInputType.text,
    this.isPswd = false,
    this.heightVal,
    this.prefix,
    this.suffix,
    this.hintText,
    this.labelText,
    this.isReadOnly,
    this.callback,
    this.isDense,
    this.backgroundColor,
    this.isRoundedBorder,
    this.borderColor,
    this.hintTextColor,
    this.validator,
    this.forceUnfocus,
    this.onSubmit,
    this.inputFormatters,
    this.expands,
    this.minLines,
    this.labelStyle,
    this.bottomPadding,
    this.allowOnlySingleDecimalPoint,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? currNode;
  final FocusNode? nextFocus;
  final TextInputAction? textInputAction;
  final TextInputType textInputType;
  final bool isPswd;
  final double? heightVal;
  final Widget? prefix;
  final Widget? suffixIcon;
  final Widget? suffix;
  final String? hintText;
  final String? labelText;
  final bool? isReadOnly;
  final VoidCallback? callback;
  final bool? isDense;
  final Color? backgroundColor;
  final bool? isRoundedBorder;
  final Color? borderColor;
  final Color? hintTextColor;
  final String? Function(String?)? validator;
  final bool? forceUnfocus;
  final Function()? onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final bool? expands;
  final int? minLines;
  final TextStyle? labelStyle;
  final double? bottomPadding;
  final bool? allowOnlySingleDecimalPoint;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return CustomSizedBox(
      child: Padding(
        padding: EdgeInsetsDirectional.only(bottom: widget.bottomPadding ?? 10),
        child: TextFormField(
          focusNode: widget.currNode,
          inputFormatters: widget.allowOnlySingleDecimalPoint ?? false
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : widget.inputFormatters,

          onEditingComplete: () {
            if (widget.nextFocus != null) {
              FocusScope.of(context).requestFocus(widget.nextFocus);
            } else if (widget.currNode != null) {
              if (widget.forceUnfocus ?? false) widget.currNode!.unfocus();
              widget.onSubmit?.call();
            }
          },
          onFieldSubmitted: (String value) {
            FocusScope.of(context).unfocus();
          },
          validator: widget.validator,
          onTap: widget.callback,
          cursorColor: context.colorScheme.lightGreyColor,

          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle:
                widget.labelStyle ?? TextStyle(color: context.colorScheme.blackColor, fontSize: 12),
            prefixIcon: widget.prefix,
            suffix: widget.suffix,
            hintText: widget.hintText,
            floatingLabelStyle:  WidgetStateTextStyle.resolveWith(
              (Set<WidgetState> states) {
                final Color color = states.contains(WidgetState.error)
                    ? context.colorScheme.error
                    : context.colorScheme.blackColor;
                return TextStyle(color: color, letterSpacing: 1.3);
              },
            ),
            hintStyle: TextStyle(
              fontSize: 12,
              color: widget.hintTextColor ?? context.colorScheme.lightGreyColor,
            ),
            isDense: widget.isDense ?? true,
            suffixIcon: widget.isPswd ? togglePassword() : widget.suffixIcon,
            fillColor: widget.backgroundColor ?? Colors.transparent,
            errorStyle: const TextStyle(fontSize: 10, color: AppColors.redColor),
            filled: true,
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.redColor),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                    ? widget.borderColor!
                    : AppColors.redColor,
              ),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                    ? widget.borderColor!
                    : context.colorScheme.lightGreyColor,
              ),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: ((widget.isRoundedBorder ?? false) && widget.borderColor != null)
                    ? widget.borderColor!
                    : context.colorScheme.accentColor,
              ),
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
            border: OutlineInputBorder(
              borderSide: widget.isRoundedBorder ?? false ? const BorderSide() : BorderSide.none,
              borderRadius: BorderRadius.circular(UiUtils.borderRadiusOf10),
            ),
          ),
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(
            fontSize: 12,
            color: widget.hintTextColor ?? context.colorScheme.blackColor,
          ),
          readOnly: widget.isReadOnly ?? false,
          keyboardType: widget.textInputType,
          minLines: widget.minLines,
          maxLines: (widget.textInputType == TextInputType.multiline)
              ? (widget.expands == true ? null : 3)
              : 1,
          //assigned 1 because null is not working with Ob-secureText
          textInputAction: widget.textInputAction ??
              ((widget.nextFocus != null)
                  ? TextInputAction.next
                  : (widget.textInputType == TextInputType.multiline)
                      ? TextInputAction.newline
                      : TextInputAction.done),
          obscureText: _checkPasswordField(),
          controller: widget.controller,
        ),
      ),
    );
  }

  IconButton togglePassword() {
    return IconButton(
      onPressed: () {
        setState(() {
          isPasswordVisible = !isPasswordVisible;
        });
      },
      icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
    );
  }

  bool _checkPasswordField() {
    if (widget.isPswd == true) {
      // if it is password field.
      // it will check the variable to check if we should show password or not
      return isPasswordVisible == false;
    } else {
      return false;
    }
  }
}
