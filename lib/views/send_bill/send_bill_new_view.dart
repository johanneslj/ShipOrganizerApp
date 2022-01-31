import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as eos;
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Class for the new bill tab in the send_bill_view
/// This class is responsible for the creation of a new bill for
/// confirmation. The class uses dropdown menu and image uploader
class newBill extends StatefulWidget {
  const newBill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _newBill();
}

class _newBill extends State<newBill> {
  String selectedValue = "Bridge";
  bool admin = false;
  late File? _image =null;

  _imgFromCamera() async {
    final image = (await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50));
    if (image == null) return;
    setState(() {
      _image = File(image.path);
    });
  }

  _imgFromGallery() async {
    final image = (await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50));

    if (image == null) return;
    setState(() {
      _image = File(image.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const Text("Select a department"),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField(
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                ),
                validator: (value) =>
                    value == null ? "Select a Department" : null,
                dropdownColor: Theme.of(context).colorScheme.background,
                value: selectedValue,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
                items: dropdownItems),
          ],
        ),
        _image != null
            ? Image.file(_image!, width: 200, height: 300, fit: BoxFit.cover)
            : const Text("No Photo"),
        ElevatedButton(
            child: Text(
              "Upload image",
              style: Theme.of(context).textTheme.headline6,
            ),
            onPressed: () => {_showPicker(context)}),
        ElevatedButton(
            child: Text(
              "Submit",
              style: Theme.of(context).textTheme.headline6,
            ),
            onPressed: () => {submitToServer()}),
      ],
    ));
  }

  ///Creates the menu items based on the department list
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = <DropdownMenuItem<String>>[];
    for (String department in getDepartments()) {
      DropdownMenuItem<String> departmentCard = DropdownMenuItem(
        child: Text(department),
        value: department,
      );
      menuItems.add(departmentCard);
    }
    return menuItems;
  }

  //Gets the departments from the backend server
  List<String> getDepartments(){
    List<String> departments = <String>["Bridge", "Factory", "Deck"];

    return departments;

  }

  //Creates the picker for the user to choose between the gallery and the camera
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const IconTheme(
                        data: IconThemeData(color: Colors.white),
                        child: Icon(Icons.photo_library_sharp)),
                    title: Text('Photo Library',
                        style: Theme.of(context).textTheme.headline6),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const IconTheme(
                      data: IconThemeData(color: Colors.white),
                      child: Icon(Icons.photo_camera_sharp),),
                  title: Text('Camera',
                      style: Theme.of(context).textTheme.headline6),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  /// Method to submit the selected department and image to the backend server
  void submitToServer() {
    Codec stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(_image!.absolute.toString());
    String fileName = p.basename(_image!.path);
    //Send this to backend server
    log('selectedValue: $selectedValue encoded image: $encoded FileName: $fileName');
  }
}
