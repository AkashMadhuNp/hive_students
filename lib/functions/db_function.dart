import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:student_provider/model/models.dart';

ValueNotifier<List<StudentModel>> studentList=ValueNotifier([]);

Future<void> addStudent(StudentModel value)async{
  final studentDb =await Hive.openBox<StudentModel>('student');
  final id= await studentDb.add(value);
  final studentdata=studentDb.get(id);
  await studentDb.put(id, StudentModel(
    photo: studentdata!.photo, 
    name: studentdata.name, 
    phone: studentdata.phone, 
    domain: studentdata.domain, 
    address: studentdata.address,
    id: id
    ));   
    getStudent();
}

 Future<void> getStudent()async{
      final studentDb = await Hive.openBox<StudentModel>('student');
      studentList.value.clear();
      studentList.value.addAll(studentDb.values);
      studentList.notifyListeners();
    }