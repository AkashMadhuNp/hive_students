import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:student_provider/functions/db_function.dart';
import 'package:student_provider/model/models.dart';

Future<void> registerStudent(
  BuildContext context,
  String name,
  String domain,
  String image,
  int phone,
  String address,
  GlobalKey<FormState> formKey)async{
    if(image.isEmpty){
      return;
    }

    if(formKey.currentState!.validate() && 
    name.isNotEmpty &&
    domain.isNotEmpty &&
    phone != null &&
    address.isNotEmpty
    ){
      final add = StudentModel(
        photo: image, 
        name: name,   
        phone: phone, 
        domain: domain, 
        address: address,
        id: -1
        );

        addStudent(add);
        showSnackBar(context,"REGISTERED SUCCESSFULLY" , Colors.green);
        Navigator.pop(context);
        
    }
    }

        
        
void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 2),
    backgroundColor: color,
  ));
}



Future<void> editStudent(
  BuildContext context,
  String name,
  String domain,
  File? image,
  int phone,
  String address,
  int id
) async {
  try {
    final editbox = await Hive.openBox<StudentModel>('student');
    final existingStudent = editbox.values.firstWhere(
      (element) => element.id == id,
      orElse: () => throw Exception('Student not found'), // Add error handling
    );

    existingStudent.name = name;
    existingStudent.photo = image!.path;
    existingStudent.domain = domain;
    existingStudent.address = address;
    existingStudent.phone = phone;

    await editbox.put(id, existingStudent);
    await getStudent(); // Make sure this completes before navigation
    
    if (context.mounted) { // Add this check
      showSnackBar(context, "Updated Successfully", Colors.green);
      Navigator.pop(context);
    }
  } catch (e) {
    if (context.mounted) {
      showSnackBar(context, "Update failed: ${e.toString()}", Colors.red);
    }
  }
}


void delete(BuildContext context, int? id) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        title: const Text(
          "Delete Student",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this student?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              "CANCEL",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8, right: 8),
            child: ElevatedButton(
              onPressed: () {
                dlt(context, id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "DELETE",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      );
    },
  );
}





Future<void> dlt(context,int? id)async{
  final remove = await Hive.openBox<StudentModel>('student');
  remove.delete(id);
  getStudent();
  showSnackBar(context, "Deleted", Colors.red);
  Navigator.pop(context);
}
