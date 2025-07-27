import 'package:flutter/material.dart';

void main() {
  runApp(const SignUpPage());
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SignUp(),
    );
  }
}

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black38,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'Sign up and simplify crypto bookkeeping and invoicing.',
                  style: TextStyle(fontSize: 13, color: Colors.white),
                ),
                const SizedBox(height: 30),
                // Input Fields
                buildInputField('Business Name'),
                const SizedBox(height: 16),
                buildInputField('Username'),
                const SizedBox(height: 16),
                buildInputField('Email'),
                const SizedBox(height: 24),
                buildInputField('Password'),
                const SizedBox(height: 24),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Divider with OR
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.white60, // 👈 change this to any color you want
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white60)),
                  ],
                ),
                const SizedBox(height: 20),
                // Social Buttons
                buildSocialButton(
                  iconUrl: 'https://img.icons8.com/?size=100&id=Oi106YG9IoLv&format=png&color=000000',
                  text: 'Connect Metamask',
                  color: const Color(0xFF1A1A2E),
                ),

                const SizedBox(height: 30),
                // Login redirect
                Center(
                  child: RichText(
                    text: const TextSpan(
                      text: 'Already have an Account? ',
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable text input
  Widget buildInputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Reusable social button
  Widget buildSocialButton({
    IconData? icon,
    String? iconUrl,
    required String text,
    required Color color,
    MainAxisAlignment alignment = MainAxisAlignment.start
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: alignment,
          children: [
            if (iconUrl != null)
              Image.network(
                iconUrl,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.error,
                  size: 24,
                ),
              )
            else
              Icon(
                icon ?? Icons.error,
                color: Colors.white,
                size: 24,
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}