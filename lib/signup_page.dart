// signup_page.dart 파일
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import "main.dart";
import "login_page.dart";

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  TextEditingController userIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  addUser(String userId, String password, String name) async {
    String serverUri =
        "https://56c0-61-75-21-162.ngrok-free.app/add-user"; // URL 변경

    var response = await http.post(
      Uri.parse(serverUri),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'userId': userId,
        'password': password,
        'name': name, // Data로 name을 추가로 넘겨줌
      },
    );

    print(response.body);

    if (response.statusCode == 200) {
      var addUserStatus = response.body;
      if (addUserStatus == 'success') {
        // Flutter 서버에서 "true" 대신 "success" 반환
        // 회원가입에 성공하면 자동으로 로그인되게 구현
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => const MyHomePage(title: 'Flutter Demo Home Page')));
      } else {
        showAlertDialog("사용자 추가 실패", "Flutter Server 관리자에게 문의하세요.");
      }
    } else {
      showAlertDialog(
          "서버 오류", "Flutter Server의 정상 동작 여부를 점검하세요.(${response.statusCode})");
    }
  }

  showAlertDialog(title, message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
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
      appBar: AppBar(
        title: Text("회원가입"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 300,
              child: Column(
                children: [
                  Container(
                    width: 200,
                    child: TextField(
                      controller: userIdController,
                      maxLines: 1, // 최대 라인수를 1줄로 제한
                      decoration: InputDecoration(
                          labelText: "아이디",
                          border: OutlineInputBorder(),
                          hintText: "8자 이상 입력해 주세요." // 안내 문구 추가
                          ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      maxLines: 1, // 최대 라인수를 1줄로 제한
                      decoration: InputDecoration(
                          labelText: "비밀번호",
                          border: OutlineInputBorder(),
                          hintText: "8자 이상 입력해 주세요." // 안내 문구 추가
                          ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: TextField(
                      controller: passwordConfirmController,
                      obscureText: true,
                      maxLines: 1, // 최대 라인수를 1줄로 제한
                      decoration: InputDecoration(
                        labelText: "비밀번호확인",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: TextField(
                      controller: nameController,
                      maxLines: 1, // 최대 라인수를 1줄로 제한
                      decoration: InputDecoration(
                        labelText: "이름",
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
                                    builder: (context) => LoginPage()));
                          },
                          child: Text("취소")),
                      TextButton(
                          onPressed: () {
                            // 회원가입 클릭시 Server의 add-user API 호출
                            addUser(userIdController.text,
                                passwordController.text, nameController.text);
                          },
                          child: Text("회원가입")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
