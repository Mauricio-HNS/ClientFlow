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
  String _role = 'client';
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
        if (result.role != 'admin') {
          throw Exception('Use uma conta admin para acessar este painel.');
        }
      } else {
        await widget.api.register(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: 'admin',
        );
        final result = await widget.api.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (result.role != 'admin') {
          throw Exception('Use uma conta admin para acessar este painel.');
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
              const Text(
                'Perfil: Admin',
                style: TextStyle(color: ClientFlowPalette.muted),
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
            const SizedBox(height: 20),
            const _DemoCredentials(
              title: 'Login de teste (Admin)',
              email: 'admin@clientflow.local',
              password: 'admin123',
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoCredentials extends StatelessWidget {
  const _DemoCredentials({
    required this.title,
    required this.email,
    required this.password,
  });

  final String title;
  final String email;
  final String password;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ClientFlowPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ClientFlowPalette.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: ClientFlowPalette.deepest,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Email: $email',
            style: const TextStyle(color: ClientFlowPalette.muted),
          ),
          Text(
            'Senha: $password',
            style: const TextStyle(color: ClientFlowPalette.muted),
          ),
        ],
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

class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.role, required this.onChanged});

  final String role;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perfil',
          style: TextStyle(color: ClientFlowPalette.muted),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            _RoleChip(
              label: 'Cliente',
              value: 'client',
              selected: role == 'client',
              onTap: () => onChanged('client'),
            ),
            _RoleChip(
              label: 'Salao',
              value: 'salon',
              selected: role == 'salon',
              onTap: () => onChanged('salon'),
            ),
            _RoleChip(
              label: 'Admin',
              value: 'admin',
              selected: role == 'admin',
              onTap: () => onChanged('admin'),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ClientFlowPalette.accent : ClientFlowPalette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ClientFlowPalette.surfaceBorder),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: ClientFlowPalette.glow.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? ClientFlowPalette.deepest
                : ClientFlowPalette.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
