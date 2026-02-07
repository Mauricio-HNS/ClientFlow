import 'package:flutter/material.dart';

import '../api/clientflow_api.dart';
import '../theme/clientflow_palette.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.api, required this.onAuthenticated});

  final ClientFlowApi api;
  final VoidCallback onAuthenticated;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
    });

    try {
      if (_isLogin) {
        final result = await widget.api.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (result.role != 'client') {
          throw Exception('Use o app correto para este perfil.');
        }
      } else {
        await widget.api.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        final result = await widget.api.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (result.role != 'client') {
          throw Exception('Use o app correto para este perfil.');
        }
      }

      widget.onAuthenticated();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const _LogoBlock(),
            const SizedBox(height: 32),
            Text(
              _isLogin ? 'Entrar' : 'Criar conta',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: ClientFlowPalette.deepest,
              ),
            ),
            const SizedBox(height: 16),
            _InsetField(
              child: TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(height: 16),
            if (!_isLogin) ...[
              _InsetField(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                ),
              ),
              const SizedBox(height: 16),
              _InsetField(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _InsetField(
              child: TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading
                  ? 'Aguarde...'
                  : _isLogin
                      ? 'Entrar'
                      : 'Cadastrar'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _toggleMode,
              child: Text(
                _isLogin
                    ? 'Nao tem conta? Cadastre-se'
                    : 'Ja tem conta? Entrar',
                style: const TextStyle(color: ClientFlowPalette.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: ClientFlowPalette.accent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: ClientFlowPalette.glow.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome,
              color: ClientFlowPalette.deepest, size: 36),
        ),
        const SizedBox(height: 12),
        const Text(
          'ClientFlow',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ClientFlowPalette.deepest,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Seu horario, sem atrito',
          style: TextStyle(color: ClientFlowPalette.muted),
        ),
      ],
    );
  }
}

class _InsetField extends StatelessWidget {
  const _InsetField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ClientFlowPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: ClientFlowPalette.glow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}
