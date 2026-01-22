import 'package:flutter/material.dart';

class AuthLayout extends StatefulWidget {
  final String title;
  final Widget child;

  const AuthLayout({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  State<AuthLayout> createState() => _AuthLayoutState();
}

class _AuthLayoutState extends State<AuthLayout> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _visible ? 1 : 0,
            child: AnimatedSlide(
              offset: _visible ? Offset.zero: const Offset(0,0.1),
              duration: const Duration(milliseconds: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.location_city,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                widget.child,
              ],
            ),
          ),
        ),
      ),
    ),
    ),
    );
  }
}
