#!/bin/bash
# Reference: https://github.com/target/strelka/

# Exit immediately if a command exits with a non-zero status
set -e

# Check if home_path is provided
if [ -z "$1" ]; then
  printf "Usage: %s <home_path>\n" "$0"
  exit 1
fi

home_path=$1
STRELKA_GIT_COMMIT=${STRELKA_GIT_COMMIT:-"0.24.07.09"}
STRELKA_UI_GIT_COMMIT=${STRELKA_UI_GIT_COMMIT:-"024610a88ddfec9f441cf7f52bc4a666536e60ad"}

# Step 1: Clone the Strelka UI repository and check out the specific commit
printf "Cloning the Strelka UI repository and checking out commit %s...\n" "$STRELKA_UI_GIT_COMMIT"
if [ -d "strelka-ui" -a -d "strelka-ui/.git" ]; then
  cd strelka-ui
  git pull
else
  git clone https://github.com/target/strelka-ui.git
  cd strelka-ui
fi
git checkout "$STRELKA_UI_GIT_COMMIT"

# Step 2: Update the homepage in package.json and config.js
#TMP disable this step to use rewrite on the nginx side
cd ui
sed -i 's/"homepage": "\/"/"homepage": "\/strelka"/g' package.json
if grep -q '"homepage": "/strelka"' package.json; then
   echo "Update homepage successful"
else
   echo "Update homepage failed"
fi

sed -i "s|baseUrl: '/'|baseUrl: '/strelka'|" public/config.js

# Step 3: Build the Strelka UI Docker image
cd ..
docker compose build
cd ..

# Step 4: Clone the Strelka repository and check out the specific commit
printf "Cloning the Strelka repository and checking out commit %s...\n" "$STRELKA_GIT_COMMIT"
if [ -d "strelka" -a -d "strelka/.git" ]; then
  cd strelka
  git pull
else
  git clone https://github.com/target/strelka.git
  cd strelka
fi
git checkout "$STRELKA_GIT_COMMIT"

# Step 5: Copy the docker-compose.yaml file from the specified home_path
printf "Copying docker-compose.yaml from %s...\n" "$home_path"
cp "$home_path/resources/strelka/docker-compose.yaml" build/docker-compose.yaml

# Step 6: Build and bring up the Strelka services
printf "Building and bringing up the Strelka services...\n"
docker compose -f build/docker-compose.yaml build
docker compose -f build/docker-compose.yaml up -d

printf "Strelka deployment completed successfully.\n"
