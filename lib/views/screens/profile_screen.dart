import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:resonate/controllers/auth_state_controller.dart';
import 'package:resonate/themes/theme_controller.dart';
import 'package:resonate/utils/colors.dart';
import 'package:resonate/utils/ui_sizes.dart';
import 'package:resonate/views/widgets/color_selection_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/email_verify_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/constants.dart';
import '../widgets/custom_card.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({final Key? key}) : super(key: key);

  final emailVerifyController =
      Get.put<EmailVerifyController>(EmailVerifyController());
  final authStateController =
      Get.put<AuthStateController>(AuthStateController());

  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthStateController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
          ),
          actions: [
            Row(
              children: [
                InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () async {
                      await authStateController.logout(context);
                    },
                    child: Icon(
                      Icons.logout_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                const SizedBox(
                  width: 20,
                ),
              ],
            )
          ],
        ),
        body: Obx(
          () => Center(
              child: Stack(children: [
            controller.isInitializing.value
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                        child: LoadingAnimationWidget.threeRotatingDots(
                            color: Colors.red, size: Get.pixelRatio * 20)),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: UiSizes.height_45,
                        ),
                        Container(
                          width: UiSizes.width_180,
                          height: UiSizes.height_180,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: themeController.primaryColor.value,
                                width: UiSizes.width_4),
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  controller.profileImageUrl ?? ''),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    emailVerifyController.isExpanded.value =
                                        !(emailVerifyController
                                            .isExpanded.value);
                                    if (emailVerifyController
                                            .isExpanded.value ==
                                        false) {
                                      emailVerifyController
                                          .shouldDisplay.value = false;
                                    }
                                  },
                                  child: AnimatedContainer(
                                      onEnd: () {
                                        if (emailVerifyController
                                                .isExpanded.value ==
                                            true) {
                                          emailVerifyController
                                              .shouldDisplay.value = true;
                                        }
                                      },
                                      width:
                                          emailVerifyController.isExpanded.value
                                              ? UiSizes.width_170
                                              : UiSizes.width_35,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: Colors.white),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: controller.isEmailVerified!
                                          ? Row(
                                              mainAxisAlignment:
                                                  emailVerifyController
                                                          .isExpanded.value
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment
                                                          .center,
                                              children: [
                                                Icon(
                                                  Icons.verified_rounded,
                                                  color: AppColor.greenColor,
                                                  size: UiSizes.size_32,
                                                ),
                                                emailVerifyController
                                                        .shouldDisplay.value
                                                    ? SizedBox(
                                                        width: UiSizes.width_5,
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      ),
                                                emailVerifyController
                                                        .shouldDisplay.value
                                                    ? Text(
                                                        "Email Verified",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              UiSizes.size_15,
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      )
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  emailVerifyController
                                                          .isExpanded.value
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment
                                                          .center,
                                              children: [
                                                Expanded(
                                                  child: Icon(
                                                    Icons.cancel_rounded,
                                                    color: Colors.red,
                                                    size: UiSizes.size_35,
                                                  ),
                                                ),
                                                emailVerifyController
                                                        .shouldDisplay.value
                                                    ? SizedBox(
                                                        width: UiSizes.width_10,
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      ),
                                                emailVerifyController
                                                        .shouldDisplay.value
                                                    ? Text(
                                                        "Verify Email",
                                                        style: TextStyle(
                                                            fontSize:
                                                                UiSizes.size_15,
                                                            color:
                                                                Colors.black),
                                                      )
                                                    : const SizedBox(
                                                        height: 0,
                                                        width: 0,
                                                      )
                                              ],
                                            )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: UiSizes.height_20),
                        SizedBox(
                          width: UiSizes.width_320,
                          height: UiSizes.height_55,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              "@ ${controller.userName}",
                              style: TextStyle(
                                  fontSize: UiSizes.size_35,
                                  color: themeController.primaryColor.value),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: UiSizes.width_320,
                          height: UiSizes.height_40,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              controller.displayName.toString(),
                              style: TextStyle(fontSize: UiSizes.size_40),
                            ),
                          ),
                        ),
                        SizedBox(height: UiSizes.height_20),
                        !(controller.isEmailVerified!)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Material(
                                  child: InkWell(
                                    highlightColor:
                                        const Color.fromARGB(138, 33, 140, 14),
                                    splashColor:
                                        const Color.fromARGB(172, 43, 174, 20),
                                    onTap: () => {
                                      emailVerifyController.isSending.value =
                                          true,
                                      emailVerifyController.sendOTP()
                                    },
                                    child: Ink(
                                        height: UiSizes.height_40,
                                        width: UiSizes.width_140,
                                        decoration: BoxDecoration(
                                            color: themeController
                                                .primaryColor.value,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: themeController
                                                    .primaryColor.value,
                                                width: 3)),
                                        child: Center(
                                          child: Text(
                                            "Verify Email",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: UiSizes.size_14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        SizedBox(height: UiSizes.height_20),
                        ColorSelectionWidget(
                          themeController: themeController,
                        ),
                        SizedBox(
                          height: UiSizes.height_10,
                        ),
                        CustomCard(
                          title: "Edit Profile",
                          icon: FontAwesomeIcons.userPen,
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.editProfile);
                          },
                        ),
                        SizedBox(height: UiSizes.height_10),
                        CustomCard(
                          title: "Contribute to the project",
                          icon: FontAwesomeIcons.github,
                          onTap: () {
                            Uri url = Uri.parse(githubRepoUrl);
                            try {
                              launchUrl(url);
                            } catch (e) {
                              log("Error launching URL: ${e.toString()}");
                            }
                          },
                        ),
                        SizedBox(height: UiSizes.height_10),
                        CustomCard(
                          title: "Terms and Conditions",
                          icon: FontAwesomeIcons.fileInvoice,
                          onTap: () {
                            //TODO: Launch URL in webView
                          },
                        ),
                        SizedBox(height: UiSizes.height_10),
                        CustomCard(
                          title: "Privacy Policy",
                          icon: FontAwesomeIcons.shieldHalved,
                          onTap: () {
                            //TODO: Launch URL in webView
                          },
                        ),
                        SizedBox(height: UiSizes.height_10),
                        CustomCard(
                          title: "Settings",
                          icon: FontAwesomeIcons.gear,
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.settings),
                        ),
                        SizedBox(
                          height: UiSizes.height_10,
                        ),
                      ],
                    ),
                  ),
            emailVerifyController.isSending.value
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Center(
                        child: LoadingAnimationWidget.threeRotatingDots(
                            color: Colors.blue, size: Get.pixelRatio * 20)),
                  )
                : const SizedBox(),
          ])),
        ),
      ),
    );
  }
}
