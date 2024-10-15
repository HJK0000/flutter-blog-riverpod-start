import 'package:dio/dio.dart';
import 'package:flutter_blog/_core/utils/my_http.dart';

// 통신
class UserRepository {
  Future<Map<String, dynamic>> autoLogin(String accessToken) async {
    // -> 엑세스 토큰이 유효한지 찾겠다.
    // 원래 findMatchAccessToken 처럼 서비스명이 아니라 뭐찾는지 적어줘야한다.

    final response = await dio.post(
      "/auto/login",
      options: Options(
          headers: {"Authorization": "Bearer $accessToken"} // 이렇게 토큰 넣어서 요청하면 된다.
      ),
    );// dio path는 99로 지금 설정되어있다.

    Map<String, dynamic> body = response.data; // 1개 객체가 응답되니까 one 이라고 짓고 Map<String, dynamic> 으로 받음
    return body;

  }


  Future<(Map<String, dynamic>, String)> login(String username, String password) async {

    final response = await dio.post(
      "/login",
      data: {
        "username":username,
        "password":password // dio에 설정되어있응니까 contenttype은 안넣어도 된다.
      }
    );

    String accessToken = response.headers["Authorization"]![0]; // 로그인 성공하면 무조건 있으니까 ! 사용
    Map<String, dynamic> body = response.data; // 1개 객체가 응답되니까 one 이라고 짓고 Map<String, dynamic> 으로 받음
    return (body, accessToken); // request DTO이런거 안만들어도 되어서 매우 편한다.

  }
}