import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pubapp/home.dart';
import 'utils.dart';
import 'connection.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscureText = true; // Initially obscure the text

  String _errorMsg = "";
  bool _hideError = true;

  void _showErrorMessage() {
    setState(() {
      _hideError = false;
    });
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
          padding: EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 20,
          ),
          color: DEFAULT_BLACK,
          alignment: Alignment.center,
          child: Column(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              getTitleText("Login"),

              getInputField("Username", usernameController, false),
              getInputField("Password", passwordController, true),

              Offstage(
                offstage: _hideError,
                child: Text("Error: $_errorMsg",
                  style: TextStyle(
                    color: DEFAULT_RED,
                  ),
                ),
              ),

              Column(
                spacing: 10,
                children: [
                  getButton("Login", DEFAULT_ORANGE, login_attempt, context),

                  Text("or",
                    style: TextStyle(
                      color: DEFAULT_WHITE,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  getButton("Register", Colors.deepOrangeAccent, goToRegisterPage, context),
                ],
              )

            ],
          ),
        ),
      )

    );
  }

  TextField getInputField(String text, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscureText,
      style: TextStyle(
          color: DEFAULT_WHITE,
      ),
      cursorColor: DEFAULT_WHITE,
      decoration: InputDecoration(
          hintText: text,
          labelText: text,
          labelStyle: TextStyle(
              color: DEFAULT_GREY,
          ),
          focusColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: DEFAULT_GREY)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: DEFAULT_WHITE)
          ),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: DEFAULT_WHITE,
            ),
            onPressed: _toggleVisibility,
          ) : SizedBox.shrink()
      ),
    );
  }



    Future<void> login_attempt() async {

    await login(usernameController.text, passwordController.text).then((onValue) {
      if(onValue) {
        getProfile().then((value) {
          Navigator.pop(context);
        });
      } else {
        setState(() {
          //Error Message
          _errorMsg = "Invalid Username or Password";
          _showErrorMessage();

        });
      }
    });

    }

    void goToRegisterPage() async {
      final isRegisterSuccessful = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => RegisterPage()));
      try {
        if(isRegisterSuccessful as bool) {
            Navigator.pop(context); //Skip Login
        }
      } catch(e) {}
    }



}


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String _errorMsg = "";
  bool _obscureText = true; // Initially obscure the text
  bool _hideError = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Toggle the value
    });
  }

  void _showErrorMessage() {
    setState(() {
      _hideError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: getDefaultAppBar(context),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 200,
            alignment: Alignment.center,
            color: DEFAULT_BLACK,
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 25,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                getTitleText("Register"),

                getInputField("Username", usernameController, false),
                getInputField("Full Name", fullNameController, false),
                getInputField("Password", passwordController, true),
                getInputField("Confirm Password", confirmPasswordController, true),

                Offstage(
                  offstage: _hideError,
                  child: Text("Error: $_errorMsg",
                    style: TextStyle(
                      color: DEFAULT_RED,
                    ),
                  ),
                ),



                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text("By clicking register you are declaring you are at least 18 years of age",
                    style: TextStyle(
                      color: DEFAULT_WHITE,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                getButton("Register", DEFAULT_ORANGE, register_btn, context),

              ],
            )
        ),
      )

    );
  }

  Future<void> register_btn() async {

    //Validate Username
    bool isUsernameValid = validateUsername(usernameController.text);
    if(!isUsernameValid) return;

    //Validate Password
    bool isPasswordValid = validatePassword(passwordController.text, confirmPasswordController.text);
    if(!isPasswordValid) return;

    String res = await register(usernameController.text, passwordController.text, fullNameController.text);
    if(res == "Error: Username Taken") {
      _errorMsg = "Username already taken";
      _showErrorMessage();
      return;
    }

    //Get user information


    //Register Successful
    Navigator.pop(context, true);

  }

  bool validateUsername(String username) {
    if(username.length < 4) {
      _errorMsg = "Username too short";
      _showErrorMessage();
      return false;
    }

    if(username.length > 16) {
      _errorMsg = "Username too long";
      _showErrorMessage();
      return false;
    }

    return true;
  }

  bool validatePassword(String password, String confirmPassword) {

    //Password Mismatch
    if(password != confirmPassword) {
      _errorMsg = "Passwords must match";
      _showErrorMessage();
      return false;
    }

    //Password too short
    if(password.length < 5) {
      _errorMsg = "Password must be longer than 6 characters";
      _showErrorMessage();
      return false;
    }

    if(password.length > 16) {
      _errorMsg = "Password too long";
      _showErrorMessage();
      return false;
    }

    return true;
  }

  TextField getInputField(String text, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscureText,
      style: TextStyle(
          color: DEFAULT_WHITE,
      ),
      cursorColor: DEFAULT_WHITE,
      decoration: InputDecoration(
          hintText: text,
          labelText: text,
          labelStyle: TextStyle(
              color: DEFAULT_GREY,
          ),
          focusColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: DEFAULT_GREY)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: DEFAULT_WHITE)
          ),
          suffixIcon: isPassword ? IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: DEFAULT_WHITE,
            ),
            onPressed: _toggleVisibility,
          ) : SizedBox.shrink()
      ),
    );
  }

}


Text getTitleText(String text) {
  return Text(text,
    style: TextStyle(
        color: DEFAULT_WHITE,
        fontWeight: FontWeight.bold,
        fontSize: 32
    ),
  );
}

TextButton getButton(String text, Color color, Function func, BuildContext context) {
  return TextButton(
    style: TextButton.styleFrom(
        backgroundColor: color,
        fixedSize: Size(
            MediaQuery.of(context).size.width,
            50
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        )
    ),

    onPressed: () {
      func();
    },
    child: Text(text,
      style: TextStyle(
        color: DEFAULT_BLACK,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}