#!/bin/bash
# ==============================================================================
# Map Analyzer - Linux AppImage Creation Script
# Version: 1.0.0
# Description: Create portable Linux AppImage installer
# ==============================================================================

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="Map Analyzer"
APP_ID="com.mapanalyzer.analysis"
VERSION="1.0.0"
APPIMAGE_NAME="MapAnalyzer-${VERSION}-x86_64.AppImage"
BUILD_DIR="../../build/linux/x64/release/bundle"
OUTPUT_DIR="./output"
APPDIR="MapAnalyzer.AppDir"

# ==============================================================================
# Functions
# ==============================================================================

print_header() {
    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}  Map Analyzer - Linux AppImage Builder${NC}"
    echo -e "${BLUE}===================================================${NC}"
}

print_step() {
    echo -e "\n${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check Flutter build
    if [ ! -d "$BUILD_DIR" ]; then
        print_error "Flutter Linux build not found at $BUILD_DIR"
        print_info "Please run: flutter build linux --release"
        exit 1
    fi
    
    # Check appimagetool
    if ! command -v appimagetool &> /dev/null; then
        print_info "Downloading appimagetool..."
        wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
        chmod +x appimagetool
    fi
    
    print_success "Prerequisites checked"
}

create_appdir_structure() {
    print_step "Creating AppDir structure..."
    
    # Clean previous AppDir
    rm -rf "$APPDIR"
    
    # Create AppDir structure
    mkdir -p "$APPDIR/usr/bin"
    mkdir -p "$APPDIR/usr/lib"
    mkdir -p "$APPDIR/usr/share/applications"
    mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
    
    print_success "AppDir structure created"
}

copy_application_files() {
    print_step "Copying application files..."
    
    # Copy Flutter bundle
    cp -r "$BUILD_DIR"/* "$APPDIR/usr/bin/"
    
    # Copy libraries
    cp -r "$BUILD_DIR/lib"/* "$APPDIR/usr/lib/" 2>/dev/null || true
    
    print_success "Application files copied"
}

create_desktop_file() {
    print_step "Creating .desktop file..."
    
    cat > "$APPDIR/map_analyzer.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Map Analyzer
GenericName=Mapillary & Gemini AI Integration
Comment=Analyze Mapillary images with Gemini AI
Exec=map_analyzer
Icon=map_analyzer
Categories=Utility;Graphics;Science;
Terminal=false
StartupNotify=true
EOF
    
    # Copy desktop file to proper location
    cp "$APPDIR/map_analyzer.desktop" "$APPDIR/usr/share/applications/"
    
    print_success "Desktop file created"
}

create_apprun_script() {
    print_step "Creating AppRun script..."
    
    cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
# AppRun script for Map Analyzer

SELF=$(readlink -f "$0")
HERE=${SELF%/*}

export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"

# Set GTK theme
export GTK_THEME=Adwaita:dark

# Run the application
exec "${HERE}/usr/bin/map_analyzer" "$@"
EOF
    
    chmod +x "$APPDIR/AppRun"
    
    print_success "AppRun script created"
}

extract_icon() {
    print_step "Extracting application icon..."
    
    # Try to extract icon from Flutter build
    if [ -f "$BUILD_DIR/data/flutter_assets/assets/icon.png" ]; then
        cp "$BUILD_DIR/data/flutter_assets/assets/icon.png" \
           "$APPDIR/usr/share/icons/hicolor/256x256/apps/map_analyzer.png"
    else
        print_info "Creating default icon..."
        # Create a simple colored square as fallback
        echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -d > "$APPDIR/map_analyzer.png"
    fi
    
    # Link icon to AppDir root
    ln -sf "usr/share/icons/hicolor/256x256/apps/map_analyzer.png" "$APPDIR/map_analyzer.png"
    
    print_success "Icon extracted"
}

build_appimage() {
    print_step "Building AppImage..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Build AppImage
    if command -v appimagetool &> /dev/null; then
        APPIMAGE_TOOL="appimagetool"
    else
        APPIMAGE_TOOL="./appimagetool"
    fi
    
    ARCH=x86_64 "$APPIMAGE_TOOL" "$APPDIR" "$OUTPUT_DIR/$APPIMAGE_NAME"
    
    if [ $? -eq 0 ]; then
        chmod +x "$OUTPUT_DIR/$APPIMAGE_NAME"
        print_success "AppImage built successfully!"
    else
        print_error "AppImage build failed"
        exit 1
    fi
}

show_summary() {
    print_step "Build Summary"
    
    APPIMAGE_PATH="$OUTPUT_DIR/$APPIMAGE_NAME"
    APPIMAGE_SIZE=$(du -h "$APPIMAGE_PATH" | cut -f1)
    
    echo ""
    echo "================================="
    echo "  AppImage Created!"
    echo "================================="
    echo ""
    echo "File: $APPIMAGE_PATH"
    echo "Size: $APPIMAGE_SIZE"
    echo ""
    echo "Installation Instructions:"
    echo "1. Download the AppImage file"
    echo "2. Make it executable: chmod +x $APPIMAGE_NAME"
    echo "3. Run: ./$APPIMAGE_NAME"
    echo ""
    echo "Integration:"
    echo "- Right-click → 'Integrate and run'"
    echo "- Or use AppImageLauncher"
    echo ""
    print_success "Build completed!"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    create_appdir_structure
    copy_application_files
    create_desktop_file
    create_apprun_script
    extract_icon
    build_appimage
    show_summary
}

main "$@"
