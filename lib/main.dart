import 'package:flutter/material.dart';
import 'main_page.dart';
import 'sign_up.dart';
import 'validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// firebase 初始設定
var db = FirebaseFirestore.instance;

// 判斷帳號和密碼有無吻合
String pwResult = "";
bool checkPw = false;
Future<void> checkAccountAndPassword(
    {required String account, required String password}) async {
  try {
    // 連接到Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 檢查是否存在該用戶帳戶
    DocumentSnapshot userSnapshot =
        await firestore.collection('userdata').doc(account).get();

    if (userSnapshot.exists) {
      // 如果帳戶存在，檢查密碼是否正確
      String storedPassword = userSnapshot.get('pw');

      if (storedPassword == password) {
        // 帳戶和密碼都正確
        print("All right!");
        pwResult = "";
        checkPw = true;
      } else {
        // 密碼不正確
        print('Wrong account or password');
        pwResult = 'Wrong account or password';
        checkPw = false;
      }
    } else {
      // 帳戶不存在
      print('Wrong account or password');
      pwResult = 'Wrong account or password';
      checkPw = false;
    }
  } catch (e) {
    // 處理錯誤
    print('Error: $e');
    pwResult = 'Error occurred';
    checkPw = false;
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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
            child: HomePage()),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller_account = new TextEditingController();
  final TextEditingController controller_pwd = new TextEditingController();
  final _FormKey = GlobalKey<FormState>();

  bool passwordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Image.asset(
        'assets/images/logo_circle.png',
        width: 100,
        height: 100,
      ),
      const Padding(
        padding: EdgeInsets.all(20),
      ),
      const Text('Login', style: kTitleTextStyle),
      Container(
        //color: const Color.fromARGB(255, 209, 209, 209),
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 40, top: 10, right: 40, bottom: 10),
        child: Column(
          children: <Widget>[
            SizedBox(height: 16),
            Form(
              key: _FormKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Account', style: kBodyTextStyle),
                    TextFormField(
                      controller: controller_account,
                      validator: (value) => Validator.LoginAccount(
                          account: controller_account.text),
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Please enter your account',
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
                      validator: (value) {
                        // 判斷帳密有無吻合
                        checkAccountAndPassword(
                            account: controller_account.text,
                            password: controller_pwd.text);
                        if (!checkPw)
                          return pwResult;
                        else
                          return null;
                      },
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 15),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        hintText: 'Please enter your password',
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
                      padding: EdgeInsets.all(16),
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
                          backgroundColor: Color.fromARGB(255, 237, 183, 142)),
                      // backgroundColor: Color.fromARGB(255, 241, 207, 142)),
                      child: const Text('Login'),
                      onPressed: () async {
                        if (_FormKey.currentState!.validate()) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => BPage()));
                        }
                      },
                    ),
                  ]),
            )
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(8),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            //side: BorderSide(color: Colors.red, width: 1.0),
          ),
          minimumSize: Size(310, 50),
          textStyle: (TextStyle(fontSize: 25)),
          foregroundColor: Color.fromARGB(255, 237, 183, 142),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
        ),
        child: const Text('Sign Up'),
        onPressed: () {
          // cities.doc("SF").set(data1);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Sign_up()));
        },
      ),
      const Padding(
        padding: EdgeInsets.all(40),
      ),
      // const Text('- Company with you -', style: TextStyle(fontSize: 20)),
    ]);
  }
}
