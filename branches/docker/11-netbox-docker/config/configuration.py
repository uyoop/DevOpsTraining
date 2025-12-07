# Configuration Python pour NetBox

ALLOWED_HOSTS = ['*']

# Base de données
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'netbox',
        'USER': 'netbox',
        'PASSWORD': 'netbox',
        'HOST': 'postgres',
        'PORT': '',
    }
}

# Redis Cache
RQ_SHOW_ADMIN_LINK = True
REDIS = {
    'default': {
        'HOST': 'redis',
        'PORT': 6379,
        'DATABASE': 0,
        'SSL': False,
    }
}

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
}

# API Configuration
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.LimitOffsetPagination',
    'PAGE_SIZE': 50,
}

# Sessions
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = True
SESSION_COOKIE_SAMESITE = 'Lax'

# Timezone
TIME_ZONE = 'UTC'

# Dynamic Inventory
ENABLE_GRAPHQL = True
