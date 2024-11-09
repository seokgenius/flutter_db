import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:math'; // pi 상수를 사용하기 위하여 import

import "main.dart";
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

//class _LoginPageState extends State<LoginPage> {
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  // SingleTickerProviderStateMixin을 사용하도록 설정
  // Mixin은 Java에는 없는 개념으로 특정 기능만 제공하는 클래스로 보면 됨
  // Animation COntroller를 사용하기 위하여 이 Mixin이 필요함
  // 여러 Animation을 사용하려면 TickerProviderStateMixin을 대신 사용함
  // 아래 코드에서 vsync: this를 동작가능하게 하여 Animation을 동기화함

  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  double idPasswordOpacity = 0;

  var animationController; // animationController 변수
  var animation; // 어떤 Animation을 할지 결정함

  // 로그인 ID를 저장하는 함수
  saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // 저장된 로그인 ID를 불러오는 함수
  loadSavedUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var userId = prefs.getString('user_id');
      if (userId != null) userIdController.text = userId;
    });
  }

  @override
  void initState() {
    // 객체 사용전 최초 자원을 할당 및 초기화
    // TODO: implement initState
    super.initState(); // Parent들이 할당할 자원과 초기화를 맨앞에 수행
    // dispose()와 반대로 앞에 배치

    // Animation Controller에 3초 Animation을 설정/Animation 대상은 이 객체(vsync: this)
    animationController =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    // 0도 에서 360도(pi * 2) 돌아가는 Animation을 Animation Controller에 설정. (3초에 한바퀴)
    animation =
        Tween<double>(begin: 0, end: pi * 2).animate(animationController);
    animationController.repeat(); // animation Controller로 Animation 시작
    // animation이 수치상으로 발생하고
    // 이를 가져다 화면에 보여주는 Widget은 AnimatedBuilder임

    // userIdController.text = "test";
    loadSavedUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(Duration(seconds: 2), () {
        setState(() {
          idPasswordOpacity = 1;
        });
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose(); // 할당받은 Animation Controller 자원을 반납함
    // TODO: implement dispose
    super.dispose(); // Parent들이 해제할 자원을 맨뒤에 해제(initState()와 반대로 뒤에 배치)
  } // super.initState()는 앞에 배치되어 Parent가 할당할 자원을 먼저 할당

  loginCheck(String userId, String password) async {
    // ngrok를 실행할 때마다 매번 바꾸어 주어야 합니다.
    String serverUri = "https://56c0-61-75-21-162.ngrok-free.app/login-check";

    var response = await http.post(
      Uri.parse(serverUri),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userId,
        'password': password,
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      //var loginStatus = response.body;
      var parseJson = jsonDecode(response.body); // Json을 Decode하여 Map으로 변경
      bool loginSuccess =
          parseJson['loginSuccess']; // Map에서 loginSuccess 키의 값을 읽음

      //if (loginStatus == 'true') {
      if (loginSuccess) {
        saveUserId(userId); // 로그인 성공시 성공한 User Id 문자열을 저장

        // Map에서 받아온 bool 값을 비교
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>
                const MyHomePage(title: 'Flutter Demo Home Page')));
      } else {
        showAlertDialog("로그인 실패", "아이디가 존재하지 않거나 비밀번호가 일치하지 않습니다.");
      }
    } else {
      showAlertDialog(
          "서버 오류", "Flutter Server의 정상 동작 여부를 점검하세요.(${response.statusCode})");
    }
  }

  showAlertDialog(title, message) {
    // 경고창을 보여주는 기능을 함수로 분리
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title), // 경고창의 타이틀 추가
            content: Text(message),
            actions: [
              // 경고창에 Ok 버튼 추가
              TextButton(
                onPressed: () {
                  // Ok 버튼 누르면 이전 창으로 돌아감
                  Navigator.of(context).pop();
                },
                child: Text("Ok"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("images/LG DX School.PNG"),
            SizedBox(height: 50),
            AnimatedOpacity(
              opacity: idPasswordOpacity, // 불투명도를 앞에서 지정한 변수로 지정
              duration: Duration(seconds: 3),
              child: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller:
                            userIdController, // TextField와 Controller 연결
                        decoration: InputDecoration(
                          labelText: "아이디",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: TextField(
                        controller:
                            passwordController, // TextField와 Controller 연결
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          SignupPage())); // 회원가입 페이지로 이동
                            },
                            child: Text("회원가입")),
                        TextButton(
                            onPressed: () {
                              loginCheck(userIdController.text,
                                  passwordController.text); // loginCheck 함수 사용
                            },
                            child: Text("로그인")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedBuilder(
                // image 객체를 AnimatedBuilder로 감쌈
                animation:
                    animationController, // animationController를 사용하여 Animation
                builder: (context, widget) {
                  // context : 현재 화면, widget : 감싸진 Widget
                  return Transform.rotate(
                    // animation에 설정된 각도 정보를 가지고 회전시킴
                    angle: animation.value, // 각도 정보가 포함된 animation을 사용
                    child: widget, // AnimatedBuilder로 감싸진 Widget
                  );
                },
                child: Image.asset("images/lab4dx.PNG")),
          ],
        ),
      )),
    );
  }
}
