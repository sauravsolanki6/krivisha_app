import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:krivisha_app/view/signUpOtp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/login/login_controller.dart';
import '../../utility/app_colors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();
  final controller = Get.put(LoginController());
  final formKey = GlobalKey<FormState>();
  late TextEditingController mobileController;
  late TextEditingController passwordController;
  late FocusNode mobileFocusNode;
  late FocusNode passwordFocusNode;
  bool _obscureText = true;
  @override
  void initState() {
    super.initState();
    mobileController = TextEditingController(
      text: controller.mobileNumber.value,
    );
    passwordController = TextEditingController(text: controller.password.value);
    mobileFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    controller.mobileNumber.listen((value) {
      if (mobileController.text != value) {
        mobileController.text = value;
      }
    });
    controller.password.listen((value) {
      if (passwordController.text != value) {
        passwordController.text = value;
      }
    });
  }

  @override
  void dispose() {
    mobileController.dispose();
    passwordController.dispose();
    mobileFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Start Your Safe Journey!',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
              const SizedBox(height: 5),
              const Row(
                children: [
                  Text(
                    'Login your account',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              TextFormField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                decoration: const InputDecoration(
                  hintText: 'Enter Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  if (value.length < 10) {
                    return 'Mobile number must be 10 digits';
                  }
                  return null;
                },
                onChanged: (value) {
                  controller.mobileNumber.value = value;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: passwordController,
                keyboardType: TextInputType.visiblePassword,

                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.error),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter password';
                  }
                  return null;
                },
                onChanged: (value) {
                  controller.password.value = value;
                },
              ),
              SizedBox(height: screenHeight * 0.05),

              GestureDetector(
                onTap: () {
                  final isValid = _formKey.currentState!.validate();
                  if (isValid) {
                    controller.login(context);
                  } else {}
                },
                child: Container(
                  margin: const EdgeInsets.all(0.0),
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Center(
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
