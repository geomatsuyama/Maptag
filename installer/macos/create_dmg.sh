#!/bin/bash
# ==============================================================================
# Map Analyzer - macOS DMG Installer Creation Script
# Version: 1.0.0
# Description: Create professional macOS .dmg installer
# ==============================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Map Analyzer"
APP_BUNDLE="map_analyzer.app"
VERSION="1.0.0"
DMG_NAME="MapAnalyzer_v${VERSION}_macOS"
BUILD_DIR="../../build/macos/Build/Products/Release"
OUTPUT_DIR="./output"
BACKGROUND_IMAGE="./dmg_background.png"
ICON_FILE="./icon.icns"

# ==============================================================================
# Functions
# ==============================================================================

print_header() {
    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}  Map Analyzer - macOS DMG Installer Builder${NC}"
    echo -e "${BLUE}===================================================${NC}"
}

print_step() {
    echo -e "\n${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script must be run on macOS"
        exit 1
    fi
    
    # Check Flutter build
    if [ ! -d "$BUILD_DIR/$APP_BUNDLE" ]; then
        print_error "Flutter macOS build not found at $BUILD_DIR/$APP_BUNDLE"
        print_info "Please run: flutter build macos --release"
        exit 1
    fi
    
    # Check create-dmg tool
    if ! command -v create-dmg &> /dev/null; then
        print_warning "create-dmg not found. Installing via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install create-dmg
        else
            print_error "Homebrew not found. Please install Homebrew first:"
            print_info "https://brew.sh"
            exit 1
        fi
    fi
    
    print_success "All prerequisites met"
}

prepare_output_directory() {
    print_step "Preparing output directory..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Clean previous DMG files
    if [ -f "$OUTPUT_DIR/$DMG_NAME.dmg" ]; then
        print_info "Removing previous DMG file..."
        rm -f "$OUTPUT_DIR/$DMG_NAME.dmg"
    fi
    
    print_success "Output directory ready: $OUTPUT_DIR"
}

create_dmg_background() {
    print_step "Creating DMG background image..."
    
    # Create simple background if not exists
    if [ ! -f "$BACKGROUND_IMAGE" ]; then
        print_info "Generating default background..."
        
        # Create a simple gradient background using ImageMagick (if available)
        if command -v convert &> /dev/null; then
            convert -size 660x400 gradient:'#1a237e-#283593' "$BACKGROUND_IMAGE"
        else
            print_warning "ImageMagick not found. Using default background."
        fi
    fi
}

build_dmg() {
    print_step "Building DMG installer..."
    
    print_info "App Bundle: $BUILD_DIR/$APP_BUNDLE"
    print_info "Output: $OUTPUT_DIR/$DMG_NAME.dmg"
    
    create-dmg \
        --volname "$APP_NAME" \
        --volicon "$BUILD_DIR/$APP_BUNDLE/Contents/Resources/AppIcon.icns" \
        --window-pos 200 120 \
        --window-size 660 400 \
        --icon-size 100 \
        --icon "$APP_BUNDLE" 180 170 \
        --hide-extension "$APP_BUNDLE" \
        --app-drop-link 480 170 \
        --no-internet-enable \
        "$OUTPUT_DIR/$DMG_NAME.dmg" \
        "$BUILD_DIR/$APP_BUNDLE"
    
    if [ $? -eq 0 ]; then
        print_success "DMG created successfully!"
    else
        print_error "DMG creation failed"
        exit 1
    fi
}

show_summary() {
    print_step "Build Summary"
    
    DMG_PATH="$OUTPUT_DIR/$DMG_NAME.dmg"
    DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
    
    echo ""
    echo "================================="
    echo "  DMG Installer Created!"
    echo "================================="
    echo ""
    echo "File: $DMG_PATH"
    echo "Size: $DMG_SIZE"
    echo ""
    echo "Installation Instructions:"
    echo "1. Open the DMG file"
    echo "2. Drag 'Map Analyzer' to Applications folder"
    echo "3. Eject the DMG"
    echo "4. Launch from Applications"
    echo ""
    echo "Distribution:"
    echo "- Upload to GitHub Releases"
    echo "- Share download link with users"
    echo ""
    print_success "Build completed successfully!"
}

# ==============================================================================
# Main Execution
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    prepare_output_directory
    create_dmg_background
    build_dmg
    show_summary
}

# Run main function
main "$@"
