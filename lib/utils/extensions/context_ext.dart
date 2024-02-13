import 'package:flutter/material.dart';
import 'package:fixawy_provider/locale/base_language.dart';

extension ContextExt on BuildContext {
  Languages get translate => Languages.of(this);
}
