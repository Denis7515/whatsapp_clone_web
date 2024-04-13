import 'package:whatsapp_web/model/user_model.dart';
import 'package:flutter/material.dart';


class ProviderChat with ChangeNotifier {
  UserModel? _toUserData;

  UserModel? get toUserData => _toUserData;

  set toUserData(UserModel? userDataModel) {
    _toUserData = userDataModel;
    notifyListeners();
  }
}