#!/bin/bash

CONFIG_PATH="/home/mcsadmin/UI_Mgmt"

# Global variable to store selected Python version
SELECTED_PYTHON=""

# Global arrays to store Python version information
declare -a python_paths=()
declare -a python_versions=()  
declare -a python_info=()

# Function to detect available Python3 versions
detect_python_versions() {
    # Clear global arrays
    python_paths=()
    python_versions=()
    python_info=()
    
    # Common Python3 executables to check
    local candidates=("python3" "python3.8" "python3.9" "python3.10" "python3.11" "python3.12" "python3.7")
    
    echo "Scanning for available Python3 versions..."
    
    for py_cmd in "${candidates[@]}"; do
        # Check if command exists and is executable
        if command -v "$py_cmd" >/dev/null 2>&1; then
            # Get full path and version info
            local py_path=$(which "$py_cmd")
            local version_info=$($py_cmd --version 2>&1)
            
            # Check if it's actually Python 3.x
            if [[ $version_info =~ Python\ 3\.[0-9]+\.[0-9]+ ]]; then
                python_paths+=("$py_path")
                python_versions+=("$py_cmd")
                python_info+=("$version_info")
            fi
        fi
    done
    
    # Remove duplicates based on actual path
    local unique_paths=()
    local unique_versions=()
    local unique_info=()
    
    for i in "${!python_paths[@]}"; do
        local is_duplicate=false
        for j in "${!unique_paths[@]}"; do
            if [[ "${python_paths[$i]}" == "${unique_paths[$j]}" ]]; then
                is_duplicate=true
                break
            fi
        done
        
        if [[ "$is_duplicate" == false ]]; then
            unique_paths+=("${python_paths[$i]}")
            unique_versions+=("${python_versions[$i]}")
            unique_info+=("${python_info[$i]}")
        fi
    done
    
    # Update global arrays with unique values
    python_paths=("${unique_paths[@]}")
    python_versions=("${unique_versions[@]}")
    python_info=("${unique_info[@]}")
    
    echo "Found ${#python_paths[@]} Python3 installation(s)"
    return ${#python_paths[@]}
}

# Function to let user select Python version
select_python_version() {
    detect_python_versions
    local count=$?
    
    if [[ $count -eq 0 ]]; then
        echo "Error: No Python3 installations found on this system"
        echo "Please install Python 3.x before running this script"
        exit 1
    elif [[ $count -eq 1 ]]; then
        SELECTED_PYTHON="${python_paths[0]}"
        echo "Only one Python3 version found: ${python_info[0]}"
        echo "Using: $SELECTED_PYTHON"
        return 0
    fi
    
    # Multiple versions found, let user choose
    echo ""
    echo "========================================"
    echo "Python 版本偵測與選擇"
    echo "========================================"
    echo "偵測到以下 Python 版本："
    
    for i in "${!python_paths[@]}"; do
        echo "$((i+1)). ${python_paths[$i]} (${python_info[$i]})"
    done
    echo "========================================"
    
    while true; do
        echo -n "請選擇要使用的 Python 版本 (1-$count): "
        read -e selection
        
        # Check if input is a number
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le $count ]; then
            local index=$((selection-1))
            SELECTED_PYTHON="${python_paths[$index]}"
            echo "已選擇: ${python_info[$index]}"
            echo "Python 路徑: $SELECTED_PYTHON"
            break
        else
            echo "錯誤: 請輸入有效的選項編號 (1-$count)"
        fi
    done
    echo ""
}
# 生成時間戳記 (格式：YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

# Select Python version before proceeding
select_python_version

echo "請輸入 acsbridge 資料夾名稱 如 acsbridge_K11:"
read -e acsbridge_path_name
echo "請輸入 acsbridge 服務名稱 如 acsbridgeK11:"
read -e acsbridge_service_name
echo "請輸入 factory 名稱 (如 K25-7F, K8-6F):"
read -e factory_name

# Check if factory input is empty
if [ -z "$factory_name" ]; then
    echo "錯誤: 未輸入 factory 名稱"
    exit 1
fi

get_python_config_value() {
    local var_name="$1"
    "$SELECTED_PYTHON" -c "import sys; sys.path.insert(0, '$CONFIG_PATH'); from config import Config; print(getattr(Config, '$var_name', ''))"
}

version_prefix=$(get_python_config_value "VERSION_PREFIX")
version=$(get_python_config_value "VERSION")

# 將小數點變成底線
version_prefix_safe="${version_prefix//./_}"

echo "原始版本前綴：$version_prefix"
echo "轉換後版本前綴：$version_prefix_safe"
echo "完整版本":"${version_prefix_safe}_${version}"

# acsbridge_path_name="acsbridge_K11"



cd /home/mcsadmin/server_Tool
full_version="UI_Mgmt_${version_prefix_safe}_${version}_${timestamp}_${factory_name}"

echo "需要建立的文件夾:${full_version}"

rm -rf UI_Mgmt

cp -R /home/mcsadmin/UI_Mgmt "/home/mcsadmin/server_Tool/${full_version}"


config_file="/home/mcsadmin/server_Tool/${full_version}/config.py"
new_log_dirs="../UI_Mgmt/log,../tsc/log,../tsc/param,../${acsbridge_path_name}/log"
# acsbridge_service_name="acsbridgeK11"

echo "正在更新 ACSBRIDGE_SYSTEM_NAME 為：$acsbridge_service_name"
echo "前版本：$(grep 'ACSBRIDGE_SYSTEM_NAME' $config_file)"
sed -i "s/^[[:space:]]*ACSBRIDGE_SYSTEM_NAME *= *'.*'/    ACSBRIDGE_SYSTEM_NAME = '${acsbridge_service_name}'/" "$config_file"
echo "後版本：$(grep 'ACSBRIDGE_SYSTEM_NAME' $config_file)"


echo "正在更新 log_dirs 為：$new_log_dirs"
echo "前版本：$(grep 'LOG_DIRS' $config_file)"
sed -i "s|^[[:space:]]*LOG_DIRS *= *'.*'|    LOG_DIRS = '${new_log_dirs}'|" "$config_file"
echo "後版本：$(grep 'LOG_DIRS' $config_file)"

echo "config.py 已更新完成。"

#3 刪除log
cd "/home/mcsadmin/server_Tool/${full_version}"/log
rm -rf *.log
rm -rf *.log.*

cd "/home/mcsadmin/server_Tool/${full_version}"
# 編譯所有 .py 檔案成 .pyc，排除 RoutineDumpDatabase.py 和 config.py
echo "Using Python version for compilation: $SELECTED_PYTHON"
find . -type f -name "*.py" \
  ! -name "RoutineDumpDatabase.py" \
  ! -name "FirstTimeDumpDB.py" \
  ! -name "gunicorn.conf.py" \
  ! -name "gunicorn.conf.stats.py" \
  ! -name "config.py" \
  ! -name "get-pip.py" \
  ! -name "agv.py" \
  ! -path "./migrations/versions/*" \
  ! -path "./Resources/colorlog/*" \
  ! -path "./Resources/cronJobs/*" \
  -exec "$SELECTED_PYTHON" -c "import sys, py_compile; py_compile.compile(sys.argv[1], cfile=sys.argv[1] + 'c', doraise=True)" {} \;

# 2. 刪除編譯過後的 .py 檔案（保留以上排除的檔案）
find . -type f -name "*.py" \
  ! -name "RoutineDumpDatabase.py" \
  ! -name "FirstTimeDumpDB.py" \
  ! -name "gunicorn.conf.py" \
  ! -name "gunicorn.conf.stats.py" \
  ! -name "config.py" \
  ! -name "get-pip.py" \
  ! -name "agv.py" \
  ! -path "./Resources/colorlog/*" \
  ! -path "./Resources/cronJobs/*" \
  -delete



# 4. 使用 tar 將 full_version 資料夾打包，
#    並透過 --transform 將解壓後的根目錄名稱改成 UI_Mgmt
cd "/home/mcsadmin/server_Tool/"

# Get Python version for filename (extract version number like 3.8, 3.9, etc.)
python_version_number=$($SELECTED_PYTHON --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
python_version_safe="${python_version_number//./}"

tar_filename="${full_version}_compile_code_by_py${python_version_safe}.tar.gz"
tar -czvf "$tar_filename" --transform="s/^${full_version}/UI_Mgmt/" "${full_version}"

echo "打包完成，檔案：$tar_filename"
echo ""

# Ask user for copy destination
echo "========================================"
echo "檔案複製選項"
echo "========================================"
default_target="/mnt/c/Users/kelvi/OneDrive/14_CODE/UI_Mgmt_compile_code"
home_target="$HOME"

echo "請選擇要將壓縮檔複製到哪裡："
echo "1. OneDrive 目錄 (預設)"
echo "   路徑: $default_target"
echo "2. Home 目錄"
echo "   路徑: $home_target"
echo "3. 不複製，保留在當前目錄"

while true; do
    echo -n "請輸入選項編號 (1-3): "
    read -e copy_choice
    
    case $copy_choice in
        1)
            target_dir="$default_target"
            echo "已選擇: OneDrive 目錄"
            
            # 檢查資料夾是否存在，如果不存在就建立
            if [ ! -d "$target_dir" ]; then
                echo "Target directory does not exist. Creating: $target_dir"
                mkdir -p "$target_dir"
            else
                echo "Target directory already exists: $target_dir"
            fi
            
            cp "$tar_filename" "$target_dir"
            echo "檔案已複製到: $target_dir/$tar_filename"
            break
            ;;
        2)
            target_dir="$home_target"
            echo "已選擇: Home 目錄"
            cp "$tar_filename" "$target_dir"
            echo "檔案已複製到: $target_dir/$tar_filename"
            break
            ;;
        3)
            echo "已選擇: 不複製，檔案保留在當前目錄"
            echo "檔案位置: $(pwd)/$tar_filename"
            break
            ;;
        *)
            echo "錯誤: 請輸入有效的選項編號 (1-3)"
            ;;
    esac
done

# Clean up only if file was copied
if [ "$copy_choice" != "3" ]; then
    rm -rf "$tar_filename"
fi

rm -rf "${full_version}"
# rm -rf "*.tar.gz"