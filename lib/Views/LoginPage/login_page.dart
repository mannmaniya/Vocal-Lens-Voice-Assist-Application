import 'package:flexify/flexify.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vocal_lens/Controllers/auth_controller.dart';
import 'package:vocal_lens/Views/HomePage/home_page.dart';
import 'package:vocal_lens/Views/RegistrationPage/registration_page.dart';
import 'package:vocal_lens/Widgets/auth_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthController authController =
        Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(context, authController),
    );
  }

  // 🔹 App Bar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        tr("login_title"),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: DropdownButton<Locale>(
            dropdownColor: Colors.grey[900],
            icon: const Icon(Icons.language, color: Colors.white),
            underline: Container(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.setLocale(newLocale);
              }
            },
            items: [
              _buildDropdownItem('English', const Locale('en', 'US')),
              _buildDropdownItem('Español', const Locale('es', 'ES')),
              _buildDropdownItem('German', const Locale('de', 'DE')),
              _buildDropdownItem('Hindi', const Locale('hi', 'IN')),
              _buildDropdownItem('Français', const Locale('fr', 'FR')),
              _buildDropdownItem('Dutch', const Locale('nl', 'NL')),
            ],
          ),
        ),
      ],
    );
  }

  // 🔹 Body UI
  Widget _buildBody(BuildContext context, AuthController authController) {
    return Stack(
      children: [
        // Main UI
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              'welcome_back'.tr(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            buildTextFormField(
                              context: context,
                              controller: emailController,
                              label: 'email'.tr(),
                              icon: Icons.email,
                            ),
                            const SizedBox(height: 16),
                            buildTextFormField(
                              context: context,
                              controller: passwordController,
                              label: 'password'.tr(),
                              icon: Icons.lock,
                              isPassword: true,
                            ),
                            const SizedBox(height: 24),
                            _buildLoginButton(authController),
                            const SizedBox(height: 16),
                            _buildGoogleSignInButton(authController),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'register_prompt'.tr(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 🔹 Loader Overlay (if loading)
        Consumer<AuthController>(
          builder: (context, authController, _) {
            return authController.isLoading
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // 🔹 Login Button
 Widget _buildLoginButton(AuthController authController) {
  return ElevatedButton(
    onPressed: authController.isLoading
        ? null // Disable button while loading
        : () async {
            if (formKey.currentState!.validate()) {
              try {
                authController.setLoading(true); // Start loader

                await authController.signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );

                Fluttertoast.showToast(
                  msg: 'login_successful'.tr(),
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );

                Flexify.goRemove(
                  const HomePage(),
                  animation: FlexifyRouteAnimations.fade,
                  duration: Durations.medium1,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'login_failed'.tr(),
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              } finally {
                authController.setLoading(false); // Stop loader
              }
            }
          },
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.2),
      elevation: 5,
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return Colors.blueGrey.shade700;
        }
        return Colors.transparent;
      }),
    ),
    child: authController.isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
        : Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'login_title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
  );
}



  // 🔹 Google Sign-In Button
  Widget _buildGoogleSignInButton(AuthController authController) {
    return ElevatedButton(
      onPressed: authController.isLoading
          ? null // Disable button while loading
          : () async {
              try {
                authController.setLoading(true); // Start loader

                await authController.signInWithGoogle();

                Fluttertoast.showToast(
                  msg: 'google_sign_in_success'.tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                );

                Flexify.goRemove(
                  const HomePage(),
                  animation: FlexifyRouteAnimations.blur,
                  duration: Durations.medium1,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: 'google_sign_in_failed'.tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
              } finally {
                authController.setLoading(false); // Stop loader
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 10,
      ),
      child: authController.isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.google,
                  color: Colors.red,
                ),
                SizedBox(width: 10),
                Text(
                  "Sign in with Google",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  // 🔹 Dropdown Helper Function
  DropdownMenuItem<Locale> _buildDropdownItem(String language, Locale locale) {
    return DropdownMenuItem(
      value: locale,
      child: Text(
        language,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
