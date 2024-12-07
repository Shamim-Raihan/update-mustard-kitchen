import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:mustard_kitchen/controller/home_controller.dart';
import 'package:mustard_kitchen/screens/notification_page.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    initOneSignal();
    super.initState();
  }

  initOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("3d8bd2fc-32d7-4aa6-a95d-39a74fa1992e");

    OneSignal.Notifications.requestPermission(true);
    String? onesignalId = await OneSignal.User.getOnesignalId();
    log('OneSignal id : $onesignalId');

    OneSignal.InAppMessages.addClickListener((event) {
      log('message${event.message.jsonRepresentation()}');
    });

    OneSignal.Notifications.addClickListener((event) {
      log('notification${event.notification.jsonRepresentation()}');
      log('url : ${event.notification.additionalData!["url"]}');
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ShowNotification(
              notificationUrl: event.notification.additionalData!["url"]);
        },
      ));
    });

    if (Platform.isAndroid) {
      homeController.url.value =
          'https://apps.mustardindian.com/?platform=android&token=$onesignalId';
      log('Android url : ${homeController.url.value}');
    }
    if (Platform.isIOS) {
      homeController.url.value =
          'https://apps.mustardindian.com/?platform=ios&token=$onesignalId';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                if (request.url.startsWith('https://www.google.com')) {
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(homeController.url.value));
        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color(0xFF1a1a1a),
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
