#!/bin/bash

echo "🔐 Testing DevKazi API Endpoints"
echo "=================================="

# Base URL
BASE_URL="http://localhost:3001/api/v1"

# Step 1: Login
echo ""
echo "1. Logging in..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@student.com",
    "password": "password123"
  }')

echo "Login Response: $LOGIN_RESPONSE"

# Extract token from response
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "❌ Failed to get access token"
    exit 1
fi

echo "✅ Token obtained: ${TOKEN:0:20}..."

# Step 2: Test protected endpoints
echo ""
echo "2. Testing teams endpoint..."
TEAMS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/teams")
echo "Teams: $TEAMS_RESPONSE"

echo ""
echo "3. Testing posts endpoint..."
POSTS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/posts")
echo "Posts: $POSTS_RESPONSE"

echo ""
echo "4. Testing user profile..."
USER_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" "$BASE_URL/users/me")
echo "User Profile: $USER_RESPONSE"

echo ""
echo "✅ API Test Completed!"