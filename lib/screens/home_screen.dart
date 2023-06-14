import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/common/loader.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/repository/document_repository.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackBar = ScaffoldMessenger.of(context);
    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackBar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void navigateToDocument(BuildContext context, String documentId) {
    final navigator = Routemaster.of(context);

    navigator.push('/document/$documentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () => createDocument(context, ref),
                icon: const Icon(Icons.add)),
            IconButton(
                onPressed: () => signOut(ref),
                icon: const Icon(
                  Icons.logout,
                  color: kRedColor,
                )),
          ],
        ),
        body: FutureBuilder<ErrorModel>(
          future: ref
              .watch(documentRepositoryProvider)
              .getDocument(ref.watch(userProvider)!.token),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.data.length,
                itemBuilder: (context, index) {
                  DocumentModel documentModel = snapshot.data!.data[index];
                  return InkWell(
                    onTap: () => navigateToDocument(context, documentModel.id),
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                          child: Text(
                            documentModel.title,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ));
  }
}
