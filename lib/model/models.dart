import 'package:hive/hive.dart';
part 'models.g.dart';

@HiveType(typeId: 1)
class StudentModel{
  @HiveField(0)
   String? photo;

   @HiveField(1)
   String? name;

   @HiveField(2)
   int? phone;

   @HiveField(3)
   String? domain;

   @HiveField(4)
   String? address;

   @HiveField(5)
   int? id;

  StudentModel( 
    { 
     required this.photo, 
     required this.name, 
     required this.phone, 
     required this.domain, 
     required this.address,
     this.id
     });
}