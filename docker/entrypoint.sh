#!/usr/bin/env sh

if [ -f ${HOME}/.env ]; then
    echo "$(date) | Loading environment variables from .env file..."
    set -a
    . ${HOME}/.env
    set +a
fi

# Run migrations
echo "$(date) | Running migrations..."
python manage.py migrate || exit 1

create_admin_user() {
    # Get the default superuser credentials from the environment variables.
    if [ -z "$ADMIN_USERNAME" ]; then
        echo "ADMIN_USERNAME is not set. Using default value 'admin'."
        ADMIN_USERNAME="admin"
    fi
    if [ -z "$ADMIN_PASSWORD" ]; then
        echo "ADMIN_PASSWORD is not set. Using default value 'admin'."
        ADMIN_PASSWORD=admin
    fi

    echo "$(date) | Creating superuser '$ADMIN_USERNAME' with password '$ADMIN_PASSWORD'..."
    python manage.py createsuperuser --username "$ADMIN_USERNAME" --email "$ADMIN_USERNAME@localhost" --noinput
    python manage.py shell -c "
from django.contrib.auth import get_user_model

User = get_user_model()

user = User.objects.get(username='$ADMIN_USERNAME')
user.set_password('$ADMIN_PASSWORD')
user.is_active = True
user.save()
"
}

# Check if at least one superuser exists. If not, create one.
echo "$(date) | Checking superuser..."
python manage.py shell -c "
from django.contrib.auth import get_user_model

User = get_user_model()
User.objects.filter(is_superuser=True).first() or exit(1)
" && echo "$(date) | Superuser exists." || create_admin_user

# Collect static files
echo "$(date) | Checking Redis connection..."
(nc -zv $REDIS_HOST $REDIS_PORT && echo "$(date) | Redis available.") || (echo "Redis is not available. Make sure it's running and accessible." && exit 1)
echo "$(date) | Collecting static files..."
python manage.py collectstatic --noinput || exit 1


# Accept docker command (CMD) as arguments to entrypoint script. This allows us
# to run any command on the container startup.
# E.g. "python manage.py runserver 0.0.0.0:8000" or "gunicorn" or even "celery -A ..."
exec "$@"