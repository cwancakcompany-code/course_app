// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:url_launcher/url_launcher.dart';

Future dialPhoneNumber(String? phone) async {
  // Add your function code here!
  final phoneNumber = Uri(
    scheme: 'tel',
    path: phone,
  );

  if (await canLaunchUrl(phoneNumber)) {
    await launchUrl(phoneNumber);
  } else {
    print('Could not launch $phoneNumber');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
