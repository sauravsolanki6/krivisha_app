import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krivisha_app/view/signUpOtp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  String errorMessage = "";
  bool validateMobileNumber = true;
  bool _isChecked = true;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData(String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobileNumber', mobileNumber);
    // Note: userId is not set since there's no API response to provide it
  }

  void _getOTP() {
    String mobileNumber = _mobileController.text.trim();

    if (mobileNumber.isEmpty) {
      setState(() {
        validateMobileNumber = false;
        errorMessage = "Mobile number cannot be empty";
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      _saveUserData(mobileNumber);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Proceeding to OTP verification"),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpOTPPage(mobileNumber: mobileNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Create a new account',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                ],
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: 'Enter Mobile Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEC5012)),
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
                  if (value.length == 10) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Flexible(
                    child: Text(
                      'A 6 digit security code will be sent via SMS to verify your mobile number!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 45),
              SizedBox(
                width: double.infinity,
                child: Container(
                  margin: const EdgeInsets.all(0.0),
                  width: 200.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEC5012), Color(0xFFD72B23)],
                    ),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: TextButton(
                    onPressed: _getOTP,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      backgroundColor: Colors.transparent,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Get OTP',
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
