// lib/auth_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; 

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true;
  bool _needsLogin = false; 
  String _savedPin = '';
  String _enteredPin = '';

  // Controllers for the Login Form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSecurityState();
  }

  Future<void> _checkSecurityState() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String? pin = prefs.getString('user_pin');

    if (!isLoggedIn) {
      // 1. Never logged in. Show Email/Password screen.
      setState(() {
        _needsLogin = true;
        _isLoading = false;
      });
    } else if (pin == null || pin.isEmpty) {
      // 2. Logged in, but no PIN was ever set in Settings. Let them straight in.
      _navigateToHome();
    } else {
      // 3. Logged in AND has a PIN. Show the Quick Access Keypad.
      setState(() {
        _savedPin = pin;
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BudgetHomePage()),
      );
    }
  }

  // --- LOGIN LOGIC ---
  Future<void> _performLogin() async {
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      // In a real app, this is where you check Firebase/Supabase.
      // For now, we mock a successful login.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      // Clear the text fields
      _emailController.clear();
      _passwordController.clear();
      
      // Re-run the security check. If they have a PIN, it asks for it. 
      // If not, it lets them in.
      _checkSecurityState(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email and password'), backgroundColor: Colors.redAccent),
      );
    }
  }

  // --- KEYPAD LOGIC ---
  void _onKeyPress(String value) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += value);
      if (_enteredPin.length == 4) {
        if (_enteredPin == _savedPin) {
          _navigateToHome();
        } else {
          setState(() => _enteredPin = '');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect PIN'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  // --- UI RENDERERS ---
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: _needsLogin ? _buildLoginForm() : _buildPinPad(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.account_balance_wallet, size: 80, color: Color(0xFF00E676)),
          const SizedBox(height: 24),
          const Text('VAULT', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.white)),
          const Text('Secure Financial Tracker', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 48),
          
          TextField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.email, color: Color(0xFF00E676)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00E676)), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.lock, color: Color(0xFF00E676)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade800), borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF00E676)), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _performLogin,
            child: const Text('SECURE LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildPinPad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_outline, size: 64, color: Color(0xFF00E676)),
        const SizedBox(height: 16),
        const Text('ENTER PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.white)),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16, height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _enteredPin.length ? const Color(0xFF00E676) : Colors.grey.shade800,
              ),
            );
          }),
        ),
        const SizedBox(height: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: GridView.count(
            shrinkWrap: true, crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 1.2,
            children: [
              for (var i = 1; i <= 9; i++) _buildKeypadButton(i.toString()),
              TextButton(
                onPressed: () async {
                  // EMERGENCY LOGOUT: Clears session token so they can log in as a different user
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('isLoggedIn');
                  setState(() => _needsLogin = true);
                },
                child: const Text('LOGOUT', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              _buildKeypadButton('0'),
              IconButton(onPressed: _onBackspace, icon: const Icon(Icons.backspace, color: Colors.grey, size: 28)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String text) {
    return TextButton(
      onPressed: () => _onKeyPress(text),
      style: TextButton.styleFrom(shape: const CircleBorder(), backgroundColor: const Color(0xFF1E1E1E)),
      child: Text(text, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
