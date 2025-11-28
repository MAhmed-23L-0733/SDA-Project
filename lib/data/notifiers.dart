//value notifier , it holds the data
//ValueListenableBuilder , listen to the data don't need the setstate
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_template/models/admin_model.dart';
import 'package:flutter_template/models/customer_model.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
ValueNotifier<bool> isSignedInNotifier = ValueNotifier(false);
ValueNotifier<String> roleNotifier = ValueNotifier("guest");
ValueNotifier<Customer> customerNotifier = ValueNotifier(
  Customer(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    dob: DateTime.now(),
    gender: -1,
  ),
);
ValueNotifier<Admin> adminNotifier = ValueNotifier(
  Admin(
    id: null,
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    dob: DateTime.now(),
    gender: -1,
  ),
);
ValueNotifier<int> randomNumberNotifier = ValueNotifier(Random().nextInt(255));
