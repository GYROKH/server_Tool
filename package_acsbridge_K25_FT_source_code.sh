#! /bin/bash



folder_name=acsbridge_K25_FT

# 讀取目前配置值的函數
read_config_value() {
    local config_file="$1"
    local config_name="$2"
    grep "self\.$config_name = [0-9]" "$config_file" | head -1 | sed 's/.*= *\([0-9]*\).*/\1/'
}

# 更新配置值的函數
update_config_value() {
    local config_file="$1"
    local config_name="$2"
    local new_value="$3"
    sed -i "s/\(self\.$config_name = \)[0-9]*\(  # .*\)/\1$new_value\2/" "$config_file"
}

# 讀取布林配置值的函數
read_boolean_config_value() {
    local config_file="$1"
    local config_name="$2"
    grep "self\.$config_name=" "$config_file" | head -1 | sed 's/.*=\([A-Za-z]*\).*/\1/' | tr -d ' '
}

# 更新布林配置值的函數  
update_boolean_config_value() {
    local config_file="$1"
    local config_name="$2"
    local new_value="$3"
    sed -i "s/\(self\.$config_name=\)[A-Za-z]*/\1$new_value/" "$config_file"
}

# 顯示配置選項並取得使用者選擇的函數
configure_settings() {
    local config_file="$HOME/server_Tool/$folder_name/config.py"
    
    echo "======================================================================="
    echo "                    ACSBridge 配置設定"  
    echo "======================================================================="
    
    # 讀取目前數值
    local current_test_type=$(read_config_value "$config_file" "test_type")
    local current_project_rack=$(read_config_value "$config_file" "project_rack")
    local current_ft_type=$(read_config_value "$config_file" "ft_type")
    local current_has_acsbridge_status=$(read_boolean_config_value "$config_file" "has_acsbridge_status")
    
    echo "📋 目前配置："
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│ 參數                    │ 目前值        │ 選項                      │"
    echo "├─────────────────────────────────────────────────────────────────────┤"
    echo "│ test_type               │      $current_test_type        │ 0:自己測, 1:Nick對測, 2:現場   │"
    echo "│ project_rack            │      $current_project_rack        │ 0:K15-6F/K25-7F, 1:K25-4F      │"
    echo "│                         │              │ 2:K8-6F, 3:K8-3F, 4:K7-14F │"
    echo "│ ft_type                 │      $current_ft_type        │ 0:FT, 1:SLT               │"
    echo "│ has_acsbridge_status    │   $current_has_acsbridge_status    │ True/False (ACSBridge 狀態)  │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # 詢問使用者是否要修改設定
    echo "❓ 您是否要修改配置設定？"
    echo -n "   請輸入您的選擇 (y/N): "
    read -e modify_choice
    if [[ ! "$modify_choice" =~ ^[Yy]$ ]]; then
        echo "保持目前配置。"
        # 仍需要根據目前配置設定工廠
        final_project_rack=$current_project_rack
    else
    
    # 配置 test_type
    echo ""
    echo "🔧 === 測試類型配置 ==="
    echo "   0: 自己測 (Self Testing)"
    echo "   1: Nick對測 (Nick Testing)" 
    echo "   2: 現場 (On-Site)"
    echo "   目前值: $current_test_type"
    echo ""
    echo -n "   請輸入新的 test_type (0-2) 或按 Enter 保持目前值: "
    read -e new_test_type
    if [[ -n "$new_test_type" && "$new_test_type" =~ ^[0-2]$ ]]; then
        update_config_value "$config_file" "test_type" "$new_test_type"
        echo "   ✅ 成功更新 test_type 為 $new_test_type"
    fi
    
    # 配置 project_rack
    echo ""
    echo "🏭 === 專案機架配置 ==="
    echo "   0: K15-6F(K25-7F) - ASE 工廠組合"
    echo "   1: K25-4F - ASE K25 四樓"
    echo "   2: K8-6F - ASE K8 六樓"
    echo "   3: K8-3F - ASE K8 三樓"
    echo "   4: K7-14F - ASE K7 十四樓"
    echo "   目前值: $current_project_rack"
    echo ""
    echo -n "   請輸入新的 project_rack (0-4) 或按 Enter 保持目前值: "
    read -e new_project_rack
    if [[ -n "$new_project_rack" && "$new_project_rack" =~ ^[0-4]$ ]]; then
        update_config_value "$config_file" "project_rack" "$new_project_rack"
        echo "   ✅ 成功更新 project_rack 為 $new_project_rack"
    fi
    
    # 配置 ft_type
    echo ""
    echo "🔬 === FT 類型配置 ==="
    echo "   0: FT (Final Test)"
    echo "   1: SLT (System Level Test)"
    echo "   目前值: $current_ft_type"
    echo ""
    echo -n "   請輸入新的 ft_type (0-1) 或按 Enter 保持目前值: "
    read -e new_ft_type
    if [[ -n "$new_ft_type" && "$new_ft_type" =~ ^[0-1]$ ]]; then
        update_config_value "$config_file" "ft_type" "$new_ft_type"
        echo "   ✅ 成功更新 ft_type 為 $new_ft_type"
    fi
    
    # 配置 has_acsbridge_status
    echo ""
    echo "⚡ === ACSBridge 狀態配置 ==="
    echo "   問題：acsbridge_Status 服務是否已安裝並運行？"
    echo "   說明：此設定決定系統是否應使用 ACSBridge Status API"
    echo "   目前值: $current_has_acsbridge_status"
    echo ""
    echo -n "   請輸入 Y 表示 True，N 表示 False，或按 Enter 保持目前值: "
    read -e acsbridge_choice
    if [[ -n "$acsbridge_choice" ]]; then
        if [[ "$acsbridge_choice" =~ ^[Yy]$ ]]; then
            update_boolean_config_value "$config_file" "has_acsbridge_status" "True"
            echo "   ✅ 成功更新 has_acsbridge_status 為 True"
        elif [[ "$acsbridge_choice" =~ ^[Nn]$ ]]; then
            update_boolean_config_value "$config_file" "has_acsbridge_status" "False"
            echo "   ✅ 成功更新 has_acsbridge_status 為 False"
        else
            echo "   ⚠️  輸入無效。保持目前值。"
        fi
    fi
    
        echo ""
        echo "🎉 配置更新成功完成！"
        
        # 更新後讀取最終配置
        final_project_rack=$(read_config_value "$config_file" "project_rack")
    fi
    
    # 顯示最終配置
    local final_test_type=$(read_config_value "$config_file" "test_type")
    local final_ft_type=$(read_config_value "$config_file" "ft_type")
    local final_has_acsbridge_status=$(read_boolean_config_value "$config_file" "has_acsbridge_status")
    
    echo ""
    echo "📊 最終配置摘要："
    echo "┌─────────────────────────────────────────────────────────────────────┐"
    echo "│ 參數                    │ 最終值        │ 說明                      │"
    echo "├─────────────────────────────────────────────────────────────────────┤"
    echo "│ test_type               │      $final_test_type        │ 測試環境類型                  │"
    echo "│ project_rack            │      $final_project_rack        │ 工廠/機架位置                 │"
    echo "│ ft_type                 │      $final_ft_type        │ 測試類型 (FT/SLT)            │"
    echo "│ has_acsbridge_status    │   $final_has_acsbridge_status    │ ACSBridge 狀態服務           │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    
    # 根據 project_rack 選擇設定工廠
    case $final_project_rack in
        0)
            echo ""
            echo "🏭 === project_rack 0 的工廠選擇 ==="
            echo "   0: K15-6F"
            echo "   1: K25-7F"
            echo -n "   請選擇工廠 (0 代表 K15-6F，1 代表 K25-7F): "
            read -e factory_choice
            if [[ "$factory_choice" == "0" ]]; then
                factory="K15-6F"
            elif [[ "$factory_choice" == "1" ]]; then
                factory="K25-7F"
            else
                echo "   ⚠️  選擇無效，預設使用 K25-7F"
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
            factory="Unknow"
            ;;
    esac
    
    echo "│ factory                 │   $factory   │ 選定的工廠位置              │"
    echo "└─────────────────────────────────────────────────────────────────────┘"
    echo "======================================================================="
}



# 檢查來源資料夾是否存在
source_path="/home/mcsadmin/$folder_name"
if [ ! -d "$source_path" ]; then
    echo "錯誤: 文件夾 '$source_path' 不存在"
    exit 1
fi

# 導航到 package_acsbridge 目錄
cd ~/server_Tool

# 刪除除了 .sh 文件以外的所有文件


rm -rf $folder_name
rm -rf *.zip




# 複製來源資料夾並重新命名，排除指定的文件和目錄
echo "複製 '$folder_name' 到 server_Tool/ (排除 *.pyc, log內容, .開頭文件夾, __pycache__)"
rsync -av --exclude='*.pyc' --exclude='log/*' --exclude='.*/' --exclude='__pycache__/' "$source_path/" $folder_name

echo "完成! '$folder_name' 已複製成功 "
# 進入目錄並清理 Claude 文件



cd ~/server_Tool/$folder_name

# 如果存在 claude.md 則移除
if [ -f "CLAUDE.md" ]; then
    echo "刪除 CLAUDE.md 文件..."
    rm -f CLAUDE.md
fi











# 檢查並清空 alembic/versions 目錄內容
if [[ -d "alembic/versions" ]]; then
    echo "找到 alembic/versions 目錄，刪除內容..."
    rm -f alembic/versions/*
    echo "alembic/versions 目錄內容已刪除。"
else
    echo "未找到 alembic/versions 目錄。"
fi
# 檢查 versions.txt 是否存在並設定 acsbridge_version
if [[ -f "version.txt" ]]; then
    acsbridge_version=$(cat version.txt)
    echo "找到 versions.txt，acsbridge_version 設定為：$acsbridge_version"
else
    acsbridge_version=""
    echo "未找到 versions.txt，acsbridge_version 設定為空"
fi


cd ~/server_Tool

# 詢問使用者輸入工廠名稱
echo ""
echo "========================================"
echo "工廠名稱輸入"
echo "========================================"
echo "請輸入 factory 名稱 (如 K25-7F, K8-6F, K15-6F):"
read -e factory_name

# 檢查工廠輸入是否為空
if [ -z "$factory_name" ]; then
    echo "錯誤: 未輸入 factory 名稱"
    exit 1
fi

echo "已設定 factory: $factory_name"
echo ""

# 在壓縮前配置設定
configure_settings

# 生成時間戳記 (格式：YYYYMMDD_HHMMSS)
timestamp=$(date +"%Y%m%d_%H%M%S")

modified_acsbridge_version=${acsbridge_version//./_}
zip_filename="acsbridge_K25_${modified_acsbridge_version}_${timestamp}_${factory_name}_source_code.zip"

# 壓縮目錄

# 重新命名資料夾以便壓縮
echo "重新命名資料夾以進行壓縮..."
mv "$folder_name" "acsbridge_K25"

echo "正在將 acsbridge_K25 目錄壓縮為 $zip_filename..."
zip -r "$zip_filename" "acsbridge_K25"

echo "壓縮完成：$zip_filename"

# 詢問使用者是否要複製壓縮檔案
echo ""
echo "==============================================="
echo "檔案複製選項"
echo "==============================================="
echo -n "您是否要將壓縮檔案複製到其他位置？(y/N): "
read -e copy_choice

if [[ "$copy_choice" =~ ^[Yy]$ ]]; then
    echo ""
    echo "1: 複製到預設路徑"
    echo "2: 複製到自訂路徑"
    echo -n "選擇選項 (1-2): "
    read -e path_choice
    
    if [[ "$path_choice" == "1" ]]; then
        # 預設路徑
        target_dir="/mnt/c/Users/kelvi/OneDrive/14_CODE/${folder_name}_${factory_name}_source_code"
        echo "使用預設路徑：$target_dir"
        
        # 檢查資料夾是否存在，如果不存在就建立
        if [ ! -d "$target_dir" ]; then
            echo "目標目錄不存在。建立中：$target_dir"
            mkdir -p "$target_dir"
        else
            echo "目標目錄已存在：$target_dir"
        fi
        
        cp -r "$zip_filename" "$target_dir"
        echo "檔案已複製到：$target_dir/$zip_filename"
        
    elif [[ "$path_choice" == "2" ]]; then
        # 自訂路徑
        echo "請輸入自訂路徑："
        read -e custom_path
        
        if [[ -n "$custom_path" ]]; then
            # 將 ~ 擴展為家目錄
            custom_path="${custom_path/#\~/$HOME}"
            
            # 檢查路徑是否存在，如果不存在就建立
            if [ ! -d "$custom_path" ]; then
                echo "自訂目錄不存在。建立中：$custom_path"
                mkdir -p "$custom_path"
            else
                echo "自訂目錄存在：$custom_path"
            fi
            
            cp -r "$zip_filename" "$custom_path"
            echo "檔案已複製到：$custom_path/$zip_filename"
        else
            echo "未輸入路徑。略過檔案複製。"
        fi
    else
        echo "選擇無效。略過檔案複製。"
    fi
else
    echo "略過檔案複製。"
fi

# 清理
rm -rf "acsbridge_K25"
echo "腳本執行成功完成！"