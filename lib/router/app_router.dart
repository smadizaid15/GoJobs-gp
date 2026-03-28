import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/company/company_signup_screen.dart';
import '../screens/auth/company/company_login_screen.dart';
import '../screens/auth/company/company_otp_screen.dart';
import '../screens/auth/company/company_forgot_password_screen.dart';
import '../screens/auth/company/company_check_email_screen.dart';
import '../screens/auth/job_seeker/jobseeker_signup_screen.dart';
import '../screens/auth/job_seeker/jobseeker_login_screen.dart';
import '../screens/auth/job_seeker/jobseeker_otp_screen.dart';
import '../screens/auth/job_seeker/jobseeker_forgot_password_screen.dart';
import '../screens/auth/job_seeker/jobseeker_check_email_screen.dart';
import '../screens/auth/student/student_signup_screen.dart';
import '../screens/auth/student/student_login_screen.dart';
import '../screens/auth/student/student_otp_screen.dart';
import '../screens/auth/student/student_forgot_password_screen.dart';
import '../screens/auth/student/student_check_email_screen.dart';
import '../screens/company/home/company_home_screen.dart';
import '../screens/job_seeker/home/jobseeker_home_screen.dart';
import '../screens/freelancer/home/freelancer_home_screen.dart';
import '../screens/student/home/student_home_screen.dart';

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

      // Home screens
      GoRoute(path: '/company/home', builder: (context, state) => const CompanyHomeScreen()),
      GoRoute(path: '/jobseeker/home', builder: (context, state) => const JobseekerHomeScreen()),
      GoRoute(path: '/freelancer/home', builder: (context, state) => const FreelancerHomeScreen()),
      GoRoute(path: '/student/home', builder: (context, state) => const StudentHomeScreen()),
    ],
  );
}