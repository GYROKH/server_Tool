#! /bin/bash



folder_name=acsbridge_K25_FT

# Function to read current config values
read_config_value() {
    local config_file="$1"
    local config_name="$2"
    grep "self\.$config_name = [0-9]" "$config_file" | head -1 | sed 's/.*= *\([0-9]*\).*/\1/'
}

# Function to update config value
update_config_value() {
    local config_file="$1"
    local config_name="$2"
    local new_value="$3"
    sed -i "s/\(self\.$config_name = \)[0-9]*\(  # .*\)/\1$new_value\2/" "$config_file"
}

# Function to read boolean config values
read_boolean_config_value() {
    local config_file="$1"
    local config_name="$2"
    grep "self\.$config_name=" "$config_file" | head -1 | sed 's/.*=\(.*\)/\1/' | tr -d ' '
}

# Function to update boolean config value
update_boolean_config_value() {
    local config_file="$1"
    local config_name="$2"
    local new_value="$3"
    sed -i "s/\(self\.$config_name=\).*/\1$new_value/" "$config_file"
}

# Function to display config options and get user choice
configure_settings() {
    local config_file="$HOME/package_acsbridge_K25_FT/$folder_name/config.py"
    
    echo "==============================================="
    echo "Configuration Options"
    echo "==============================================="
    
    # Read current values
    local current_test_type=$(read_config_value "$config_file" "test_type")
    local current_project_rack=$(read_config_value "$config_file" "project_rack")
    local current_ft_type=$(read_config_value "$config_file" "ft_type")
    local current_has_acsbridge_status=$(read_boolean_config_value "$config_file" "has_acsbridge_status")
    
    echo "Current configuration:"
    echo "  test_type = $current_test_type (0:自己測, 1:Nick對測, 2:現場)"
    echo "  project_rack = $current_project_rack (0:K15-6F(K25-7F), 1:K25-4F, 2:K8-6F, 3:K8-3F, 4:K7-14F)"
    echo "  ft_type = $current_ft_type (0:FT, 1:SLT)"
    echo "  has_acsbridge_status = $current_has_acsbridge_status (Server是否已經安裝且啟動 acsbridge_Status)"
    echo ""
    
    # Ask if user wants to modify settings
    read -p "Do you want to modify these settings? (y/N): " modify_choice
    if [[ ! "$modify_choice" =~ ^[Yy]$ ]]; then
        echo "Keeping current configuration."
        # Still need to set factory based on current config
        final_project_rack=$current_project_rack
    else
    
    # Configure test_type
    echo ""
    echo "=== Test Type Configuration ==="
    echo "0: 自己測"
    echo "1: Nick對測" 
    echo "2: 現場"
    echo "Current: $current_test_type"
    read -p "Enter new test_type (0-2) or press Enter to keep current: " new_test_type
    if [[ -n "$new_test_type" && "$new_test_type" =~ ^[0-2]$ ]]; then
        update_config_value "$config_file" "test_type" "$new_test_type"
        echo "Updated test_type to $new_test_type"
    fi
    
    # Configure project_rack
    echo ""
    echo "=== Project Rack Configuration ==="
    echo "0: K15-6F(K25-7F)"
    echo "1: K25-4F"
    echo "2: K8-6F"
    echo "3: K8-3F"
    echo "4: K7-14F"
    echo "Current: $current_project_rack"
    read -p "Enter new project_rack (0-4) or press Enter to keep current: " new_project_rack
    if [[ -n "$new_project_rack" && "$new_project_rack" =~ ^[0-4]$ ]]; then
        update_config_value "$config_file" "project_rack" "$new_project_rack"
        echo "Updated project_rack to $new_project_rack"
    fi
    
    # Configure ft_type
    echo ""
    echo "=== FT Type Configuration ==="
    echo "0: FT"
    echo "1: SLT"
    echo "Current: $current_ft_type"
    read -p "Enter new ft_type (0-1) or press Enter to keep current: " new_ft_type
    if [[ -n "$new_ft_type" && "$new_ft_type" =~ ^[0-1]$ ]]; then
        update_config_value "$config_file" "ft_type" "$new_ft_type"
        echo "Updated ft_type to $new_ft_type"
    fi
    
    # Configure has_acsbridge_status
    echo ""
    echo "=== ACSBridge Status Configuration ==="
    echo "Server是否已經安裝且啟動 acsbridge_Status?"
    echo "Current: $current_has_acsbridge_status"
    read -p "Enter Y for True, N for False, or press Enter to keep current: " acsbridge_choice
    if [[ -n "$acsbridge_choice" ]]; then
        if [[ "$acsbridge_choice" =~ ^[Yy]$ ]]; then
            update_boolean_config_value "$config_file" "has_acsbridge_status" "True"
            echo "Updated has_acsbridge_status to True"
        elif [[ "$acsbridge_choice" =~ ^[Nn]$ ]]; then
            update_boolean_config_value "$config_file" "has_acsbridge_status" "False"
            echo "Updated has_acsbridge_status to False"
        else
            echo "Invalid input. Keeping current value."
        fi
    fi
    
        echo ""
        echo "Configuration update completed!"
        
        # Read final configuration after updates
        final_project_rack=$(read_config_value "$config_file" "project_rack")
    fi
    
    # Display final configuration
    local final_test_type=$(read_config_value "$config_file" "test_type")
    local final_ft_type=$(read_config_value "$config_file" "ft_type")
    local final_has_acsbridge_status=$(read_boolean_config_value "$config_file" "has_acsbridge_status")
    
    echo "Final configuration:"
    echo "  test_type = $final_test_type"
    echo "  project_rack = $final_project_rack"
    echo "  ft_type = $final_ft_type"
    echo "  has_acsbridge_status = $final_has_acsbridge_status"
    
    # Set factory based on project_rack selection
    case $final_project_rack in
        0)
            echo ""
            echo "=== Factory Selection for project_rack 0 ==="
            echo "0: K15-6F"
            echo "1: K25-7F"
            read -p "Select factory (0 for K15-6F, 1 for K25-7F): " factory_choice
            if [[ "$factory_choice" == "0" ]]; then
                factory="K15-6F"
            elif [[ "$factory_choice" == "1" ]]; then
                factory="K25-7F"
            else
                echo "Invalid choice, defaulting to K25-7F"
                factory="K25-7F"
            fi
            ;;
        1)
            factory="K25-4F"
            ;;
        2)
            factory="K8-6F"
            ;;
        3)
            factory="K8-3F"
            ;;
        4)
            factory="K7-14F"
            ;;
        *)
            factory="Unknown"
            ;;
    esac
    
    echo "  factory = $factory"
    echo "==============================================="
}



# Check if source folder exists
source_path="/home/mcsadmin/$folder_name"
if [ ! -d "$source_path" ]; then
    echo "錯誤: 文件夾 '$source_path' 不存在"
    exit 1
fi

# Navigate to package_acsbridge directory
cd ~/package_acsbridge_K25_FT

# Delete all files except .sh files

rm -rf $folder_name

rm -rf *.zip




# Copy the source folder and rename to tsc, excluding specified files and directories
echo "複製 '$folder_name' 到 package_acsbridge_K25_FT/ (排除 *.pyc, log內容, .開頭文件夾, __pycache__)"
rsync -av --exclude='*.pyc' --exclude='log/*' --exclude='.*/' --exclude='__pycache__/' "$source_path/" $folder_name

echo "完成! '$folder_name' 已複製成功 "
# Enter tsc directory and clean up Claude files



cd ~/package_acsbridge_K25_FT/$folder_name

# Remove claude.md if it exists
if [ -f "CLAUDE.md" ]; then
    echo "刪除 CLAUDE.md 文件..."
    rm -f CLAUDE.md
fi



# .pyc files and __pycache__ directories were already excluded during copying with rsync
echo "Skipping .pyc files and __pycache__ directories check (already excluded during copy)"

# 檢查是否有 .git* 檔案，並列印出檔案名稱
echo "Checking for .git* files..."
git_files=$(find . -type f -name ".git*")

if [[ -n "$git_files" ]]; then
    echo "Found .git* files:"
    echo "$git_files"
    find . -type f -name "*.git*" -delete
    echo "All .git* files have been deleted."
else
    echo "No .git* files found."
fi



# 檢查並清空 alembic/versions 目錄內容
if [[ -d "alembic/versions" ]]; then
    echo "Found alembic/versions directory, deleting contents..."
    rm -f alembic/versions/*
    echo "alembic/versions directory contents have been deleted."
else
    echo "No alembic/versions directory found."
fi
# 檢查 versions.txt 是否存在並設定 acsbridge_version
if [[ -f "version.txt" ]]; then
    acsbridge_version=$(cat version.txt)
    echo "Found versions.txt, acsbridge_version set to: $acsbridge_version"
else
    acsbridge_version=""
    echo "No versions.txt found, acsbridge_version set to empty"
fi


cd ~/package_acsbridge_K25_FT

# Configure settings before compression
configure_settings

# 生成時間戳記 (格式：YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

modified_acsbridge_version=${acsbridge_version//./_}
zip_filename="acsbridge_K25_${modified_acsbridge_version}_${timestamp}_${factory}_source_code.zip"

# 壓縮 tsc 目錄

# Rename folder to desired name for extraction
echo "Renaming folder for compression..."
mv "$folder_name" "acsbridge_K25"

echo "Compressing acsbridge_K25 directory into $zip_filename..."
zip -r "$zip_filename" "acsbridge_K25"

echo "Compression completed: $zip_filename"

# Ask user if they want to copy the compressed file
echo ""
echo "==============================================="
echo "File Copy Options"
echo "==============================================="
read -p "Do you want to copy the compressed file to another location? (y/N): " copy_choice

if [[ "$copy_choice" =~ ^[Yy]$ ]]; then
    echo ""
    echo "1: Copy to default path"
    echo "2: Copy to custom path"
    read -p "Select option (1-2): " path_choice
    
    if [[ "$path_choice" == "1" ]]; then
        # Default path
        target_dir="/mnt/c/Users/kelvi/OneDrive/14_CODE/${folder_name}_${factory}_source_code"
        echo "Using default path: $target_dir"
        
        # 檢查資料夾是否存在，如果不存在就建立
        if [ ! -d "$target_dir" ]; then
            echo "Target directory does not exist. Creating: $target_dir"
            mkdir -p "$target_dir"
        else
            echo "Target directory already exists: $target_dir"
        fi
        
        cp -r "$zip_filename" "$target_dir"
        echo "File copied to: $target_dir/$zip_filename"
        
    elif [[ "$path_choice" == "2" ]]; then
        # Custom path
        read -p "Enter custom path: " custom_path
        
        if [[ -n "$custom_path" ]]; then
            # Expand ~ to home directory if present
            custom_path="${custom_path/#\~/$HOME}"
            
            # 檢查路徑是否存在，如果不存在就建立
            if [ ! -d "$custom_path" ]; then
                echo "Custom directory does not exist. Creating: $custom_path"
                mkdir -p "$custom_path"
            else
                echo "Custom directory exists: $custom_path"
            fi
            
            cp -r "$zip_filename" "$custom_path"
            echo "File copied to: $custom_path/$zip_filename"
        else
            echo "No path entered. Skipping file copy."
        fi
    else
        echo "Invalid choice. Skipping file copy."
    fi
else
    echo "Skipping file copy."
fi

# Clean up
rm -rf "acsbridge_K25"
echo "Script completed successfully!"