#!/bin/bash

echo "Giving Connection Docker Method Setup Script started."
sleep 1
echo "This command will take at least 2 full minutes to complete."
sleep 1

MAC=false
# Determine if the platform is macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  MAC=true
  echo -e "\033[1;33mRunning on macOS.\033[0m"
else
  echo -e "\033[1;33mRunning on Linux.\033[0m"
fi


# Check and modify .env file
if ! grep -q "redis://redis:6379" .env; then
  echo -e "\033[1;32mModifying .env file...\033[0m"
  if $MAC; then
    sed -i '' 's|redis://localhost:6379|redis://redis:6379|g' .env
  else
    sed -i 's|redis://localhost:6379|redis://redis:6379|g' .env
  fi
else
  echo -e "\033[1;33m.env file already modified.\033[0m"
fi

# Check and modify Gemfile
if ! grep -q 'ruby "~> 3.1.0"' Gemfile; then
  echo -e "\033[1;32mModifying Gemfile...\033[0m"
  if $MAC; then
    sed -i '' 's|ruby "3.1.0"|ruby "~> 3.1.0"|g' Gemfile
  else
    sed -i 's|ruby "3.1.0"|ruby "~> 3.1.0"|g' Gemfile
  fi
else
  echo -e "\033[1;33mGemfile already modified.\033[0m"
fi

# Check and modify config/database.yml for host and username
if grep -q "#username: giving_connection" config/database.yml; then
  echo -e "\033[1;32mModifying config/database.yml file...\033[0m"
  if $MAC; then
    sed -i '' 's|#username: giving_connection|username: postgres|g' config/database.yml
  else 
    sed -i 's|#username: giving_connection|username: postgres|g' config/database.yml
  fi
else
  echo -e "\033[1;33mconfig/database.yml file already modified.\033[0m"
fi

# Modify specific lines in config/database.yml if not set
if grep -q "#host: localhost" config/database.yml; then
  if $MAC; then
    sed -i '' 's|#host: localhost|host: db|g' config/database.yml
  else
    sed -i 's|#host: localhost|host: db|g' config/database.yml
  fi
fi

if ! sed -n '62p' config/database.yml | grep -q "host: db"; then
  if $MAC; then
    sed -i '' '62i\
  host: db' config/database.yml
  else
    sed -i '62i\
  host: db' config/database.yml
  fi
fi

if ! sed -n '63p' config/database.yml | grep -q "username: postgres"; then
  if $MAC; then
    sed -i '' '63i\
  username: postgres' config/database.yml
  else
    sed -i '63i\
  username: postgres' config/database.yml
  fi
fi



# Finished editing, now building the image and initializing the container
echo -e "\033[1;34mPulling the image and initializing the container (this will take some time!)...\033[0m"
sleep 1
echo ""

if docker-compose build --no-cache; then
    echo ""
    echo -e "\033[1;32mImage built successfully!\033[0m"
    sleep 1
else
    echo ""
    echo -e "\033[1;31mError building the image.\033[0m"
    exit 1
fi

echo -e "\033[1;34mStarting the container...\033[0m"
sleep 1

if docker-compose up -d; then
    echo ""
    echo -e "\033[1;32mContainer started successfully!\033[0m"
    sleep 1
else
    echo ""
    echo -e "\033[1;31mError starting the container.\033[0m"
    exit 1
fi

# Corrected the logging command to ensure proper script execution
docker-compose logs -f web
