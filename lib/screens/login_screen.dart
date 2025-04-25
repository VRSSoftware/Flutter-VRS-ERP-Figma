import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:vrs_erp_figma/constants/app_constants.dart';
import 'package:vrs_erp_figma/screens/home_screen.dart';
import 'package:vrs_erp_figma/screens/register_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Map<String, dynamic>? _selectedCompany;
  Map<String, dynamic>? _selectedYear;

  final List<Map<String, dynamic>> _companies = [];
  final List<Map<String, dynamic>> _years = [];

  bool _isLoadingCompanies = true;

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _companyFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? isRegistered;
  @override
  void initState() {
    super.initState();
    _checkPreferences();
    _fetchCompanies();
    _fetchFinancialYears();
  }

  Future<void> _checkPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isRegistered = prefs.getString('isRegistered');
    });
  }

  Future<void> _fetchCompanies() async {
    final url = '${AppConstants.BASE_URL}/users/cobr';
    try {
      final response = await http.get(Uri.parse(url));
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _companies.clear();
          _companies.addAll(
            data.map((e) => e as Map<String, dynamic>).toList(),
          );
          _isLoadingCompanies = false;
        });
      } else {
        print("Failed to load companies");
        setState(() {
          _isLoadingCompanies = false;
        });
      }
    } catch (e) {
      print('Error fetching companies: $e');
      setState(() {
        _isLoadingCompanies = false;
      });
    }
  }

  Future<void> _fetchFinancialYears() async {
    final url = '${AppConstants.BASE_URL}/users/fcyr';
    try {
      final response = await http.get(Uri.parse(url));
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _years.clear();
          _years.addAll(data.map((e) => e as Map<String, dynamic>).toList());
        });
      } else {
        print("Failed to load financial years");
      }
    } catch (e) {
      print('Error fetching financial years: $e');
    }
  }

  Future<void> login(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? isRegistered = prefs.getString('isRegistered');
    if (isRegistered == '1') {
      if (_formKey.currentState?.validate() ?? false) {
        final url = '${AppConstants.BASE_URL}/users/login';

        final Map<String, String> headers = {
          'Content-Type': 'application/json',
        };

        final Map<String, String> body = {
          'userName': _usernameController.text.trim(),
          'userPwd': _passwordController.text.trim(),
        };

        print(body.toString());

        try {
          final response = await http.post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          );

          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");

          if (response.statusCode == 200) {
            final Map<String, dynamic> responseData = json.decode(
              response.body,
            );
            print(_selectedCompany?["coBrId"]);
            print(responseData?["userId"]);

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('coBrId', _selectedCompany?["coBrId"]);
            await prefs.setInt('userId', responseData?["userId"]);

            if (responseData.containsKey('userName') &&
                responseData['userName'] == _usernameController.text.trim()) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            } else {
              _showPopupMessage(context, "Invalid Username or Password");
            }
          } else {
   
            final Map<String, dynamic> errorResponse = json.decode(
              response.body,
            );
            String errorMessage =
                errorResponse['errorMessage'] ?? "An error occurred";

            if (errorMessage.contains('Invalid UserName')) {
              _showPopupMessage(context, "Invalid Username");
            } else if (errorMessage.contains('Invalid Password')) {
              _showPopupMessage(context, "Invalid Password");
            } else {
              _showPopupMessage(context, errorMessage);
            }
          }
        } catch (e) {
          print('Error: $e');
          _showPopupMessage(context, "An error occurred. Please try again.");
        }
      } else {
        if (_usernameController.text.isEmpty) {
          _usernameFocus.requestFocus();
        } else if (_passwordController.text.isEmpty) {
          _passwordFocus.requestFocus();
        } else if (_selectedCompany == null) {
          _companyFocus.requestFocus();
        } else if (_selectedYear == null) {
          _yearFocus.requestFocus();
        }
      }
    } else {
      _showPopupMessage(
        context,
        "You have to register first. Device not registerd",
      );
    }
  }

  void _showPopupMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Failed"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _companyFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics:
                  constraints.maxHeight < 600
                      ? AlwaysScrollableScrollPhysics()
                      : NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              "assets/images/background.png",
                              width: double.infinity,
                              height: constraints.maxHeight * 0.23,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              bottom: -40,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: ClipOval(
                                  child: Image.asset(
                                    "assets/images/new_logo.png",
                                    width: 300,
                                    height: 350,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Text(
                                "Login Now",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildTextField(
                                "User",
                                "Enter your username",
                                controller: _usernameController,
                                focusNode: _usernameFocus,
                                nextFocus: _passwordFocus,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Username is required'
                                            : null,
                              ),
                              _buildTextField(
                                "Password",
                                "Enter your password",
                                obscureText: true,
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                nextFocus: _companyFocus,
                                validator:
                                    (value) =>
                                        value == null || value.isEmpty
                                            ? 'Password is required'
                                            : null,
                              ),
                              _buildDropdown(
                                "Company",
                                "Select your Company",
                                items: _companies,
                                value: _selectedCompany,
                                focusNode: _companyFocus,
                                nextFocus: _yearFocus,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCompany = val;
                                  });
                                },
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Please select a company'
                                            : null,
                              ),
                              _buildDropdown(
                                "Year",
                                "Select Year",
                                items: _years,
                                value: _selectedYear,
                                focusNode: _yearFocus,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedYear = val;
                                  });
                                },
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Please select a year'
                                            : null,
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(
                                    colors: [AppColors.violet, AppColors.slateGray],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    login(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Text(
                                    "Log in",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              isRegistered == '1'
                                  ? Container()
                                  : TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => RegisterScreen(),
                                        ),
                                      );
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: "New user? ",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "Register here",
                                            style: TextStyle(
                                              color: AppColors.violet,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    bool isLastField = false,
    TextInputAction textInputAction = TextInputAction.next,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 2),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            textInputAction: textInputAction,
            onFieldSubmitted: (value) {
              if (!isLastField) {
                nextFocus?.requestFocus();
              } else {
                focusNode?.unfocus();
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 3.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 2.0),
              ),
              errorStyle: TextStyle(height: 0.7),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String hint, {
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic>? value,
    required Function(Map<String, dynamic>?) onChanged,
    String? Function(Map<String, dynamic>?)? validator,
    FocusNode? focusNode,
    FocusNode? nextFocus,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 2),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: value,
            focusNode: focusNode,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 3.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.violet, width: 2.0),
              ),
              errorStyle: TextStyle(height: 0.7),
            ),
            hint: Text(hint, overflow: TextOverflow.ellipsis),
            items:
                items.map((item) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: item,
                    child: Text(
                      item.containsKey('coBr_name')
                          ? item['coBr_name']
                          : item['fcYrName'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (val) {
              onChanged(val);
              if (nextFocus != null) {
                nextFocus.requestFocus();
              }
            },
            validator: validator,
          ),
        ],
      ),
    );
  }
}
