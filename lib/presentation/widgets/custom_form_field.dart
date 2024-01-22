import 'package:flutter/material.dart';

class CustomFormField extends FormField {
  const CustomFormField({
    super.key,
    required super.builder,
    FormFieldValidator<dynamic>? validator,
  }) : super(validator: validator);
}
