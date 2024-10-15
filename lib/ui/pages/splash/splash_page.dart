import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/gm/session_gm.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(sessionProvider).autoLogin(); // 통신이 끝나고 토큰이 없으면 로그인 페이지로 간다.

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/splash.gif',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
