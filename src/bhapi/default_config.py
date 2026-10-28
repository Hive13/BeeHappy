# Signing key for session cookies
SECRET_KEY = "dev"

# Application mode
BHAPI_APPLICATION_MODE = "test"

# Session cookie settings
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = "Lax"

# Application redirect path
REDIRECT_PATH="/auth/action"

# Permissions scopes to request from OIDC
SCOPE = [ "openid", "email", "profile" ]

# Where should we store sessions?
SESSION_TYPE="cachelib"

# Application time zone
APP_TIMEZONE = "America/New_York"