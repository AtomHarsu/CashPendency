import 'package:cash_pendency/src/features/auth/login_provider.dart';
import 'package:cash_pendency/src/features/cash_pendency/cash_pendency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

LoginProvider? loginProvider;

class _LoginScreenState extends State<LoginScreen> {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo? androidInfo;
  getDeviceInfo() async {
    androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo!.model}');
    print('Running on ${androidInfo!.name}');
    print('Running on ${androidInfo!.id}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginProvider>(
        builder: (context, loginProvider, child) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: GoogleFonts.montserrat(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username ';
                        }
                        return null;
                      },
                      controller: loginProvider.emailController,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.montserrat(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      style: GoogleFonts.montserrat(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                      controller: loginProvider.passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        loginProvider.setLoading(true);
                        await loginProvider.Login(
                          androidInfo!.id.toString(),
                          androidInfo!.name.toString(),
                          androidInfo!.version.codename.toString(),
                        ).then((value) {
                          loginProvider.setLoading(false);
                          if (value == 'true') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => CashPendency()),
                              (_) => false,
                            );
                          } else if (value == 'false') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Login Failed',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
                            return;
                          } else {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value,
                                  style: GoogleFonts.montserrat(),
                                ),
                              ),
                            );
                            return;
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xfffFF6B1B),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Login',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loginProvider.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(),
            ],
          );
        },
      ),
    );
  }
}
