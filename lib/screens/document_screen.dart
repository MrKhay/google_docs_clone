import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/repository/document_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'UntitledDocument');
  final quill.QuillController quillController = quill.QuillController.basic();
  ErrorModel? errorModel;
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    quillController.dispose(); 
  }

  @override
  void initState() {
    super.initState();

    fetchDocumentData();
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      setState(() {});
    }
  }

  void updateTitle(WidgetRef ref, String title) async {
    final snackBar = ScaffoldMessenger.of(context);
    ErrorModel errorModel =
        await ref.read(documentRepositoryProvider).updateDocumentTitle(
              token: ref.read(userProvider)!.token,
              id: widget.id,
              title: title,
            );

    if (errorModel.error != null) {
      snackBar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock, size: 16),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlueColor,
              ),
            ),
          )
        ],
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Image.asset('assets/images/docs-logo.png', height: 40),
              const SizedBox(width: 10),
              SizedBox(
                  width: 180,
                  child: TextField(
                    controller: titleController,
                    onSubmitted: (value) => updateTitle(ref, value),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 10),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: kBlueColor,
                        ))),
                  ))
            ],
          ),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: kGrayColor, width: 0.1)),
            )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          quill.QuillToolbar.basic(controller: quillController),
          const SizedBox(height: 20),
          Expanded(
            child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: quillController,
                      readOnly: false,
                    ),
                  ),
                )),
          )
        ],
      ),
    );
  }
}
