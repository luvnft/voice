import 'dart:developer';

import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:resonate/controllers/auth_state_controller.dart';
import 'package:resonate/routes/app_routes.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationController extends GetxController {
  var isLoading = false.obs;
  var isPasswordFieldVisible = false.obs;
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController confirmPasswordController = TextEditingController(text: "");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Client client = Client();
  late final Account account;

  AuthStateContoller authStateController = Get.find<AuthStateContoller>();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registrationFormKey = GlobalKey<FormState>();

  @override
  void onInit() async {
    super.onInit();
    client
        .setEndpoint('http://192.168.1.102/v1')
        .setProject('648c22fd861787e6f32c')
        .setSelfSigned(status: true); // For self signed certificates, only use for development
    account = Account(client);
    // await isUserLoggedIn();
  }

  Future<bool> isUserProfileComplete() async {
    final documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(_auth.currentUser!.uid).get();
    return documentSnapshot.exists;
  }

  // Future<void> isUserLoggedIn() async {
  //   User? firebaseUser = await _auth.currentUser;
  //   if (firebaseUser != null) {
  //     bool isProfileComplete = await isUserProfileComplete();
  //     if (isProfileComplete) {
  //       Get.offNamed(AppRoutes.tabview);
  //     } else {
  //       Get.offNamed(AppRoutes.onBoarding);
  //     }
  //   } else {
  //     return;
  //   }
  // }

  Future<void> login() async {
    if (!loginFormKey.currentState!.validate()) {
      return;
    }
    try {
      isLoading.value = true;
      await authStateController.login(emailController.text, passwordController.text);
      Get.offNamed(AppRoutes.tabview);
    } on AppwriteException catch (e) {
      log(e.toString());
      if (e.type == 'user_invalid_credentials') {
        Get.snackbar(
          'Try Again!',
          "Incorrect Email Or Password",
          icon: const Icon(Icons.disabled_by_default_outlined),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (!registrationFormKey.currentState!.validate()) {
      return;
    }
    try {
      isLoading.value = true;
      // await _auth.createUserWithEmailAndPassword(
      //     email: emailController.text, password: passwordController.text);
      await account.create(userId: ID.unique(), email: emailController.text, password: passwordController.text);
      await account.createEmailSession(email: emailController.text, password: passwordController.text);
      Get.offNamed(AppRoutes.onBoarding);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        Get.offNamed(AppRoutes.onBoarding);
      } else {
        Get.offNamed(AppRoutes.tabview);
      }
    } catch (error) {
      log(error.toString());
    }
  }
}

extension Validator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValidPassword() {
    return RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$').hasMatch(this);
  }

  bool isSamePassword(String password) {
    return this == password;
  }
}
