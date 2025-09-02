#! /bin/bash

# Function to display start.sh command selection menu
select_start_command() {
    echo ""
    echo "========================================"
    echo "start.sh 執行指令選擇"
    echo "========================================"
    echo "請選擇要在 start.sh 中使用的執行指令："
    echo "1. FT 模式 (僅 Final Test)"
    echo "   指令: /usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25"
    echo ""
    echo "2. FT + CP 模式 (Final Test + CP 整合)"
    echo "   指令: /usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25 -e88_eq mirle -erack KHCP"
    echo ""
    echo "3. 保持原有設定 (不修改)"
    echo "========================================"
}

# Function to update start.sh based on user selection
update_start_script() {
    local choice="$1"
    local start_file="$HOME/server_Tool/tsc/start.sh"
    
    if [[ ! -f "$start_file" ]]; then
        echo "警告: start.sh 檔案不存在，略過修改"
        return 1
    fi
    
    case $choice in
        1) # FT 模式
            echo "設定 start.sh 為 FT 模式..."
            # Create new start.sh with FT mode
            cat > "$start_file" << 'EOF'
#!/usr/bin/env sh

#FT
/usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25


# FT + CP
#/usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25 -e88_eq mirle -erack KHCP
EOF
            echo "✅ start.sh 已設定為 FT 模式"
            ;;
        2) # FT + CP 模式  
            echo "設定 start.sh 為 FT + CP 模式..."
            # Create new start.sh with FT + CP mode
            cat > "$start_file" << 'EOF'
#!/usr/bin/env sh

#FT
#/usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25


# FT + CP
/usr/bin/python2 ./controller.py -url 127.0.0.1 -api v3_K25 -e88_eq mirle -erack KHCP
EOF
            echo "✅ start.sh 已設定為 FT + CP 模式"
            ;;
        3) # 保持原設定
            echo "✅ 保持 start.sh 原有設定"
            return 0
            ;;
        *)
            echo "錯誤: 無效的選項"
            return 1
            ;;
    esac
    
    # Make sure start.sh is executable
    chmod +x "$start_file"
    echo "已確保 start.sh 具有執行權限"
}

# Scan for tsc directories only in /home/mcsadmin/
echo "掃描 /home/mcsadmin/ 目錄中以 'tsc' 開頭的資料夾..."
tsc_folders=($(find /home/mcsadmin -maxdepth 1 -type d -name "tsc*" 2>/dev/null | xargs -I {} basename {}))

# Check if any tsc folders found
if [ ${#tsc_folders[@]} -eq 0 ]; then
    echo "錯誤: 在 /home/mcsadmin/ 目錄下未找到以 'tsc' 開頭的資料夾"
    exit 1
fi

# Display folder selection menu
echo ""
echo "請選擇要複製的 TSC 資料夾:"
echo "========================================"
for i in "${!tsc_folders[@]}"; do
    echo "$((i+1)). ${tsc_folders[$i]}"
done
echo "========================================"

# Get user selection
while true; do
    echo -n "請輸入選項編號 (1-${#tsc_folders[@]}): "
    read -e selection
    
    # Check if input is a number
    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#tsc_folders[@]} ]; then
        folder_name="${tsc_folders[$((selection-1))]}"
        echo "已選擇: $folder_name"
        break
    else
        echo "錯誤: 請輸入有效的選項編號 (1-${#tsc_folders[@]})"
    fi
done

# Prompt for factory name input
echo "請輸入 factory 名稱:"
read -e factory_name

# Check if factory input is empty
if [ -z "$factory_name" ]; then
    echo "錯誤: 未輸入 factory 名稱"
    exit 1
fi

# Check if source folder exists
source_path="/home/mcsadmin/$folder_name"
if [ ! -d "$source_path" ]; then
    echo "錯誤: 文件夾 '$source_path' 不存在"
    exit 1
fi

# Navigate to server_Tool directory
cd ~/server_Tool

# Delete all files except .sh files


# Remove existing tsc folder if it exists
if [ -d "tsc" ]; then
    echo "刪除現有的 tsc 文件夾..."
    rm -rf tsc
fi





# Copy the source folder and rename to tsc
echo "複製 '$folder_name' 到 server_Tool/tsc..."
cp -r "$source_path" ./tsc

echo "完成! '$folder_name' 已複製並重命名為 'tsc'"
# Enter tsc directory and clean up Claude files


cd ~/server_Tool/tsc/log
rm -rf *.log
rm -rf *.log.*

cd ~/server_Tool/tsc

# Remove claude.md if it exists
if [ -f "claude.md" ]; then
    echo "刪除 claude.md 文件..."
    rm -f claude.md
fi

# Remove all hidden directories (starting with .)
for dir in .*; do
    if [ -d "$dir" ] && [ "$dir" != "." ] && [ "$dir" != ".." ]; then
        echo "刪除隱藏目錄 $dir..."
        rm -rf "$dir"
    fi
done

# 檢查是否有 .pyc 檔案，並列印出檔案名稱
echo "Checking for .pyc files..."
pyc_files=$(find . -type f -name "*.pyc")

if [[ -n "$pyc_files" ]]; then
    echo "Found .pyc files:"
    echo "$pyc_files"
    find . -type f -name "*.pyc" -delete
    echo "All .pyc files have been deleted."
else
    echo "No .pyc files found."
fi

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

# Ask user to select start.sh command configuration
select_start_command
while true; do
    echo -n "請選擇選項 (1-3): "
    read -e start_choice
    
    if [[ "$start_choice" =~ ^[1-3]$ ]]; then
        update_start_script "$start_choice"
        break
    else
        echo "錯誤: 請輸入有效的選項編號 (1-3)"
    fi
done

echo ""

tsc_version=$(cat version.txt)

cd ~/server_Tool

# 生成時間戳記 (格式：YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

modified_tsc_version=${tsc_version//./_}
zip_filename="tsc_${modified_tsc_version}_${timestamp}_${factory_name}_source_code.zip"

# 壓縮 tsc 目錄

echo "Compressing tsc directory into $zip_filename..."
zip -r "$zip_filename" tsc

echo "Compression completed: $zip_filename"
echo ""

# Ask user for copy destination
echo "========================================"
echo "檔案複製選項"
echo "========================================"
default_target="/mnt/c/Users/kelvi/OneDrive/14_CODE/tsc_${factory_name}_source_code"
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
            
            cp "$zip_filename" "$target_dir"
            echo "檔案已複製到: $target_dir/$zip_filename"
            break
            ;;
        2)
            target_dir="$home_target"
            echo "已選擇: Home 目錄"
            cp "$zip_filename" "$target_dir"
            echo "檔案已複製到: $target_dir/$zip_filename"
            break
            ;;
        3)
            echo "已選擇: 不複製，檔案保留在當前目錄"
            echo "檔案位置: $(pwd)/$zip_filename"
            break
            ;;
        *)
            echo "錯誤: 請輸入有效的選項編號 (1-3)"
            ;;
    esac
done