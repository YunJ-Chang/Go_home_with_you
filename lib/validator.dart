import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'dart:async';


class Validator {
  static String? LoginAccount({required String account}) {
    if (account.isEmpty) {
      return 'can\'t be empty';
    }
    return null;
  }

  Future<String?> checkAccountAndPassword(String inputAccount, String inputPassword) async {
    try {
      // 連接到Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // 檢查是否存在該用戶帳戶
      DocumentSnapshot userSnapshot = await firestore.collection('userdata').doc(inputAccount).get();

      if (userSnapshot.exists) {
        // 如果帳戶存在，檢查密碼是否正確
        String storedPassword = userSnapshot.get('password');

        if (storedPassword == inputPassword) {
          // 帳戶和密碼都正確
          return null;
        } else {
          // 密碼不正確
          return 'Wrong account or password';
        }
      } else {
        // 帳戶不存在
        return 'Wrong account or password';
      }
    } catch (e) {
      // 處理錯誤
      print('Error: $e');
      return 'Error occurred';
    }
  }

  static String? LoginPassword(
      {required String account, required String password}) {
    if (password.isEmpty) {
      return 'can\'t be empty';
    } else if (account != 'abc' || password != '123') {
      return '✘ wrong account or password';
    }
    return null;
  }

  static String? SignUpAccount({required String account}){
    if (account.isEmpty) {
      return 'can\'t be empty';
    } else if (account.length < 4) {
      return 'must be more than 4 characters';
    } else if (account.contains(' ')) {
      return 'can\'t contain blank';
    }

    // bool isUnique = await isUsernameUnique(account);
    //
    // if (isUnique) {
    //   print('註冊成功！');
    //   return null;
    // } else if (!isUnique){
    //   // 如果 username 已存在，則顯示錯誤訊息
    //   print('錯誤：該用戶名稱已被使用！');
    //   return 'The account is already taken!';
    // }
    return null;
  }

  static String? SignUpPassword({required String password}) {
    if (password.isEmpty) {
      return 'can\'t be empty';
    } else if (password.length < 4) {
      return 'must be more than 4 characters';
    } else if (password.contains(' ')) {
      return 'can\'t contain blank';
    }
    return null;
  }

  static String? Confirm_Password(
      {required String pass, required String com_pass}) {
    if (com_pass.isEmpty) {
      return 'can\'t be empty';
    } else if (pass != com_pass) {
      return 'The passwords isn\'t consistent';
    }
    return null;
  }
  var db = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();

  Future<bool> isUsernameUnique(String username) async {
    // 查詢是否已存在相同的 username
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userdata')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty;
  }
}