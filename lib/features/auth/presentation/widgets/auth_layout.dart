import 'package:flutter/material.dart';

import 'package:fitness_social_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_form.dart';
import 'package:fitness_social_app/features/auth/presentation/widgets/auth_theme.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.controller,
    required this.onAuthenticated,
    super.key,
  });

  final AuthController controller;
  final VoidCallback onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 980;
            final form = _FormPanel(
              controller: controller,
              onAuthenticated: onAuthenticated,
            );

            if (!isWide) {
              return LayoutBuilder(
                builder: (context, innerConstraints) => SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    24 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: innerConstraints.maxHeight - 48),
                    child: form,
                  ),
                ),
              );
            }

            return Row(
              children: [
                const Expanded(flex: 6, child: _BrandPanel()),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      48,
                      48,
                      48,
                      48 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: form,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.controller, required this.onAuthenticated});

  final AuthController controller;
  final VoidCallback onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RepflowLogo(),
            const SizedBox(height: 42),
            AuthForm(
              controller: controller,
              onAuthenticated: onAuthenticated,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2B08), Color(0xFF080B06), AuthTheme.background],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _RepflowLogo(),
            const Spacer(),
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AuthTheme.lime,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 58,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'تدرّب بذكاء.\nتقدّم مع مجتمعك.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                height: 1.08,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 420,
              child: Text(
                'Repflow يجمع التدريب، الاستمرارية، والمجتمع الرياضي في مكان واحد.',
                style: TextStyle(
                  color: AuthTheme.textMuted,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _RepflowLogo extends StatelessWidget {
  const _RepflowLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'REP',
            style: TextStyle(
              color: AuthTheme.lime,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: 'FLOW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
