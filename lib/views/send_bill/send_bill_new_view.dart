import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ship_organizer_app/api%20handling/api_controller.dart';

/// Class for the new bill tab in the send_bill_view
/// This class is responsible for the creation of a new bill for
/// confirmation. The class uses dropdown menu and image uploader
class NewBill extends StatefulWidget {
  const NewBill({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _newBill();
}

class _newBill extends State<NewBill> {
  String selectedValue = "";
  bool admin = false;
  late File? _image;

  ApiService apiService = ApiService.getInstance();
  late bool _isLoading = false;

  late List<DropdownMenuItem<String>> dropdownItems = [];

  @override
  void initState() {
    dataLoadFunction();
    _image = null;
    super.initState();
  }

  /// Function to load data when entering the view
  dataLoadFunction() async {
    setState(() {
      _isLoading = true;
    });
    await _setSelectedValue();
    await getDropdownItems();
    setState(() {
      _isLoading = false;
    });
  }

  /// Set the selected value to be active department
  Future<void> _setSelectedValue() async {
    String? department = await apiService.storage.read(key: "activeDepartment");
    setState(() {
      selectedValue = department!;
    });
  }

  /// Gets image which user has taken now
  _imgFromCamera() async {
    final image = (await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50));
    if (image == null) return;
    setState(() {
      _image = File(image.path);
    });
  }

  /// Gets image selected from the gallery
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
    apiService.setContext(context);
    return _isLoading
        ? circularProgress()
        : Scaffold(
            body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(AppLocalizations.of(context)!.selectDepartment),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: DropdownButtonFormField(
                        icon: const IconTheme(
                            data: IconThemeData(color: Colors.black),
                            child: Icon(Icons.arrow_downward_sharp)),
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 1),
                          ),
                        ),
                        validator: (value) => value == null
                            ? AppLocalizations.of(context)!.selectADepartment
                            : null,
                        dropdownColor: Theme.of(context).colorScheme.onPrimary,
                        value: selectedValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedValue = newValue!;
                          });
                        },
                        items: dropdownItems),
                  ),
                ],
              ),
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(_image!,
                          width: 200, height: 300, fit: BoxFit.cover))
                  : Text(AppLocalizations.of(context)!.noPhoto),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.uploadImage,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onPressed: () => {_showPicker(context)}),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context)!.submit,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    onPressed: () =>
                        {submitToServer(), Navigator.of(context).pop()}),
              )
            ],
          ));
  }

  ///Creates the menu items based on the department list
  Future<void> getDropdownItems() async {
    List<DropdownMenuItem<String>> menuItems = <DropdownMenuItem<String>>[];
    List<String> departments = await apiService.getDepartments();
    for (String department in departments) {
      DropdownMenuItem<String> departmentCard = DropdownMenuItem(
        child: Text(department),
        value: department,
      );
      menuItems.add(departmentCard);
    }
    setState(() {
      dropdownItems = menuItems;
    });
  }

  /// Creates the picker for the user to choose between the gallery and the camera
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
                    title: Text(AppLocalizations.of(context)!.photoLibrary,
                        style: Theme.of(context).textTheme.headline6),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const IconTheme(
                    data: IconThemeData(color: Colors.white),
                    child: Icon(Icons.photo_camera_sharp),
                  ),
                  title: Text(AppLocalizations.of(context)!.camera,
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
  Future<void> submitToServer() async {
    if (_image != null) {
      await apiService.sendOrder(_image!, selectedValue);
    }
  }

  /// Creates a container with a CircularProgressIndicator
  Container circularProgress() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(top: 10.0),
      child: const CircularProgressIndicator(
        strokeWidth: 2.0,
      ),
    );
  }
}
