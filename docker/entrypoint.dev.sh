#!/usr/bin/env bash
set -euo pipefail

python --version
pip --version

# Install the project in editable mode if setup files exist
if [ -f "/app/pyproject.toml" ] || [ -f "/app/setup.py" ]; then
  echo "Installing Pretix (editable) and dev extras..."
  pip install --upgrade pip wheel
  pip install -e .
else
  echo "ERROR: No Pretix source detected in /app. Mount or copy the repo into the container."
  exit 1
fi

echo "Installing DB/cache clients..."
pip install psycopg2-binary redis gunicorn

echo "Applying migrations..."
python manage.py migrate --noinput

echo "Collecting static files..."
python manage.py collectstatic --noinput || true

if [ -n "${PRETIX_ADMIN_EMAIL:-}" ] && [ -n "${PRETIX_ADMIN_PASSWORD:-}" ]; then
python - <<'PYCODE'
from django.contrib.auth import get_user_model
import os
User = get_user_model()
email = os.environ.get("PRETIX_ADMIN_EMAIL")
password = os.environ.get("PRETIX_ADMIN_PASSWORD")
if email and password:
    if not User.objects.filter(email=email).exists():
        User.objects.create_superuser(email=email, password=password, is_active=True)
        print("Created admin:", email)
    else:
        print("Admin already exists:", email)
PYCODE
fi

echo "Starting Pretix (gunicorn on :8000)..."
exec gunicorn pretix.wsgi:application --workers 3 --bind 0.0.0.0:8000 --timeout 180
