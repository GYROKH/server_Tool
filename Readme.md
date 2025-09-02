


## 打包腳本總覽

| 腳本名稱 | 功能 | 輸出格式 | 主要用途 |
|---------|------|----------|----------|
| package_acsbridge_K25_FT_source_code.sh | ACSBridge 源碼打包 | .zip | 源碼部署和版本控制 |
| package_tsc_source_code.sh | TSC 源碼打包 | .zip | 源碼部署和版本控制 |
| package_UI_Mgmt_compile_code.sh | UI管理系統編譯打包 | .tar.gz | 編譯後的生產環境部署 |

---

## 1. ACSBridge K25 FT 源碼打包腳本

### 檔案：package_acsbridge_K25_FT_source_code.sh

### 主要功能
- 複製並清理 ACSBridge K25 FT 系統源碼
- 提供互動式配置管理界面
- 自動生成帶時間戳和工廠標識的壓縮檔案
- 支援多工廠環境配置

### 配置參數

| 參數名稱 | 選項 | 說明 |
|---------|------|------|
| test_type | 0: 自己測<br>1: Nick對測<br>2: 現場 | 測試環境類型 |
| project_rack | 0: K15-6F/K25-7F<br>1: K25-4F<br>2: K8-6F<br>3: K8-3F<br>4: K7-14F | 專案機架位置 |
| ft_type | 0: FT (Final Test)<br>1: SLT (System Level Test) | 測試類型 |
| has_acsbridge_status | True/False | ACSBridge 狀態服務是否可用 |

### 使用方式

1. **執行腳本**
```bash
cd ~/server_Tool
chmod +x package_acsbridge_K25_FT_source_code.sh
./package_acsbridge_K25_FT_source_code.sh
```

2. **配置設定**
- 腳本會顯示目前配置值
- 選擇是否修改配置 (y/N)
- 逐步設定各項參數

3. **輸入工廠名稱**
```bash
請輸入 factory 名稱 (如 K25-7F, K8-6F, K15-6F): K25-7F
```

4. **選擇檔案複製位置**
- 選項 1: 複製到預設路徑
- 選項 2: 複製到自訂路徑
- 或保留在當前目錄

### 輸出檔案格式
```
acsbridge_K25_{version}_{timestamp}_{factory_name}_source_code.zip
```
範例：acsbridge_K25_1_2_3_20250102_143022_K25-7F_source_code.zip

### 清理項目
- *.pyc 檔案
- log 目錄內容  
- 隱藏目錄 (.開頭)
- __pycache__ 目錄
- alembic/versions 內容
- CLAUDE.md 檔案

---

## 2. TSC 源碼打包腳本

### 檔案：package_tsc_source_code.sh

### 主要功能
- 自動掃描並列出所有 TSC 資料夾
- 提供選擇界面讓使用者選擇要打包的 TSC 版本
- 清理和優化源碼結構
- 生成標準化的壓縮檔案

### 使用方式

1. **執行腳本**
```bash
cd ~/server_Tool
chmod +x package_tsc_source_code.sh
./package_tsc_source_code.sh
```

2. **選擇 TSC 資料夾**
```bash
請選擇要複製的 TSC 資料夾:
========================================
1. tsc_8.31.12_FT
2. tsc_8.30.5_FT
3. tsc_9.1.0_FT
========================================
請輸入選項編號 (1-3): 1
```

3. **輸入工廠名稱**
```bash
請輸入 factory 名稱: K25-7F
```

4. **選擇複製目的地**
- 選項 1: OneDrive 目錄 (預設)
- 選項 2: Home 目錄  
- 選項 3: 保留在當前目錄

### 輸出檔案格式
```
tsc_{version}_{timestamp}_{factory_name}_source_code.zip
```
範例：tsc_8_31_12_20250102_143022_K25-7F_source_code.zip

### 清理項目
- *.log 和 *.log.* 檔案
- *.pyc 檔案
- .git* 檔案
- 隱藏目錄
- claude.md 檔案

---

## 3. UI 管理系統編譯打包腳本

### 檔案：package_UI_Mgmt_compile_code.sh

### 主要功能
- 複製 UI_Mgmt 系統源碼
- 自動讀取版本資訊
- 更新配置檔案中的 ACSBridge 服務設定
- 編譯 Python 檔案為 .pyc 格式
- 生成生產環境用的壓縮檔案

### 使用方式

1. **執行腳本**
```bash
cd ~/server_Tool
chmod +x package_UI_Mgmt_compile_code.sh
./package_UI_Mgmt_compile_code.sh
```

2. **輸入 ACSBridge 相關資訊**
```bash
請輸入 acsbridge 資料夾名稱 如 acsbridge_K11: acsbridge_K25
請輸入 acsbridge 服務名稱 如 acsbridgeK11: acsbridgeK25
請輸入 factory 名稱 (如 K25-7F, K8-6F): K25-7F
```

3. **自動配置更新**
腳本會自動更新 config.py 中的：
- ACSBRIDGE_SYSTEM_NAME = 設定的服務名稱
- LOG_DIRS = 相關的 log 目錄路徑

4. **Python 編譯**
自動編譯 .py 檔案為 .pyc，排除以下檔案：
- RoutineDumpDatabase.py
- FirstTimeDumpDB.py
- gunicorn.conf.py
- gunicorn.conf.stats.py
- config.py
- get-pip.py
- agv.py
- migrations/versions/*
- Resources/colorlog/*
- Resources/cronJobs/*

### 輸出檔案格式
```
UI_Mgmt_{version_prefix}_{version}_{timestamp}_{factory_name}_compile_code_by_py38.tar.gz
```
範例：UI_Mgmt_1_0_0_1_20250102_143022_K25-7F_compile_code_by_py38.tar.gz

### 處理流程
1. 複製 UI_Mgmt 原始碼
2. 更新配置檔案
3. 清理 log 檔案
4. 編譯 Python 檔案
5. 刪除原始 .py 檔案 (保留排除清單)
6. 打包為 tar.gz 格式

---

## 通用設定和注意事項

### 預設路徑設定
- **來源目錄**: /home/mcsadmin/{對應系統名稱}
- **工作目錄**: /home/mcsadmin/server_Tool/
- **預設複製目標**: /mnt/c/Users/kelvi/OneDrive/14_CODE/

### 時間戳格式
所有腳本使用統一的時間戳格式：YYYYMMDD_HHMMSS

### 權限要求
確保腳本具有執行權限：
```bash
chmod +x *.sh
```

### 重要提醒

1. **執行前備份**：建議在執行腳本前備份重要資料
2. **磁碟空間**：確保有足夠的磁碟空間存放壓縮檔案
3. **路徑檢查**：腳本會自動檢查來源路徑是否存在
4. **版本控制**：壓縮檔案名稱包含版本和時間戳，避免覆蓋
5. **清理政策**：腳本會自動清理編譯後的暫存目錄

### 故障排除

**常見問題解決方案：**

- **來源資料夾不存在**：檢查 /home/mcsadmin/ 下是否有對應的系統資料夾
- **權限不足**：使用 chmod +x 給予腳本執行權限
- **磁碟空間不足**：清理不必要的檔案或更改輸出目錄
- **Python 編譯失敗**：確保 Python 3.8 已正確安裝

---

## 技術支援

如遇到問題，請檢查：
1. 系統環境和依賴是否正確安裝
2. 檔案路徑和權限設定
3. 磁碟空間是否充足
4. 網路連接狀態（如需複製到遠端位置）

**建議在生產環境使用前，先在測試環境驗證所有腳本功能。**