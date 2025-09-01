# ACSBridge K25 FT Source Code Package Tool Usage Guide

## File Name
package_acsbridge_K25_FT_source_code.sh

## How to Execute
```bash
# Grant execution permission
chmod +x package_acsbridge_K25_FT_source_code.sh

# Run the script
./package_acsbridge_K25_FT_source_code.sh
```

## Main Functions

### 1. Source Code Copy and Cleanup
- Copy source code from `/home/mcsadmin/acsbridge_K25_FT` to `~/package_acsbridge_K25_FT/`
- Automatically exclude unnecessary files:
  - *.pyc files
  - log/ directory contents  
  - Hidden folders (starting with .)
  - __pycache__/ directories
  - CLAUDE.md file
  - .git* files
  - alembic/versions/ directory contents

### 2. Interactive Configuration Settings
The script reads and allows modification of the following settings in config.py:

**test_type** (Test Type)
- 0: Self testing
- 1: Nick co-testing  
- 2: On-site testing

**project_rack** (Project Rack)
- 0: K15-6F(K25-7F)
- 1: K25-4F
- 2: K8-6F
- 3: K8-3F
- 4: K7-14F

**ft_type** (FT Type)
- 0: FT
- 1: SLT

**has_acsbridge_status** (ACSBridge Status)
- True: Server has installed and started acsbridge_Status
- False: Server has not installed acsbridge_Status

### 3. Version Number Handling
- Automatically read version.txt file to get version number
- Convert dots in version number to underscores for filename compliance

### 4. ZIP File Packaging
- Package processed source code into ZIP file
- Filename format: `acsbridge_K25_{version}_{timestamp}_{factory}_source_code.zip`
- Timestamp format: YYYYMMDD_HHMMSS

### 5. File Copy Options
Provides two copy options:
1. **Default path**: `/mnt/c/Users/kelvi/OneDrive/14_CODE/{folder_name}_{factory}_source_code/`
2. **Custom path**: User-specified target path

## Prerequisites
- Ensure `/home/mcsadmin/acsbridge_K25_FT` directory exists
- Have execution permissions
- Have sufficient disk space for copy and compression operations

## Execution Flow
1. Check if source code directory exists
2. Clean up old package files
3. Copy and clean source code
4. Interactive configuration settings
5. Create timestamped ZIP file
6. Optional copy to specified location
7. Clean up temporary files

## Notes
- Script will automatically create non-existent target directories
- Detailed progress prompts during execution
- All sensitive files and development-related files are automatically excluded