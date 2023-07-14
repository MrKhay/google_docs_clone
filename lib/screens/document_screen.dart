import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/colors.dart';
import 'package:google_docs_clone/common/loader.dart';
import 'package:google_docs_clone/models/document_model.dart';
import 'package:google_docs_clone/models/error_model.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/repository/document_repository.dart';
import 'package:google_docs_clone/repository/socket_repository.dart';
import 'package:google_docs_clone/utility/utility.dart';
import 'package:routemaster/routemaster.dart';

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
  quill.QuillController? quillController;
  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();

    // leaving room
    socketRepository.existingRoom(<String, dynamic>{
      'room': widget.id,
    });
  }

  @override
  void initState() {
    super.initState();

    fetchDocumentData();
    socketRepository.joinRoom(widget.id);

    socketRepository.changeListener((data) {
      try {
        quillController?.compose(
          quill.Delta.fromJson(data['delta']),
          quillController?.selection ??
              const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE,
        );

        quillController?.moveCursorToEnd();
      } catch (e) {
        e.logError();
      }
    });

// update document title
    socketRepository.updatedDocumentTitle((data) {
      try {
        var value = data['title'];
        titleController.text = value;
      } catch (e) {
        e.logError();
      }
    });

// auto saves every 2 seconds
    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': quillController!.document.toDelta(),
        'room': widget.id,
      });
    });
  }

  void fetchDocumentData() async {
    errorModel = await ref
        .read(documentRepositoryProvider)
        .getDocumentById(ref.read(userProvider)!.token, widget.id);

    if (errorModel!.data != null) {
      titleController.text = (errorModel!.data as DocumentModel).title;

      quillController = quill.QuillController(
        document: errorModel!.data.content.isEmpty
            ? quill.Document()
            : quill.Document.fromDelta(
                quill.Delta.fromJson(errorModel!.data.content),
              ),
        selection: const TextSelection.collapsed(offset: 0),
      );

      setState(() {});
    }

    quillController!.document.changes.listen((event) {
      if (event.source == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.change,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
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
    if (quillController == null) {
      return const Scaffold(body: Loader());
    }
    quillController?.moveCursorToEnd();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(
                        text: 'http://localhost:3000/#/document/${widget.id}'))
                    .then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Linked copied!'),
                    ),
                  );
                });
              },
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
              GestureDetector(
                  onTap: () {
                    Routemaster.of(context).replace('/');
                  },
                  child:
                      Image.asset('assets/images/docs-logo.png', height: 40)),
              const SizedBox(width: 10),
              SizedBox(
                  width: 180,
                  child: TextField(
                    controller: titleController,
                    onSubmitted: (value) => updateTitle(ref, value),
                    onChanged: (data) {
                      socketRepository.updatingTitle(<String, dynamic>{
                        'room': widget.id,
                        'title': data,
                      });
                    },
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
          quill.QuillToolbar.basic(controller: quillController!),
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
                      controller: quillController!,
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
