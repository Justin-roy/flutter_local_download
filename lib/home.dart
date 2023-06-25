import 'package:flutter/material.dart';
import 'package:flutter_local_download/local_download.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final LocalDownload _ld = LocalDownload();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flutter Local Download',
          style: textTheme.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextFormField(
                controller: _controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter url here';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Type url here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ),
            (_ld.imageBytes == null)
                ? const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 200,
                    ),
                  )
                : InkWell(
                    onTap: () async {
                      _ld.openFileLocation(_ld.filePath!);
                    },
                    child: Center(
                      child: _ld.isImageUrl
                          ? Image.memory(
                              _ld.imageBytes!,
                              height: 220,
                            )
                          : const Icon(
                              Icons.file_copy_outlined,
                              size: 200,
                            ),
                    ),
                  ),
            const SizedBox(height: 15),
            FilledButton.tonal(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _ld.downloadFileToLocalStorage(context,
                      url: _controller.text.trim());
                  setState(() {});
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Download',
                  style: textTheme.titleSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
