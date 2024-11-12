import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:student_provider/functions/crud_operations.dart';
import 'package:student_provider/functions/db_function.dart';
import 'package:student_provider/model/models.dart';

class StudentProvider extends ChangeNotifier {
  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;
  
  // Add search functionality within provider
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  
  List<StudentModel> get filteredStudents {
    if (_searchQuery.isEmpty) {
      return _students;
    }
    return _students.where((student) =>
      student.name?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
      student.domain?.toLowerCase().contains(_searchQuery.toLowerCase()) == true
    ).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> registerStudent(
  BuildContext context,
  String name,
  String domain,
  String image,
  int phone,
  String address,
  GlobalKey<FormState> formKey) async {
  if (image.isEmpty) {
    return;
  }

  if (formKey.currentState!.validate() && 
      name.isNotEmpty &&
      domain.isNotEmpty &&
      phone != null &&
      address.isNotEmpty) {
    final add = StudentModel(
      photo: image, 
      name: name,   
      phone: phone, 
      domain: domain, 
      address: address,
      id: -1
    );

    await addStudent(add);  // Make sure to await this
    if (context.mounted) {
      // Update the provider after registration
      await context.read<StudentProvider>().getStudents();
      showSnackBar(context, "REGISTERED SUCCESSFULLY", Colors.green);
      Navigator.pop(context, true);  // Pass back true to indicate success
    }
  }
}

  Future<void> editStudent(
    BuildContext context,
    String name,
    String domain,
    File? image,
    int phone,
    String address,
    int id,
  ) async {
    final studentDB = await Hive.openBox<StudentModel>('student');
    final student = StudentModel(
      id: id,
      name: name,
      domain: domain,
      photo: image?.path,
      phone: phone,
      address: address,
    );

    await studentDB.put(id, student);
    await getStudents();

    if (context.mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student updated successfully')),
      );
    }
  }

  Future<bool> deleteStudent(BuildContext context, StudentModel student) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete this student?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    backgroundImage: student.photo != null 
                      ? FileImage(File(student.photo!)) 
                      : null,
                    child: student.photo == null 
                      ? const Icon(Icons.person, color: Colors.blue) 
                      : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.name ?? 'No Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.domain ?? 'No Domain',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
            ),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        final studentDB = await Hive.openBox<StudentModel>('student');
        await studentDB.delete(student.id);
        await getStudents();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('${student.name} deleted successfully'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return true;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Failed to delete student'),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        return false;
      }
    }
    return false;
  }


  Future<void> getStudents() async {
    final studentDB = await Hive.openBox<StudentModel>('student');
    _students = studentDB.values.toList();
    notifyListeners();
  }
}
