#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Configuration
PROJECT_GIT_URL='https://github.com/achahid19/Profiles-REST-API.git'

PROJECT_BASE_PATH='/usr/local/apps/profiles-rest-api'

echo "Installing system dependencies..."
apt-get update
apt-get install -y python3-dev python3-venv sqlite3 python3-pip supervisor nginx git build-essential libssl-dev libffi-dev zlib1g-dev

# Clone the project repository
if [ ! -d "$PROJECT_BASE_PATH" ]; then
    echo "Cloning project repository..."
    mkdir -p $PROJECT_BASE_PATH
    git clone $PROJECT_GIT_URL $PROJECT_BASE_PATH
else
    echo "Project directory already exists. Pulling latest changes..."
    cd $PROJECT_BASE_PATH
    git pull
fi

# Create virtual environment
if [ ! -d "$PROJECT_BASE_PATH/env" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv $PROJECT_BASE_PATH/env
else
    echo "Virtual environment already exists."
fi

# Install Python dependencies
echo "Installing Python dependencies..."
$PROJECT_BASE_PATH/env/bin/pip install --upgrade pip setuptools wheel
$PROJECT_BASE_PATH/env/bin/pip install -r $PROJECT_BASE_PATH/requirements.txt

# Handle uWSGI installation explicitly
echo "Installing uWSGI..."
$PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.21 || {
    echo "uWSGI installation failed. Attempting with updated build flags..."
    CFLAGS="-Wno-deprecated-declarations" $PROJECT_BASE_PATH/env/bin/pip install uwsgi==2.0.21
}

# Run migrations and collect static files
echo "Running migrations and collecting static files..."
cd $PROJECT_BASE_PATH
$PROJECT_BASE_PATH/env/bin/python manage.py migrate
$PROJECT_BASE_PATH/env/bin/python manage.py collectstatic --noinput

# Configure Supervisor
echo "Configuring Supervisor..."
cp $PROJECT_BASE_PATH/deploy/supervisor_profiles_api.conf /etc/supervisor/conf.d/profiles_api.conf
supervisorctl reread
supervisorctl update
supervisorctl restart profiles_api

# Configure Nginx
echo "Configuring Nginx..."
cp $PROJECT_BASE_PATH/deploy/nginx_profiles_api.conf /etc/nginx/sites-available/profiles_api.conf
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi
ln -sf /etc/nginx/sites-available/profiles_api.conf /etc/nginx/sites-enabled/profiles_api.conf
systemctl restart nginx.service

echo "DONE! :)"
