// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

String getCurrencySymbol(String currencyCode) {
  switch (currencyCode.trim().toUpperCase()) {
    case 'IQD':
    case 'د.ع':
      // Prices already append د.ع after the number — never prefix.
      return '';
    case 'USD':
    case 'AUD':
    case 'CAD':
    case 'SGD':
      // Storefront is IQD; do not show $.
      return '';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
    case 'CNY':
      return '¥';
    case 'INR':
      return '₹';
    case 'CHF':
      return 'CHF';
    default:
      return '';
  }
}

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
