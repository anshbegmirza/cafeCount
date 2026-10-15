import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/widgets/hr_widgets.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _id = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() {
    _id.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: HrColors.mist,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset('assets/images/logo.png', width: 120, height: 120, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'appName'.tr(),
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: HrColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('tagline'.tr(), style: const TextStyle(color: HrColors.muted, fontSize: 15)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _id,
                    decoration: InputDecoration(labelText: 'identifier'.tr()),
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    decoration: InputDecoration(labelText: 'password'.tr()),
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!, style: const TextStyle(color: HrColors.out, fontSize: 15)),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: auth.loading ? null : _submit,
                    child: auth.loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: HrColors.cream),
                          )
                        : Text('login'.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final ok = await ref.read(authProvider.notifier).login(_id.text.trim(), _pass.text);
    if (!ok && mounted) {
      showHrToast(context, title: 'loginFailed'.tr(), success: false);
    }
  }
}
