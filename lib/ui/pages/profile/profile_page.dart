import 'package:buscatelo/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authBloc = context.watch<AuthBloc>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              child: Text(authBloc.displayName.characters.first),
            ),
            const SizedBox(height: 12),
            Text(
              authBloc.displayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (!authBloc.signedIn)
              ElevatedButton(
                onPressed: () => authBloc.signInMock('Guest User'),
                child: const Text('Sign in with Google (mock)'),
              )
            else
              ElevatedButton(
                onPressed: authBloc.signOut,
                child: const Text('Sign out'),
              ),
          ],
        ),
      ),
    );
  }
}
