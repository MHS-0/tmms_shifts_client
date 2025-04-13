import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmms_shifts_client/l18n/app_localizations.dart';

class TitleAndTextFieldRow extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final bool numbersOnly;
  final bool enabled;
  final bool emptyAllowed;
  final String? Function(String?)? validator;

  const TitleAndTextFieldRow({
    super.key,
    required this.controller,
    required this.title,
    this.numbersOnly = false,
    this.enabled = true,
    this.emptyAllowed = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String? Function(String?)? localValidator;

    if (validator == null && !emptyAllowed) {
      localValidator = (text) {
        if (text == null || text.isEmpty) {
          return localizations.pleaseFillTheField;
        }
        return null;
      };
    } else {
      localValidator = validator;
    }

    return SizedBox(
      height: 80,
      child: Row(
        spacing: 32,
        children: [
          SizedBox(
            width: 200,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, textAlign: TextAlign.end),
            ),
          ),
          SizedBox(
            width: 400,
            child: TextFormField(
              enabled: enabled,
              controller: controller,
              decoration: InputDecoration(hintText: title, labelText: title),

              keyboardType:
                  numbersOnly ? const TextInputType.numberWithOptions() : null,
              inputFormatters:
                  numbersOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
              validator: localValidator,
            ),
          ),
        ],
      ),
    );
  }
}
