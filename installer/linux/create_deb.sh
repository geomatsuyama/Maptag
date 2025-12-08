#!/bin/bash
# ==============================================================================
# Map Analyzer - Debian Package (.deb) Creation Script
# Version: 1.0.0
# Description: Create .deb package for Ubuntu/Debian
# ==============================================================================

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="map-analyzer"
APP_VERSION="1.0.0"
MAINTAINER="MapAnalyzer Project <support@mapanalyzer.com>"
ARCHITECTURE="amd64"
DEB_NAME="${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}.deb"
BUILD_DIR="../../build/linux/x64/release/bundle"
OUTPUT_DIR="./output"
PACKAGE_DIR="${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}"

# ==============================================================================
# Functions
# ==============================================================================

print_header() {
    echo -e "${BLUE}===================================================${NC}"
    echo -e "${BLUE}  Map Analyzer - Debian Package Builder${NC}"
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
        print_error "Flutter Linux build not found"
        print_info "Run: flutter build linux --release"
        exit 1
    fi
    
    # Check dpkg-deb
    if ! command -v dpkg-deb &> /dev/null; then
        print_error "dpkg-deb not found"
        print_info "Install: sudo apt-get install dpkg"
        exit 1
    fi
    
    print_success "Prerequisites met"
}

create_package_structure() {
    print_step "Creating package structure..."
    
    # Clean previous build
    rm -rf "$PACKAGE_DIR"
    
    # Create Debian package structure
    mkdir -p "$PACKAGE_DIR/DEBIAN"
    mkdir -p "$PACKAGE_DIR/opt/map_analyzer"
    mkdir -p "$PACKAGE_DIR/usr/share/applications"
    mkdir -p "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps"
    mkdir -p "$PACKAGE_DIR/usr/bin"
    
    print_success "Package structure created"
}

copy_application_files() {
    print_step "Copying application files..."
    
    # Copy Flutter bundle to /opt
    cp -r "$BUILD_DIR"/* "$PACKAGE_DIR/opt/map_analyzer/"
    
    # Create launcher script in /usr/bin
    cat > "$PACKAGE_DIR/usr/bin/map-analyzer" << 'EOF'
#!/bin/bash
cd /opt/map_analyzer
exec ./map_analyzer "$@"
EOF
    
    chmod +x "$PACKAGE_DIR/usr/bin/map-analyzer"
    
    print_success "Application files copied"
}

create_control_file() {
    print_step "Creating DEBIAN/control file..."
    
    cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: utils
Priority: optional
Architecture: $ARCHITECTURE
Depends: libgtk-3-0, libglu1-mesa, libc6
Maintainer: $MAINTAINER
Description: Mapillary API & Gemini AI Integration
 Map Analyzer integrates Mapillary street view images with Google Gemini AI
 for advanced image analysis and GIS data export.
 .
 Features:
  - Mapillary image search (point+radius, bbox, polygon)
  - Gemini AI image analysis with custom prompts
  - Export to JSON/Excel/CSV formats
  - Full EXIF metadata support
  - Free/Premium mode (100/200,000 images per search)
Homepage: https://github.com/geomatsuyama/Maptag
EOF
    
    print_success "Control file created"
}

create_postinst_script() {
    print_step "Creating post-installation script..."
    
    cat > "$PACKAGE_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -q /usr/share/icons/hicolor
fi

echo "Map Analyzer installed successfully!"
echo "Launch with: map-analyzer"

exit 0
EOF
    
    chmod +x "$PACKAGE_DIR/DEBIAN/postinst"
    
    print_success "Post-install script created"
}

create_postrm_script() {
    print_step "Creating post-removal script..."
    
    cat > "$PACKAGE_DIR/DEBIAN/postrm" << 'EOF'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -q /usr/share/icons/hicolor
fi

echo "Map Analyzer removed."

exit 0
EOF
    
    chmod +x "$PACKAGE_DIR/DEBIAN/postrm"
    
    print_success "Post-removal script created"
}

create_desktop_file() {
    print_step "Creating desktop entry..."
    
    cat > "$PACKAGE_DIR/usr/share/applications/map-analyzer.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Map Analyzer
GenericName=Mapillary & Gemini AI Integration
Comment=Analyze Mapillary street view images with Gemini AI
Exec=map-analyzer
Icon=map-analyzer
Categories=Utility;Graphics;Science;Geography;
Terminal=false
StartupNotify=true
Keywords=mapillary;gemini;ai;gis;analysis;
EOF
    
    print_success "Desktop entry created"
}

build_deb_package() {
    print_step "Building .deb package..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Build package
    dpkg-deb --build "$PACKAGE_DIR" "$OUTPUT_DIR/$DEB_NAME"
    
    if [ $? -eq 0 ]; then
        print_success "Package built successfully!"
    else
        print_error "Package build failed"
        exit 1
    fi
}

show_summary() {
    print_step "Build Summary"
    
    DEB_PATH="$OUTPUT_DIR/$DEB_NAME"
    DEB_SIZE=$(du -h "$DEB_PATH" | cut -f1)
    
    echo ""
    echo "================================="
    echo "  Debian Package Created!"
    echo "================================="
    echo ""
    echo "File: $DEB_PATH"
    echo "Size: $DEB_SIZE"
    echo ""
    echo "Installation:"
    echo "  sudo dpkg -i $DEB_NAME"
    echo "  sudo apt-get install -f  # Fix dependencies"
    echo ""
    echo "Uninstallation:"
    echo "  sudo apt-get remove $APP_NAME"
    echo ""
    echo "Launch:"
    echo "  map-analyzer"
    echo ""
    print_success "Build completed!"
}

# ==============================================================================
# Main
# ==============================================================================

main() {
    print_header
    
    check_prerequisites
    create_package_structure
    copy_application_files
    create_control_file
    create_postinst_script
    create_postrm_script
    create_desktop_file
    build_deb_package
    show_summary
}

main "$@"
