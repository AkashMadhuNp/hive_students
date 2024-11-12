import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_provider/functions/db_function.dart';
import 'package:student_provider/model/models.dart';
import 'package:student_provider/povider/helperclass.dart';
import 'package:student_provider/screens/home/edit_screenp.dart';
import 'package:student_provider/screens/registration_page.dart';
import 'package:student_provider/screens/student_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  Timer? debouncer;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    debouncer?.cancel();
    searchController.dispose();
    
  }
  

  

 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().getStudents();
    });
    refreshStudentList();
  }

void _onSearchChanged(String query){
  if(debouncer?.isActive ?? false) debouncer!.cancel();
  debouncer=Timer(Duration(microseconds: 500), () {
    context.read<StudentProvider>().setSearchQuery(query);
  },);
}
  

  



Future<void> refreshStudentList() async {
  if (!mounted) return;
  await getStudent();
  if (mounted) {
    
    setState(() {});
  }
}


  Future<void> _navigateToRegistrationScreen() async {
  if (!mounted) return;
  
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const RegistrationPage()),
  );

  if (result == true && mounted) {
    await context.read<StudentProvider>().getStudents();
    setState(() {
      
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: AppBar(
            backgroundColor: const Color(0xFF1E1E1E),
            elevation: 0,
            toolbarHeight: 80,
            title: const Column(
              children: [
                Text(
                  "STUDENT PORTAL",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "Manage Your Students",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    // Handle logout
                  },
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1E1E1E), Color(0xFF3D3D3D)],
            ),
          ),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: Consumer<StudentProvider>(
                  builder: (context, provider, child) {
                    final students = provider.filteredStudents;
                  if(students.isEmpty){
                      const Center(
                          child: Text(
                            "No Students Found",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )  ;
                  }
                  
                      return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student=students[index];
                            return _buildStudentCard(student);
                            
                          },
                        );
                  }

                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToRegistrationScreen,
          backgroundColor: Colors.white,
          label: const Row(
            children: [
              Icon(
                Icons.add,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text(
                "ADD STUDENT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
      }


      Widget _buildStudentCard(StudentModel student) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          bottomSheet(
        
                  context, 
                  student.name!, 
                  student.domain!, 
                  student.phone!, 
                  student.address!, 
                  student.photo!);                            
         
        },
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.2),
            backgroundImage:
                student.photo != null ? FileImage(File(student.photo!)) : null,
            child:
                student.photo == null ? const Icon(Icons.person, color: Colors.blue) : null,
          ),
          title: Text(
            student.name ?? "No Name",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            student.domain ?? "No Domain",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditStudentScreen(student: student),
                  ),
                ).then((_) => context.read<StudentProvider>().getStudents()),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () {
                  context.read<StudentProvider>().deleteStudent(context, student);
                },
                icon: const Icon(Icons.delete, color: Colors.white70),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }



      Widget _buildSearchBar() {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white30),
          ),
          child: TextField(
            controller: searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search students...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();
                        provider.setSearchQuery('');
                      },
                      icon: const Icon(Icons.clear, color: Colors.white),
                      tooltip: 'Clear search',
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      );
      });

  }

    
  }

  