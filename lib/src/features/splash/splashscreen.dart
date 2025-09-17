import 'package:cash_pendency/src/features/auth/login.dart';
import 'package:cash_pendency/src/features/cash_pendency/cash_pendency.dart';
import 'package:cash_pendency/src/helper/api.dart';
import 'package:cash_pendency/src/helper/hive_localstorage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () => navigatToscreen());
  }

  navigatToscreen() async {
    user = await getUserData();
    if (user != null) {
      Auth.accestoken = user!.accestoken;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null ? CashPendency() : LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Cash Pendency',
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
