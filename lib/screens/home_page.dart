import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mustard_kitchen/controller/home_controller.dart';
import 'package:mustard_kitchen/screens/splash_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../utils/constants.dart';
import '../globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;

  handleLoading() {
    Timer(Duration(seconds: 3), () {
      isLoading = false;
      setState(() {});
    });
  }

  // @override
  // void initState() {
  //   handleLoading();
  //   super.initState();
  // }
  // PaymentController paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());

    return Obx(() {
      if (homeController.url.value == '') {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Image.asset('assets/images/splash.jpg'),
          ),
        );
      } else {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x001a1a1a))
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                // Update loading bar.
              },
              onPageStarted: (String url) {
                log('onPageStarted called: $url');
                homeController.isLoading.value = true;
              },
              onPageFinished: (String url) {
                homeController.isLoading.value = false;
                log('onPageFinished called: $url');
              },
              onWebResourceError: (WebResourceError error) {},
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.startsWith(
                    'https://sandbox.sslcommerz.com/EasyCheckOut/testcdef3967e8b1d6a74c7061d283140bc7c95')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(homeController.url.value));
        return SafeArea(
          child: Scaffold(
            backgroundColor: Color(0xFF1a1a1a),
            body: Obx(
              () => Stack(
                children: [
                  WebViewWidget(controller: controller),
                  homeController.isLoading.value
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Image.asset('assets/images/splash.jpg'),
                          ),
                        )
                      : const Stack()
                ],
              ),
            ),
          ),
        );
      }
    });
  }
}
