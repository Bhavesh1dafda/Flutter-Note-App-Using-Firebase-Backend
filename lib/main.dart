import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';
import 'loginPage.dart';
import 'package:get/get.dart';
import 'notepage.dart';


Future<void> main() async {
  var deviceId = ["E6B67FA2B5A15BCCD5A1663AF09D2D8C"];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();
  runApp(MyApp());
  RequestConfiguration requestConfiguration =  RequestConfiguration(
testDeviceIds: deviceId
  );
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;
  @override
  initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, child!),
        maxWidth: 1200,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          const ResponsiveBreakpoint.resize(450, name: MOBILE),
          const ResponsiveBreakpoint.autoScale(800, name: TABLET),
          const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
          const ResponsiveBreakpoint.resize(1200, name: DESKTOP),
          const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
        ],),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: user != null ? NotesHomePage() : LoginaPage(),
    );
  }
}

