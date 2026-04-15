import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';

// Auth - Company
import '../screens/auth/company/company_signup_screen.dart';
import '../screens/auth/company/company_login_screen.dart';
import '../screens/auth/company/company_otp_screen.dart';
import '../screens/auth/company/company_forgot_password_screen.dart';
import '../screens/auth/company/company_check_email_screen.dart';

// Auth - JobSeeker
import '../screens/auth/job_seeker/jobseeker_signup_screen.dart';
import '../screens/auth/job_seeker/jobseeker_login_screen.dart';
import '../screens/auth/job_seeker/jobseeker_otp_screen.dart';
import '../screens/auth/job_seeker/jobseeker_forgot_password_screen.dart';
import '../screens/auth/job_seeker/jobseeker_check_email_screen.dart';

// Auth - Student
import '../screens/auth/student/student_signup_screen.dart';
import '../screens/auth/student/student_login_screen.dart';
import '../screens/auth/student/student_otp_screen.dart';
import '../screens/auth/student/student_forgot_password_screen.dart';
import '../screens/auth/student/student_check_email_screen.dart';

// Company
import '../screens/company/home/company_home_screen.dart';
import '../screens/company/profile/company_profile_screen.dart';
import '../screens/company/profile/company_edit_profile_screen.dart';
import '../screens/company/jobs/company_jobs_screen.dart';
import '../screens/company/jobs/company_add_job_screen.dart';
import '../screens/company/jobs/company_edit_job_screen.dart';
import '../screens/company/jobs/company_job_position_picker.dart';
import '../screens/company/jobs/company_workplace_type_sheet.dart';
import '../screens/company/jobs/company_location_picker.dart';
import '../screens/company/jobs/company_job_type_sheet.dart';
import '../screens/company/applicants/company_applicants_screen.dart';
import '../screens/company/messages/company_messages_screen.dart';
import '../screens/company/messages/company_chat_screen.dart';
import '../screens/company/notifications/company_notifications_screen.dart';
import '../screens/company/settings/company_settings_screen.dart';
import '../screens/company/settings/company_update_password_screen.dart';

// JobSeeker
import '../screens/job_seeker/home/jobseeker_home_screen.dart';
import '../screens/job_seeker/search/jobseeker_search_screen.dart';
import '../screens/job_seeker/search/jobseeker_filter_screen.dart';
import '../screens/job_seeker/jobs/jobseeker_job_detail_screen.dart';
import '../screens/job_seeker/jobs/jobseeker_company_profile_screen.dart';
import '../screens/job_seeker/jobs/jobseeker_upload_cv_screen.dart';
import '../screens/job_seeker/jobs/jobseeker_application_success_screen.dart';
import '../screens/job_seeker/jobs/jobseeker_my_application_screen.dart';
import '../screens/job_seeker/saved/jobseeker_saved_screen.dart';
import '../screens/job_seeker/messages/jobseeker_messages_screen.dart';
import '../screens/job_seeker/messages/jobseeker_chat_screen.dart';
import '../screens/job_seeker/notifications/jobseeker_notifications_screen.dart';
import '../screens/job_seeker/settings/jobseeker_settings_screen.dart';
import '../screens/job_seeker/settings/jobseeker_update_password_screen.dart';
import '../screens/job_seeker/profile/jobseeker_profile_screen.dart';
import '../screens/job_seeker/profile/jobseeker_edit_profile_screen.dart';
import '../screens/job_seeker/profile/jobseeker_work_experience_screen.dart';
import '../screens/job_seeker/profile/jobseeker_education_screen.dart';
import '../screens/job_seeker/profile/jobseeker_skills_screen.dart';
import '../screens/job_seeker/profile/jobseeker_language_screen.dart';
import '../screens/job_seeker/profile/jobseeker_about_me_screen.dart';
import '../screens/job_seeker/profile/jobseeker_resume_screen.dart';
import '../screens/job_seeker/freelancer_marketplace/jobseeker_service_providers_screen.dart';

// Freelancer
import '../screens/freelancer/home/freelancer_home_screen.dart';
import '../screens/freelancer/profile/freelancer_profile_screen.dart';
import '../screens/freelancer/profile/freelancer_edit_profile_screen.dart';
import '../screens/freelancer/profile/freelancer_about_me_screen.dart';
import '../screens/freelancer/profile/freelancer_services_screen.dart';
import '../screens/freelancer/profile/freelancer_expertise_screen.dart';
import '../screens/freelancer/profile/freelancer_skills_screen.dart';
import '../screens/freelancer/profile/freelancer_portfolio_screen.dart';
import '../screens/freelancer/messages/freelancer_messages_screen.dart';
import '../screens/freelancer/messages/freelancer_chat_screen.dart';
import '../screens/freelancer/notifications/freelancer_notifications_screen.dart';
import '../screens/freelancer/settings/freelancer_settings_screen.dart';
import '../screens/freelancer/settings/freelancer_update_password_screen.dart';

// Student
import '../screens/student/home/student_home_screen.dart';
import '../screens/student/notifications/student_notifications_screen.dart';
import '../screens/student/settings/student_settings_screen.dart';
import '../screens/student/settings/student_update_password_screen.dart';
import '../screens/student/messages/student_messages_screen.dart';
import '../screens/student/messages/student_chat_screen.dart';
import '../screens/student/saved/student_saved_screen.dart';
import '../screens/student/profile/student_profile_screen.dart';
import '../screens/student/courses/student_courses_screen.dart';
import '../screens/student/courses/student_course_detail_screen.dart';
import '../screens/student/internships/student_internship_categories_screen.dart';
import '../screens/student/internships/student_internship_detail_screen.dart';
import '../screens/student/internships/student_internship_list_screen.dart';
import '../screens/student/internships/student_upload_cv_screen.dart';
import '../screens/student/internships/student_application_success_screen.dart';
import '../screens/student/freelancer_marketplace/student_service_providers_screen.dart';

// AI 
import '../screens/ai/ai_chat_screen.dart';
import '../screens/ai/ai_job_match_screen.dart';
import '../screens/ai/ai_job_description_screen.dart';
import '../screens/ai/ai_interview_prep_screen.dart';









class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash & Welcome
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),

      // Company Auth
      GoRoute(path: '/company/signup', builder: (context, state) => const CompanySignupScreen()),
      GoRoute(path: '/company/login', builder: (context, state) => const CompanyLoginScreen()),
      GoRoute(path: '/company/otp', builder: (context, state) => const CompanyOtpScreen()),
      GoRoute(path: '/company/forgot-password', builder: (context, state) => const CompanyForgotPasswordScreen()),
      GoRoute(path: '/company/check-email', builder: (context, state) => const CompanyCheckEmailScreen()),

      // JobSeeker Auth
      GoRoute(path: '/jobseeker/signup', builder: (context, state) => const JobseekerSignupScreen()),
      GoRoute(path: '/jobseeker/login', builder: (context, state) => const JobseekerLoginScreen()),
      GoRoute(path: '/jobseeker/otp', builder: (context, state) => const JobseekerOtpScreen()),
      GoRoute(path: '/jobseeker/forgot-password', builder: (context, state) => const JobseekerForgotPasswordScreen()),
      GoRoute(path: '/jobseeker/check-email', builder: (context, state) => const JobseekerCheckEmailScreen()),

      // Student Auth
      GoRoute(path: '/student/signup', builder: (context, state) => const StudentSignupScreen()),
      GoRoute(path: '/student/login', builder: (context, state) => const StudentLoginScreen()),
      GoRoute(path: '/student/otp', builder: (context, state) => const StudentOtpScreen()),
      GoRoute(path: '/student/forgot-password', builder: (context, state) => const StudentForgotPasswordScreen()),
      GoRoute(path: '/student/check-email', builder: (context, state) => const StudentCheckEmailScreen()),

      // Company
      GoRoute(path: '/company/home', builder: (context, state) => const CompanyHomeScreen()),
      GoRoute(path: '/company/profile', builder: (context, state) => const CompanyProfileScreen()),
      GoRoute(path: '/company/edit-profile', builder: (context, state) => const CompanyEditProfileScreen()),
      GoRoute(path: '/company/jobs', builder: (context, state) => const CompanyJobsScreen()),
      GoRoute(path: '/company/add-job', builder: (context, state) => const CompanyAddJobScreen()),
      GoRoute(path: '/company/edit-job', builder: (context, state) => const CompanyEditJobScreen()),
      GoRoute(path: '/company/job-position-picker', builder: (context, state) => const CompanyJobPositionPicker()),
      GoRoute(path: '/company/workplace-type', builder: (context, state) => const CompanyWorkplaceTypeSheet()),
      GoRoute(path: '/company/location-picker', builder: (context, state) => const CompanyLocationPicker()),
      GoRoute(path: '/company/job-type', builder: (context, state) => const CompanyJobTypeSheet()),
      GoRoute(path: '/company/applicants', builder: (context, state) => const CompanyApplicantsScreen()),
      GoRoute(path: '/company/messages', builder: (context, state) => const CompanyMessagesScreen()),
      GoRoute(path: '/company/chat', builder: (context, state) => const CompanyChatScreen()),
      GoRoute(path: '/company/notifications', builder: (context, state) => const CompanyNotificationsScreen()),
      GoRoute(path: '/company/settings', builder: (context, state) => const CompanySettingsScreen()),
      GoRoute(path: '/company/update-password', builder: (context, state) => const CompanyUpdatePasswordScreen()),

      // JobSeeker
      GoRoute(path: '/jobseeker/home', builder: (context, state) => const JobseekerHomeScreen()),
      GoRoute(path: '/jobseeker/search', builder: (context, state) => const JobseekerSearchScreen()),
      GoRoute(path: '/jobseeker/filter', builder: (context, state) => const JobseekerFilterScreen()),
      GoRoute(
  path: '/jobseeker/job-detail',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return JobseekerJobDetailScreen(job: job);
  },
),
      GoRoute(
  path: '/jobseeker/company-profile',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return JobseekerCompanyProfileScreen(job: job);
  },
),
      GoRoute(
  path: '/jobseeker/upload-cv',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return JobseekerUploadCvScreen(job: job);
  },
),
      GoRoute(
  path: '/jobseeker/application-success',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return JobseekerApplicationSuccessScreen(job: job);
  },
),
      GoRoute(
  path: '/jobseeker/my-application',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return JobseekerMyApplicationScreen(job: job);
  },
),
      GoRoute(path: '/jobseeker/saved', builder: (context, state) => const JobseekerSavedScreen()),
      GoRoute(path: '/jobseeker/messages', builder: (context, state) => const JobseekerMessagesScreen()),
      GoRoute(path: '/jobseeker/chat', builder: (context, state) => const JobseekerChatScreen()),
      GoRoute(path: '/jobseeker/notifications', builder: (context, state) => const JobseekerNotificationsScreen()),
      GoRoute(path: '/jobseeker/settings', builder: (context, state) => const JobseekerSettingsScreen()),
      GoRoute(path: '/jobseeker/update-password', builder: (context, state) => const JobseekerUpdatePasswordScreen()),
      GoRoute(path: '/jobseeker/profile', builder: (context, state) => const JobseekerProfileScreen()),
      GoRoute(path: '/jobseeker/edit-profile', builder: (context, state) => const JobseekerEditProfileScreen()),
      GoRoute(path: '/jobseeker/work-experience', builder: (context, state) => const JobseekerWorkExperienceScreen()),
      GoRoute(path: '/jobseeker/education', builder: (context, state) => const JobseekerEducationScreen()),
      GoRoute(path: '/jobseeker/skills', builder: (context, state) => const JobseekerSkillsScreen()),
      GoRoute(path: '/jobseeker/language', builder: (context, state) => const JobseekerLanguageScreen()),
      GoRoute(path: '/jobseeker/about-me', builder: (context, state) => const JobseekerAboutMeScreen()),
      GoRoute(path: '/jobseeker/resume', builder: (context, state) => const JobseekerResumeScreen()),
      GoRoute(path: '/jobseeker/service-providers', builder: (context, state) => const JobseekerServiceProvidersScreen()),
      GoRoute(path: '/jobseeker/chat-from-providers', builder: (context, state) => const JobseekerChatScreen()),

      // Freelancer
      GoRoute(path: '/freelancer/home', builder: (context, state) => const FreelancerHomeScreen()),
      GoRoute(path: '/freelancer/profile', builder: (context, state) => const FreelancerProfileScreen()),
      GoRoute(path: '/freelancer/edit-profile', builder: (context, state) => const FreelancerEditProfileScreen()),
      GoRoute(path: '/freelancer/about-me', builder: (context, state) => const FreelancerAboutMeScreen()),
      GoRoute(path: '/freelancer/services', builder: (context, state) => const FreelancerServicesScreen()),
      GoRoute(path: '/freelancer/expertise', builder: (context, state) => const FreelancerExpertiseScreen()),
      GoRoute(path: '/freelancer/skills', builder: (context, state) => const FreelancerSkillsScreen()),
      GoRoute(path: '/freelancer/portfolio', builder: (context, state) => const FreelancerPortfolioScreen()),
      GoRoute(path: '/freelancer/messages', builder: (context, state) => const FreelancerMessagesScreen()),
      GoRoute(path: '/freelancer/chat', builder: (context, state) => const FreelancerChatScreen()),
      GoRoute(path: '/freelancer/notifications', builder: (context, state) => const FreelancerNotificationsScreen()),
      GoRoute(path: '/freelancer/settings', builder: (context, state) => const FreelancerSettingsScreen()),
      GoRoute(path: '/freelancer/update-password', builder: (context, state) => const FreelancerUpdatePasswordScreen()),

      // Student
      GoRoute(path: '/student/home', builder: (context, state) => const StudentHomeScreen()),
      GoRoute(path: '/student/notifications', builder: (context, state) => const StudentNotificationsScreen()),
      GoRoute(path: '/student/settings', builder: (context, state) => const StudentSettingsScreen()),
      GoRoute(path: '/student/update-password', builder: (context, state) => const StudentUpdatePasswordScreen()),
      GoRoute(path: '/student/messages', builder: (context, state) => const StudentMessagesScreen()),
      GoRoute(path: '/student/chat', builder: (context, state) => const StudentChatScreen()),
      GoRoute(path: '/student/saved', builder: (context, state) => const StudentSavedScreen()),
      GoRoute(path: '/student/profile', builder: (context, state) => const StudentProfileScreen()),
      GoRoute(path: '/student/courses', builder: (context, state) => const StudentCoursesScreen()),
      GoRoute(path: '/student/course-detail', builder: (context, state) => const StudentCourseDetailScreen()),
      GoRoute(path: '/student/internship-categories', builder: (context, state) => const StudentInternshipCategoriesScreen()),
      GoRoute(path: '/student/internship-detail', builder: (context, state) => const StudentInternshipDetailScreen()),
      GoRoute(path: '/student/internship-list', builder: (context, state) => const StudentInternshipListScreen()),
      GoRoute(path: '/student/upload-cv', builder: (context, state) => const StudentUploadCvScreen()),
      GoRoute(path: '/student/application-success', builder: (context, state) => const StudentApplicationSuccessScreen()),
      GoRoute(path: '/student/service-providers', builder: (context, state) => const StudentServiceProvidersScreen()),
      GoRoute(path: '/student/chat-from-providers', builder: (context, state) => const StudentChatScreen()),

      //AI
      GoRoute(path: '/ai-chat', builder: (context, state) => const AIChatScreen()),
      GoRoute(
  path: '/ai-job-match',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return AIJobMatchScreen(job: job);
  },
),GoRoute(
  path: '/ai-interview-prep',
  builder: (context, state) {
    final job = state.extra as Map<String, dynamic>?;
    return AIInterviewPrepScreen(job: job);
  },
),
      GoRoute(path: '/ai-job-description', builder: (context, state) => const AIJobDescriptionScreen()),
    
    ],
  );
}