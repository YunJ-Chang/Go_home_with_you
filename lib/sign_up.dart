import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// 判斷是否已存在相同的 username
bool isUnique = false;
bool checkUni = false;
Future<bool> isUsernameUnique({required String username}) async {
  // 查詢是否已存在相同的 username
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('userdata')
      .where('account', isEqualTo: username)
      .get();

  return querySnapshot.docs.isEmpty;
}

Future<void> CheckIsUnique({required String account}) async {
  // 檢查是否已存在相同的 username
  bool isUnique = await isUsernameUnique(username: account);

  if (isUnique) {
    // 如果 username 是唯一的，則進行註冊
    checkUni = true;
    print('註冊成功！');
  } else {
    // 如果 username 已存在，則顯示錯誤訊息
    checkUni = false;
    print('錯誤：該用戶名稱已被使用！');
  }
}

const OutlineInputBorder testfieldSet = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(20)),
  borderSide: BorderSide(
    width: 2,
    color: Color.fromARGB(255, 223, 223, 223),
  ),
);

const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 30,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w500,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 20,
  color: Color.fromARGB(255, 255, 255, 255),
  fontWeight: FontWeight.w400,
);

class Sign_up extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 117, 113, 173),
        // backgroundColor: Color.fromARGB(255, 43, 36, 129),
        // backgroundColor: Color.fromARGB(255, 237, 183, 142),
        //title: Text('登入'),
      ),
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg4.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Sign_up_()),
    );
  }
}

class Sign_up_ extends StatefulWidget {
  @override
  State<Sign_up_> createState() => _Sign_up();
}

class _Sign_up extends State<Sign_up_> {
  final TextEditingController controller_account = new TextEditingController();
  final TextEditingController controller_pwd = new TextEditingController();
  final TextEditingController controller_pwd_again =
      new TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _validate = false;
  bool passwordVisible = true;
  bool rePasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      const Padding(
        padding: EdgeInsets.all(25),
      ),
      const Text('Sign Up', style: kTitleTextStyle),
      Container(
        //color: const Color.fromARGB(255, 209, 209, 209),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 40, top: 15, right: 40, bottom: 0),
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10),
            ),
            Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Account', style: kBodyTextStyle),
                    TextFormField(
                      controller: controller_account,
                      validator: (value) {
                        // 判斷username有無被註冊過 (到 return null; 下的大括弧)
                        if (Validator.SignUpAccount(
                                account: controller_account.text) !=
                            null) {
                          return Validator.SignUpAccount(
                              account: controller_account.text);
                        }
                        CheckIsUnique(account: controller_account.text);
                        if (!checkUni) {
                          return 'The account is already taken!';
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 15),
                        // labelText: "AccounColor.fromARGB(255, 252, 207, 4)Behavior: FloatingLabelBehavior.never,
                        hintText: 'more than 4 characters',
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.person),
                        border: testfieldSet,
                        enabledBorder: testfieldSet,
                        focusedBorder: testfieldSet,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        filled: true,
                      ),
                      //maxLength: 300,
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Text('Password', style: kBodyTextStyle),
                    TextFormField(
                      controller: controller_pwd,
                      validator: (value) => Validator.SignUpPassword(
                          password: controller_pwd.text),
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'more than 4 characters',
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        border: testfieldSet,
                        enabledBorder: testfieldSet,
                        focusedBorder: testfieldSet,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        filled: true,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                    ),
                    Text('Confirm Password', style: kBodyTextStyle),
                    TextFormField(
                      controller: controller_pwd_again,
                      validator: (value) => Validator.Confirm_Password(
                          pass: controller_pwd.text,
                          com_pass: controller_pwd_again.text),
                      obscureText: rePasswordVisible,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Re-enter your password',
                        contentPadding: const EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(rePasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              rePasswordVisible = !rePasswordVisible;
                            });
                          },
                        ),
                        border: testfieldSet,
                        enabledBorder: testfieldSet,
                        focusedBorder: testfieldSet,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        filled: true,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          //side: BorderSide(color: Colors.red, width: 1.0),
                        ),
                        minimumSize: Size(310, 50),
                        textStyle: (TextStyle(fontSize: 25)),
                        foregroundColor: Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color.fromARGB(255, 237, 183, 142),
                      ),
                      child: const Text('Sign Up'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // 存入帳號密碼 ( 到userdata.doc(controller_account.text).set(data); )
                          var db = FirebaseFirestore.instance;
                          final userdata =
                              FirebaseFirestore.instance.collection("userdata");
                          final data = <String, dynamic>{
                            "account": controller_account.text,
                            "pw": controller_pwd.text
                          };
                          userdata.doc(controller_account.text).set(data);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ]),
            )
          ],
        ),
      ),
    ]);
  }
}

showAlertDialog(BuildContext context) {
  // Init
  AlertDialog dialog = AlertDialog(
    title: Text("Please ensure that Password and Confirm Password match."),
    actions: [
      ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              //side: BorderSide(color: Colors.red, width: 1.0),
            ),
            minimumSize: Size(50, 25),
            textStyle: (TextStyle(fontSize: 20)),
            foregroundColor: Color.fromARGB(255, 237, 183, 142),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
          child: Text("close"),
          onPressed: () {
            Navigator.pop(context);
          }),
    ],
  );

  // Show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      });
}
