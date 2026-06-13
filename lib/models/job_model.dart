class JobModel {
  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String location;
  final String workplaceType;
  final String employmentType;
  final String description;
  final bool isActive;
  final String? salary; 

  JobModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.location,
    required this.workplaceType,
    required this.employmentType,
    required this.description,
    this.isActive = true, 
    this.salary,          
  });

  factory JobModel.fromMap(Map<String, dynamic> data, String documentId) {
    return JobModel(
      id: documentId,
      companyId: data['companyId'] ?? '',
      companyName: data['companyName'] ?? 'Unknown Company',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      workplaceType: data['workplaceType'] ?? '',
      employmentType: data['employmentType'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      salary: data['salary']?.toString(), 
    );
  }
}