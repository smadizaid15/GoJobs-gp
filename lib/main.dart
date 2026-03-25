import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calma Space MVP',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF8F9FD),
        primaryColor: Color(0xFF120E5C),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.blueGrey.shade200,
          body: Center(
            child: Container(
              width: 393,
              height: 852,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FD),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
                border: Border.all(color: Colors.black, width: 8),
              ),
              child: child,
            ),
          ),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => JobDescriptionScreen(),
        '/upload': (context) => UploadCVScreen(),
        '/success': (context) => SuccessScreen(),
      },
    );
  }
}
// header for pages
class JobHeader extends StatelessWidget {
  const JobHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F6FC),
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Icon(Icons.more_vert, color: Colors.black),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Image.asset('assets/images/company_logo.png', fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 10),
          Text("Calma Space", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 20),
          Text("Head Manager", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
          SizedBox(height: 8),
          Text("Irbid  •  Calma space  •  1 day ago", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello", 
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
                      ),
                      SizedBox(height: 5),
                      Text("Zaid Smadi.", 
                        style: TextStyle(
                          fontSize: 28, 
                          color: Color(0xFF120E5C), 
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          height: 1.0
                        )
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: AssetImage('assets/images/profile_pic.png'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              TextField(
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                  prefixIcon: Icon(Icons.menu, color: Colors.grey.shade600),
                  suffixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(35), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                ),
              ),
              SizedBox(height: 30),
              Text("Recent Job List", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF120E5C),
                  letterSpacing: -0.5
                )
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 60, width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: Offset(0,4))]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/images/company_logo.png', fit: BoxFit.cover),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Barista", 
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF120E5C))
                              ),
                              SizedBox(height: 5),
                              Text("Calma Coffee house  •  Irbid, Jordan", 
                                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.bookmark_border, color: Colors.grey.shade400, size: 28),
                      ],
                    ), 
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text("\$350/Mo", 
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF120E5C))
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(color: Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(20)),
                          child: Text("On site", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(width: 0),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(color: Color(0xFFF8F9FD), borderRadius: BorderRadius.circular(20)),
                          child: Text("Full time", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        Spacer(),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFDECB),
                          foregroundColor: Color(0xFFBC560A),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: () { Navigator.pushNamed(context, '/details'); },
                        child: Text("Apply", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      )
                    )
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text("Find Your Job/Course", 
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w800, 
                  color: Color(0xFF120E5C),
                  letterSpacing: -0.5
                )
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 140, 
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Color(0xFFAFECFE), borderRadius: BorderRadius.circular(35)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work, size: 32, color: Colors.black),
                          SizedBox(height: 15),
                          Text("44.5k", 
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)
                          ),
                          Flexible(
                            child: Text(
                              "Jobs/internships", 
                              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600), 
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: 140, 
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Color(0xFFBEAFFE), borderRadius: BorderRadius.circular(35)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school, size: 32, color: Colors.black),
                          SizedBox(height: 15),
                          Text("3k+", 
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)
                          ),
                          Flexible(
                            child: Text(
                              "courses/workshops", 
                              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600), 
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 140, 
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(color: Color(0xFFFFD6AD), borderRadius: BorderRadius.circular(35)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.laptop, size: 32, color: Colors.black),
                    SizedBox(height: 15),
                    Text("In need of service providers?", 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)
                    ),
                    Flexible(
                      child: Text(
                        "press here to uncover the world of freelancers!", 
                        style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.7), fontWeight: FontWeight.w600), 
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
              ), 
              SizedBox(height: 55),
              Container(
                height: 170,
                width: double.infinity,
                clipBehavior: Clip.hardEdge, 
                decoration: BoxDecoration(
                  color: Color(0xFF130160), 
                  borderRadius: BorderRadius.circular(10), 
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10, 
                      bottom: 0,  
                      top: -10,
                      child: Image.asset(
                        'assets/images/woman_banner.png',
                        fit: BoxFit.contain
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("50% off", 
                            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.0)
                          ),
                          SizedBox(height: 5),
                          Text("take any courses", 
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)
                          ),
                          Spacer(), 
                          SizedBox(
                            height: 40, 
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange, 
                                padding: EdgeInsets.symmetric(horizontal: 35),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                              ),
                              onPressed: (){}, 
                              child: Text("Join Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: Offset(0, -5))]
        ),
        child: BottomNavigationBar(
          selectedItemColor: Color(0xFF120E5C),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline, size: 28), label: ""),
            BottomNavigationBarItem(icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Color(0xFF120E5C), shape: BoxShape.circle),
              child: Icon(Icons.add, color: Colors.white, size: 28)), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline, size: 28), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark_border, size: 28), label: ""),
          ],
        ),
      ),
    );
  }
}
class JobDescriptionScreen extends StatelessWidget {
  const JobDescriptionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FC), 
      body: Column(
        children: [
          JobHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                       child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        decoration: BoxDecoration(
                          color: Color(0xFFD6CDFE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text("View company", style: TextStyle(color: Color(0xFF120E5C), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Job Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF120E5C))),
                    ),
                    Text(
                      "The Head Manager oversees all daily operations of the coffee house, ensuring a smooth, efficient, and welcoming environment for both customers and staff. This role involves leading and motivating the team, managing inventory and supplies, maintaining high standards of service and product quality, and implementing operational policies. The Head Mana...",
                      style: TextStyle(color: Color.fromARGB(255, 158, 158, 158), height: 1),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Requirements", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF120E5C))),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Lead and supervise the coffee house team.", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Ensure consistent quality of coffee.", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Resolve customer complaints.", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Manage inventory and supplies.", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Implement health and safety standards.", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 10),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF120E5C))),
                    ),
                    Text("Jordan, Irbid, behind Sameh Mall", style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 15),
                    
                    Container(
                      height: 150, 
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge, 
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, 
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage('assets/images/calmalocationn.png'), 
                          fit: BoxFit.cover, 
                        ),
                      ),
                      child: Center(
                        child: Icon(Icons.location_on, size: 40, color: Colors.red),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Informations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF120E5C))),
                    ),
                   
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Position", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
                          SizedBox(height: 3),
                          Text("Head Manager", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          SizedBox(height: 5),
                          Divider(color: Colors.grey.shade200),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Qualification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
                          SizedBox(height: 3),
                          Text("Bachelor's Degree", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          SizedBox(height: 5),
                          Divider(color: Colors.grey.shade200),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 25),

                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text("Facilities and Others", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF120E5C))),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Managing both floors", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("• ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 96, 82, 110))),
                          SizedBox(width: 5),
                          Expanded(child: Text("Leadership", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500))),
                        ],
                      ),
                    ),
                                     
                    SizedBox(height: 30),                   
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () { Navigator.pushNamed(context, '/upload'); },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF120E5C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text("APPLY NOW", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UploadCVScreen extends StatelessWidget {
  const UploadCVScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FC), 
      body: Column(
        children: [
          JobHeader(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upload CV", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
                    SizedBox(height: 5),
                    Text("Add your CV/Resume to apply for a job", style: TextStyle(color: Colors.grey, fontSize: 15)),
                    SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, color: Colors.grey),
                                SizedBox(height: 5),
                                Text("Upload CV", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.normal)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Color(0xFFD6CDFE),
                              border: Border.all(color: Color(0xFFD6CDFE), width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_present, color: Color.fromARGB(255, 0, 0, 0)),
                                SizedBox(height: 5),
                                Text("Use existing CV", style: TextStyle(fontSize: 13, color: Color(0xFF120E5C), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 35),
                    Text("Information (optional)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
                    SizedBox(height: 15),
                    TextField(
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Explain why you are the right person for this job",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        fillColor: Color(0xFFF8F9FD),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF120E5C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () { Navigator.pushNamed(context, '/success'); },
                        child: Text("SUBMIT APPLICATION", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F6FC), 
      body: Column(
        children: [
          JobHeader(),
          Expanded(
            child: Container(
              width: double.infinity, 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40))
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(), 
                    
                    Container(
                      padding: EdgeInsets.all(15), 
                      decoration: BoxDecoration(
                        color: Color(0xFFD6CDFE).withOpacity(0.3), 
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: Offset(0,5))]
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Color(0xFFE5252A), size: 40), 
                          SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Zaid Kilani - CV - Head barista", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF120E5C))),
                              SizedBox(height: 1),
                              Text("867 Kb • 14 Feb 2022", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30), 
                    
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.check, size: 50, color: Colors.orange), 
                    ),
                    
                    SizedBox(height: 20),
                    
                    Text("Successful", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF120E5C))),
                    SizedBox(height: 10),
                    Text("Congratulations, your application has been sent", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                    
                    Spacer(flex: 2), 
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55, 
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD6CDFE),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: () {},
                        child: Text("VIEW APPLICATION", style: TextStyle(color: Color(0xFF120E5C), fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF120E5C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                           Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: Text("BACK TO HOME", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}