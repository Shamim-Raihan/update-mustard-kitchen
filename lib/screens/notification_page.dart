import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:mustard_kitchen/controller/home_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../globals.dart' as globals;

class ShowNotification extends StatefulWidget {
  final String notificationUrl;
  const ShowNotification({Key? key, required this.notificationUrl}) : super(key: key);

  @override
  State<ShowNotification> createState() => _ShowNotificationState();
}

class _ShowNotificationState extends State<ShowNotification> {
  @override
  void initState() {
    log('noti : ${widget.notificationUrl}');
    globals.weblink = widget.notificationUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x001a1a1a))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            homeController.isLoading.value = true;
          },
          onPageFinished: (String url) {
            homeController.isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(globals.weblink));
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: SafeArea(
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
      ),
    );
  }
}
