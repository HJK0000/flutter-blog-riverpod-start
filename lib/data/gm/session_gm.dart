import 'package:flutter/material.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';
import 'package:flutter_blog/data/repository/user_repository.dart';
import 'package:flutter_blog/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// 창고겸 데이터
class SessionGM {
  int? id;
  String? username;
  String? accessToken;
  bool isLogin;

  SessionGM({this.id, this.username, this.accessToken, this.isLogin = false});

  final mContext = navigatorKey.currentContext!;

  // 뷰가 호출한다.
  Future<void> login(String username, String password) async {
    // 1. username, apssword를 받아서 통신 {success: status: erreoMessage: response 이렇게 넘어온다.}
    var (body, accessToken) = await UserRepository().login(username, password);

    Logger().d("세션창고의 login() 메서드 실행됨 ${body}, ${accessToken}");

    // 2. 성공 or 실패 처리
    if (body["success"]) {
      Logger().d("로그인 성공");
      // 1. sessionGM 값 변경
      this.id = body["response"]["id"];
      this.username = body["response"]["username"];
      this.accessToken = accessToken;
      this.isLogin = true;
      // 이 4개는 세션에 넣는다고 생각하면 된다.

      // 2. 휴대폰 하드에 저장
      await secureStorage.write(key: "accessToken", value: accessToken);
      // 저장되고 이동되어야 하니까 accessToken 넣어준다.

      // 3. dio에 토큰 세팅
      dio.options.headers["Authorization"] =
          accessToken; // dio에 헤더에서 전달된 토큰이 저장된다.
      // 이제부터는 항상 토큰을 가지고 요청할 것임

      // 4. 화면 이동
      Navigator.pushNamed(mContext, "/post/list");
    } else {
      Logger().d("로그인 실패");
      ScaffoldMessenger.of(mContext).showSnackBar(
        SnackBar(content: Text("${body["errorMessage"]}")),
      );
    }
  }

  Future<void> join() async {}

  Future<void> logout() async {
    await secureStorage.delete(key: "accessToken"); // 삭제하면 이제 디바이스에 토큰이 없다.
    // 서버는 상태가 없으니까 로그아웃 서버에서 하는거 아님
    // 로그아웃은 프론트에서 토큰삭제하고 메모리 저장된 값 원복하면 된다.
    this.id = null;
    this.username = null;
    this.accessToken = null;
    this.isLogin = false;
    Navigator.popAndPushNamed(mContext, "/login"); // IO가 일어나는게 아니니까 AWAIT 붙여주지 않는다.
    // 로그아웃 페이지로 갈때는 다 지우고 가면 된다. ?

  }

  Future<void> autoLogin() async {
    // 1. 시큐어 스토리지에서 accessToken 꺼내기
      String? accessToken = await secureStorage.read(key: "accessToken");

      if(accessToken == null){
        Navigator.popAndPushNamed(mContext, "/login");
      }else{
        // 2. api 호출
        Map<String, dynamic> body = await UserRepository().autoLogin(accessToken);

        // 3. 통신이 끝나면 세션값 갱신
        this.id = body["response"]["id"];
        this.username = body["response"]["username"];
        this.accessToken = accessToken;
        this.isLogin = true;

        // 4. 정상이면 /post/list로 이동 (pop and pushNamed)
        // -> 스플래쉬의 이미지 사라져야 하니까 pop and pushname
        Navigator.popAndPushNamed(mContext, "/post/list");
      }
  }
}

final sessionProvider = StateProvider<SessionGM>((ref) {
  return SessionGM();
});
