#!/bin/bash

# Set your Signal profile picture (avatar)
# Usage: ./set-profile-avatar.sh "Name" path/to/image.jpg

SIGNAL_NUMBER="+40751770274"
SIGNAL_API_URL="http://localhost:8080"

# Check if name and image file are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "❌ Error: Please provide a name and image file"
    echo ""
    echo "Usage: ./set-profile-avatar.sh \"Your Name\" path/to/image.jpg"
    echo ""
    echo "Examples:"
    echo "  ./set-profile-avatar.sh \"Amatsu\" ~/Pictures/profile.jpg"
    echo "  ./set-profile-avatar.sh \"Amatsu\" ./avatar.png"
    echo "  ./set-profile-avatar.sh \"Amatsu\" ../signal-poc/AmatsuLogo.png"
    echo ""
    echo "Supported formats: JPG, PNG, GIF, WebP"
    exit 1
fi

PROFILE_NAME="$1"
IMAGE_FILE="$2"

# Check if file exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo "❌ Error: File not found: $IMAGE_FILE"
    exit 1
fi

echo "========================================="
echo "Setting Signal Profile Picture"
echo "========================================="
echo ""
echo "Phone Number: $SIGNAL_NUMBER"
echo "Profile Name: $PROFILE_NAME"
echo "Image File: $IMAGE_FILE"
echo ""

# Get file size
FILE_SIZE=$(wc -c < "$IMAGE_FILE" | tr -d ' ')
echo "File Size: $((FILE_SIZE / 1024)) KB"

# Check file size (Signal has limits, typically around 5MB)
if [ $FILE_SIZE -gt 5242880 ]; then
    echo "⚠️  Warning: File is larger than 5MB"
    echo "   Signal may reject large images"
    echo ""
fi

echo ""
echo "Converting image to base64..."

# Convert image to base64
if command -v base64 > /dev/null; then
    # macOS/Linux base64
    BASE64_IMAGE=$(base64 -i "$IMAGE_FILE" | tr -d '\n')
else
    echo "❌ Error: base64 command not found"
    exit 1
fi

echo "✅ Image converted"
echo ""
echo "Uploading to Signal..."

# Set profile with avatar and name
response=$(curl -s -w "\n%{http_code}" -X PUT \
  "$SIGNAL_API_URL/v1/profiles/$SIGNAL_NUMBER" \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"$PROFILE_NAME\",
    \"avatar\": \"$BASE64_IMAGE\"
  }")

# Get HTTP status code (last line)
http_code=$(echo "$response" | tail -n1)
# Get response body (everything except last line)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 204 ]; then
    echo "✅ Profile picture set successfully!"
    echo ""
    echo "Your new profile picture is now active."
    echo ""
    echo "Note: It may take a few moments for recipients to see the updated picture."
else
    echo "❌ Failed to set profile picture"
    echo "HTTP Status: $http_code"
    echo "Response: $body"
    echo ""
    echo "Make sure:"
    echo "  - Signal API is running (docker ps | grep signal)"
    echo "  - Your number is registered or linked"
    echo "  - Image file is valid (JPG, PNG, GIF, WebP)"
    echo "  - Image is not too large (< 5MB recommended)"
fi

echo ""
echo "========================================="

