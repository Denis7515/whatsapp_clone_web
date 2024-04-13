
import 'package:flutter/material.dart';
import 'package:whatsapp_web/model/user_model.dart';

class ProviderEmail with ChangeNotifier {
  UserModel? _toUserData;

  UserModel? get toUserData => _toUserData;

  set toUserData(UserModel? userDataModel) {
    _toUserData = userDataModel;
    notifyListeners();
  }
}