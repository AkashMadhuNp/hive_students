import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:student_provider/functions/crud_operations.dart';
import 'package:student_provider/functions/db_function.dart';
import 'package:student_provider/model/models.dart';
import 'package:student_provider/screens/edit_screen.dart';
import 'package:student_provider/screens/registration_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  Timer? debouncer;
  bool hasSearchText = false;
  bool _mounted = true;

  void onSearch(String query) {
    if (debouncer?.isActive ?? false) debouncer?.cancel();

    debouncer = Timer(const Duration(milliseconds: 500), () async {
      if (!_mounted) return;
      
      try {
        final studentDb = await Hive.openBox<StudentModel>('student');
        final allStudents = studentDb.values.toList();

        if (!_mounted) return;

        if (query.trim().isEmpty) {
          studentList.value = allStudents;
        } else {
          final filteredStudents = allStudents
              .where((student) =>
                  student.name?.toLowerCase().contains(query.toLowerCase().trim()) ==
                      true ||
                  student.domain
                          ?.toLowerCase()
                          .contains(query.toLowerCase().trim()) ==
                      true)
              .toList();
          studentList.value = filteredStudents;
        }

        studentList.notifyListeners();
      } catch (e) {
        debugPrint("Search Error: $e");
      }
    });
  }

  Future<void> refreshStudentList() async {
    if (!_mounted) return;
    await getStudent();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _mounted = true;
    refreshStudentList();
    searchController.addListener(() {
      if (!_mounted) return;
      setState(() {
        hasSearchText = searchController.text.isNotEmpty;
      });
      onSearch(searchController.text);
    });
  }

  @override
  void dispose() {
    _mounted = false;
    searchController.dispose();
    debouncer?.cancel();
    super.dispose();
  }

  Future<void> _navigateToEditScreen(StudentModel student) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPage(
          id: student.id!,
          name: student.name ?? '',
          domain: student.domain ?? '',
          phone: student.phone ?? 0,
          address: student.address ?? '',
          photo: student.photo,
        ),
      ),
    );

    if (result == true && _mounted) {
      await refreshStudentList();
    }
  }

  Future<void> _navigateToRegistrationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );

    if (result == true && _mounted) {
      await refreshStudentList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: ValueListenableBuilder(
                valueListenable: studentList,
                builder: (context, List<StudentModel> students, child) {
                  return students.isEmpty
                      ? const Center(
                          child: Text(
                            "No Students Found",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.2)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.withOpacity(0.2),
                                  backgroundImage: student.photo != null
                                      ? FileImage(File(student.photo!))
                                      : null,
                                  child: student.photo == null
                                      ? const Icon(Icons.person,
                                          color: Colors.blue)
                                      : null,
                                ),
                                title: Text(
                                  student.name ?? "No Name",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.domain ?? "No Domain",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    Text(
                                      student.phone?.toString() ?? "No Phone",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white70),
                                      onPressed: () => _navigateToEditScreen(student),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        delete(context, student.id);
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.white70),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
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

  Widget _buildSearchBar() {
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
          onChanged: onSearch,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search students...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
            suffixIcon: hasSearchText
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        hasSearchText = false;
                        refreshStudentList();
                      });
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
  }
}