#!/bin/bash

function print_batman() {
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  echo "           _                         _"
  echo "       _==/          i     i          \=="
  echo "     /XX/            |\___/|            \XX\\"
  echo "   /XXXX\            |XXXXX|            /XXXX\\"
  echo "  |XXXXXX\_         _XXXXXXX_         _/XXXXXX|"
  echo " XXXXXXXXXXXxxxxxxxXXXXXXXXXXXxxxxxxxXXXXXXXXXXX"
  echo "|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|"
  echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  echo "|XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX|"
  echo " XXXXXX/^^^^\"\XXXXXXXXXXXXXXXXXXXXX/^^^^^\XXXXXX"
  echo "  |XXX|       \XXX/^^\XXXXX/^^\XXX/       |XXX|"
  echo "    \XX\       \X/    \XXX/    \X/       /XX/"
  echo "       \"\       \"      \X/      \"       /\""
  echo "      SJG               !"
  echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

function print_error_image() {
  echo "++++++++++++++++++++++++++++++++++++++++++++++"
  echo "                                  .-."
  echo "     (___________________________()6 \`-,"
  echo "     (   ______________________   /''\""
  echo "     //\\\\                      //\\\\"
  echo "     \"\" \"\"                     \"\" \"\""
  echo "++++++++++++++++++++++++++++++++++++++++++++++"
}

function print_info_about_waiting_for_closing_application() {
  for i in {3..1}; do
    echo "Waiting for closing old application - $i seconds left"
    sleep 1
  done
}

function print_info_about_closing_window_soon() {
  for i in {5..1}; do
    echo "Window will be closed in $i seconds"
    sleep 1
  done
}

function wait_for_pressing_key() {
  echo "Press any button to exit..."
  read
}

# Wait few seconds
print_info_about_waiting_for_closing_application

# Define directories and filenames
CURRENT_DIR="$(pwd)"
OLD_APP_NAME="script-control-panel.jar"
NEW_APP_NAME="new_script-control-panel.jar"

# Check if $NEW_APP_NAME exists in the current directory
if [ ! -f "$CURRENT_DIR/$NEW_APP_NAME" ]; then
  echo "Error: $CURRENT_DIR/$NEW_APP_NAME not found!"
  print_error_image
  wait_for_pressing_key
  exit 1
fi

# Move one level up from the current directory
cd ..

# Define the target directory after moving up
TARGET_DIR="$(pwd)"

# Replace the old JAR with the new one
mv -f "$CURRENT_DIR/$NEW_APP_NAME" "$TARGET_DIR/$OLD_APP_NAME"
if [ $? -ne 0 ]; then
  echo "Error: Failed to move $CURRENT_DIR/$NEW_APP_NAME to $TARGET_DIR/$OLD_APP_NAME!"
  print_error_image
  wait_for_pressing_key
  exit 1
fi

# Function to get the value of JAVA_PATH from a specified JSON file
get_java_path_variable_for_file() {
  local file="$1"
  local java_path=$(jq -r '.settings[] | select(.key == "JAVA_PATH") | .value' "$1")
  echo "$java_path"
}

# Function to get the value of JAVA_PATH, checking multiple files
get_java_path_variable() {
  local my_own_settings_file="../config/my_own_settings.json"
  local settings_file="../config/settings.json"

  local java_path=$(get_java_path_variable_for_file "$my_own_settings_file")

  if [ -z "$java_path" ]; then
    java_path=$(get_java_path_variable_for_file "$settings_file")
  fi

  echo "$java_path"
}

# Function to get the value of JAVA_PATH from a specified JSON file
get_java_path_variable_for_file() {
  local json_file="$1"
  local java_path=$(awk '
        BEGIN { RS="{"; FS="," }
        /"key": "JAVA_PATH"/ {
          for (i = 1; i <= NF; i++) {
            if ($i ~ /"value":/) {
              gsub(/.*"value": *"/, "", $i)
              gsub(/".*/, "", $i)
              print $i
              exit 0
            }
          }
        }
        ' "$json_file")
  echo "$java_path"
}

# Function to get the value of JAVA_PATH, checking multiple files
get_java_path_variable() {
  local my_own_settings_file="../config/my_own_settings.json"
  local settings_file="../config/default_settings.json"

  local java_path=$(get_java_path_variable_for_file "$my_own_settings_file")

  if [ -z "$java_path" ]; then
    java_path=$(get_java_path_variable_for_file "$settings_file")
  fi

  echo "$java_path"
}

# Function to run script-control-panel.jar
run_script_control_panel() {
  local java_path="$(get_java_path_variable)"
  if [ -n "$java_path" ]; then
    local java_dir_path="$java_path\\java"
    echo "Executing JAR with custom Java path: '$java_dir_path'"
    nohup "$java_path" -jar "$TARGET_DIR/$OLD_APP_NAME" > "$TARGET_DIR/tmp/app_update.log" 2>&1 &
  else
    echo "Executing JAR with standard JAVA_HOME path: '$JAVA_HOME'"
    nohup java -jar "$TARGET_DIR/$OLD_APP_NAME" > "$TARGET_DIR/tmp/app_update.log" 2>&1 &
  fi
}

# Restart the application
run_script_control_panel
if [ $? -ne 0 ]; then
  echo "Error: Failed to start the application!"
  print_error_image
  wait_for_pressing_key
  exit 1
fi

echo "------------------------------------------------------"
echo "Application updated successfully!"
echo "------------------------------------------------------"
print_batman
print_info_about_closing_window_soon