#!/bin/bash

# Complete SonarQube Setup and Analysis Script
# This script handles everything: Docker setup, project creation, token generation, and Gradle analysis

set -e  # Exit on any error

# Configuration
SONAR_URL="http://localhost:9000"
SONAR_USER="YOUR_USER"
SONAR_PASS="YOUR_PASSWORD"
PROJECT_KEY="${1:-YOUR_PROJECT}"  # Use command line argument or default
BUILD_GRADLE_FILE="build.gradle"
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Functions
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
print_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_step "🚀 Starting Complete SonarQube Setup for project: $PROJECT_KEY"

# ========================================
print_info "Creating SonarQube project: $PROJECT_KEY"
CREATE_RESPONSE=$(curl -s -u "$SONAR_USER:$SONAR_PASS" -X POST "$SONAR_URL/api/projects/create?project=$PROJECT_KEY&name=$PROJECT_KEY")

if echo "$CREATE_RESPONSE" | grep -q "errors"; then
    if echo "$CREATE_RESPONSE" | grep -q "already exists"; then
        print_info "Project already exists, continuing..."
    else
        print_warn "Project creation response: $CREATE_RESPONSE"
    fi
else
    print_info "Project created successfully!"
fi

# Generate authentication token
print_info "Generating authentication token..."
TOKEN_NAME="${PROJECT_KEY}-token-$(date +%s)"
TOKEN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" \
    -d "name=$TOKEN_NAME" \
    -u "$SONAR_USER:$SONAR_PASS" \
    "$SONAR_URL/api/user_tokens/generate")

# Extract token from JSON response
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    print_error "Failed to generate token!"
    echo "Response: $TOKEN_RESPONSE"
    exit 1
fi

print_info "Token generated successfully: ${TOKEN:0:20}..."

# ========================================
# PART 1: BUILD.GRADLE UPDATE
# ========================================
print_step "1. Updating build.gradle configuration"

# Create backup
cp "$BUILD_GRADLE_FILE" "${BUILD_GRADLE_FILE}.backup"
print_info "Backup created: ${BUILD_GRADLE_FILE}.backup"

# Update or create sonarqube block
if grep -q "sonarqube {" "$BUILD_GRADLE_FILE"; then
    print_info "Updating existing sonarqube block..."
    
    # Update existing values
    sed -i "s|property \"sonar.projectKey\", \".*\"|property \"sonar.projectKey\", \"$PROJECT_KEY\"|g" "$BUILD_GRADLE_FILE"
    sed -i "s|property \"sonar.host.url\", \".*\"|property \"sonar.host.url\", \"$SONAR_URL\"|g" "$BUILD_GRADLE_FILE"
    sed -i "s|property \"sonar.login\", \".*\"|property \"sonar.login\", \"$TOKEN\"|g" "$BUILD_GRADLE_FILE"
else
    print_info "Adding new sonarqube block..."
    # Add sonarqube block at the end of file
    cat >> "$BUILD_GRADLE_FILE" << EOF
sonarqube {
    properties {
        property "sonar.projectKey", "$PROJECT_KEY"
        property "sonar.host.url", "$SONAR_URL"
        property "sonar.login", "$TOKEN"
    }
}
EOF
fi
# ========================================
# PART 2: RUN ANALYSIS
# ========================================
print_step "2. Running SonarQube analysis"
print_info "Current sonarqube configuration:"
print_info "Compiling project..."
sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-11-openjdk-amd64/bin/javac
./gradlew test
./gradlew jacocoTestReport
sudo update-alternatives --set java /usr/lib/jvm/java-17-openjdk-amd64/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-17-openjdk-amd64/bin/javac
print_info "Running SonarQube analysis..."
./gradlew sonar
# ========================================
# COMPLETION
# ========================================
print_step "3. ✅ Setup Complete!"
print_info "🎉 SonarQube analysis completed successfully!"
echo ""
echo "📊 View your results:"
echo "   URL: $SONAR_URL/dashboard?id=$PROJECT_KEY"
echo "   Login: $SONAR_USER / $SONAR_PASS"
echo ""
echo "🔧 Configuration Details:"
echo "   Project Key: $PROJECT_KEY"
echo "   Token Name: $TOKEN_NAME" 
echo "   Docker Container: sonarqube (running on port 9000)"
echo ""
echo "🚀 Next time, just run: ./gradlew sonar"
echo ""
print_info "Script completed successfully! 🎊"
