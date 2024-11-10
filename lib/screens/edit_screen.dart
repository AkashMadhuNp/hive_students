import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:student_provider/functions/crud_operations.dart';
import 'package:student_provider/screens/validations.dart';

class EditPage extends StatefulWidget {
  final int id;
  final String name;
  final String domain;
  final int phone;
  final String address;
  final String? photo;

  const EditPage({super.key, required this.id, required this.name, required this.domain, required this.phone, required this.address, this.photo});

  @override
  State<EditPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<EditPage> {
  File? selectedImage;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = widget.name;
    _contactController.text = widget.phone.toString();
    _emailController.text = widget.domain;
    _addressController.text = widget.address;
    
    // Initialize selected image if photo exists
    if (widget.photo != null) {
      selectedImage = File(widget.photo!);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
     _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }


  

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Student Registration Edit",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E1E1E), Color(0xFF3D3D3D)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: selectedImage != null
                                ? Image.file(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 160,
                                    height: 160,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.person,size: 80,color: Colors.grey,);
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                                  try {
                                    final picker = ImagePicker();
                                    final pickedImage = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 75, // Optimize image quality
                                    );
                                    
                                    if (pickedImage != null) {
                                      setState(() {
                                        selectedImage = File(pickedImage.path);
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      showSnackBar(
                                        context,
                                        "Failed to pick image: ${e.toString()}",
                                        Colors.red,
                                      );
                                    }
                                    }
                                },

                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                    validator: Validations.nameValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _contactController,
                    label: "Contact Number",
                    icon: Icons.phone_outlined,
                    validator: Validations.phoneValidator,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: "Domain",
                    icon: Icons.edgesensor_high,
                    validator: Validations.domainValidator,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _addressController,
                    label: "Address",
                    icon: Icons.location_on_outlined,
                    //validator: Validations.nameValidator,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {


                        if (_formKey.currentState!.validate() &&
                                _nameController.text.isNotEmpty &&
                                _contactController.text.isNotEmpty &&
                                _emailController.text.isNotEmpty &&
                                _addressController.text.isNotEmpty != null &&
                                selectedImage!.path.isNotEmpty) {
                              editStudent(context, 
                              _nameController.text, 
                              _emailController.text, 
                              selectedImage, 
                              int.parse(_contactController.text.toString()), 
                              _addressController.text, 
                              widget.id
                              );
                            } else {
                              _nameController.clear();
                              _contactController.clear();
                              _addressController.clear();
                              _emailController.clear();
                              showSnackBar(
                                  context, 'Update Failed!', Colors.red);
                            }
                          

                      
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black26,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}