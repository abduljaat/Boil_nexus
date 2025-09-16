import 'package:flutter/material.dart';

// Changed to StatelessWidget as state is managed by controllers
class ForgotPasswordScreen extends StatelessWidget {
  final _emailController = TextEditingController(); // Consider disposing if needed, though less critical in StatelessWidget
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A0E21), // Matching theme
      // Removed AppBar, using IconButton for back navigation
      body: SafeArea(
        child: Padding( // Using Padding directly
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 20),
              Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Enter your email to receive a reset link',
                style: TextStyle(color: Colors.white70, fontSize: 16), // Added font size
              ),
              SizedBox(height: 40),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email', // Consistent styling
                    labelStyle: TextStyle(color: Colors.white70),
                    prefixIcon: Icon(Icons.email, color: Colors.white70),
                    filled: true,
                    fillColor: Color(0xFF1D1E33), // Matching theme
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress, // Added keyboard type
                  style: TextStyle(color: Colors.white), // Added text style
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Using previous regex for better validation
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Send reset link logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset link sent to ${_emailController.text}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00E676), // Updated from primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 50), // Set button height
                  padding: EdgeInsets.symmetric(vertical: 16), // Match other buttons
                ),
                 // Match text style from other buttons
                child: Text(
                    'SEND RESET LINK',
                     style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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