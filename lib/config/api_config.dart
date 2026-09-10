// Tracked, safe, and intentionally empty. No AI provider credential is ever
// compiled into the Flutter mobile or web client — see
// lib/services/ai_service.dart's empty-key guard, which reports AI features
// as unconfigured rather than making a network call when groqApiKey is ''.
//
// The target architecture routes AI calls through a backend proxy instead
// of the client holding a key at all (Flutter -> GoJobs backend -> AI
// service -> provider); see docs/architecture/TARGET_ARCHITECTURE.md.
// Do not put a real key here, in this file or any local edit of it — see
// docs/security/SECURITY_AUDIT.md (H-1) for why a hardcoded client-side key
// was a critical finding in this project's history.
class ApiConfig {
  static const String groqApiKey = '';
}
