@echo off
setlocal enabledelayedexpansion
:: 获取脚本所在目录路径
for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"

cd %SCRIPT_DIR%
:: 设置要拉取的文件夹名称
set FOLDER_1=mp_package_hg2259
set FOLDER_2=hg2259

:: 检查并删除上一个版本的文件夹
if exist "%SCRIPT_DIR%\%FOLDER_1%" (
	echo ************************************************************************
    echo Folder MPTool exists and is being deleted......
    rd /s /q "%SCRIPT_DIR%\%FOLDER_1%"
)

if exist "%SCRIPT_DIR%\%FOLDER_2%" (
	echo Folder hg2259 exists and is being deleted......
	echo ************************************************************************
    rd /s /q "%SCRIPT_DIR%\%FOLDER_2%"
)
echo.

:: 设置 Git 配置文件路径
set PATH_CONFIG=%SCRIPT_DIR%\config.txt

:: 配置编译路径,Git路径和账号密码
if not exist "%PATH_CONFIG%" (
	echo +--------------------------------------------------------------------------------------------------------+
	echo.
	echo Config.txt file does not exist,We can't find the Software path.  
	echo.
	echo Now let's configure so that you can clone the repository and compile the code.
	echo.
	echo We give an example so that you can refer.You can look up the path on your computer's.
	echo.
	echo It's usually the disk drive that makes the difference.
	echo.
	echo Example
	echo 	1. Reference Git_cmd_path:    C:\Program Files\Git\cmd
	echo  	2. Reference AndeSightPath_1: C:\Andestech\AndeSight_STD_v521\cygwin\bin
	echo  	3. Reference AndeSightPath_2: C:\Andestech\AndeSight_STD_v521\toolchains\nds32le-elf-mculib-v5\bin
	echo.
	echo You only need to configure it once to save it automatically.
	echo.
	:: 提示用户手动输入账号和密码
	set /p  GitPath="Git_cmd_path: "
    set /p  GitUsername="Git_Username: "
    set /p  GitPassword="Git_Password: "	
    set /p  AndeSightPath1="AndeSightPath__1: " 
    set /p  AndeSightPath2="AndeSightPath__2: "
	echo.
    echo We have finished the configuration.
	echo if there are subsequent changes to be made, directly use config.txt to modify.
	echo +--------------------------------------------------------------------------------------------------------+
	pause
    :: 将信息写入配置文件
    >"%PATH_CONFIG%" (
		echo Git_Path=!GitPath!
        echo Git_Username=!GitUsername!
        echo Git_Password=!GitPassword!	
        echo AndeSightPath1=!AndeSightPath1!
        echo AndeSightPath2=!AndeSightPath2!
    )
) else (
    :: 从配置文件中读取信息
    for /f "usebackq tokens=1,* delims== " %%a in ("%PATH_CONFIG%") do (
	    if /i "%%a"=="GitPath" set "GitPath=%%b"		
        if /i "%%a"=="GitUsername" set "GitUsername=%%b"
        if /i "%%a"=="GitPassword" set "GitPassword=%%b"	
        if /i "%%a"=="AndeSightPath1" set "AndeSightPath1=%%b"
        if /i "%%a"=="AndeSightPath2" set "AndeSightPath2=%%b"
    )
)

set path=%path%;%GitPath%;
echo ************************************************************************
:: 拉取最新的MPTool和hg2259code
git clone http://%GitUsername%%Git_Password%@192.168.18.188:7990/scm/hg2259/mp_package_hg2259.git "%SCRIPT_DIR%\%FOLDER_1%"
if %errorlevel% neq 0 (
    echo Error: Failed to clone mp_package_hg2259.
    pause
    exit /b %errorlevel%
)
echo ************************************************************************
git clone http://%GitUsername%%Git_Password%@192.168.18.188:7990/scm/hg2259/hg2259.git "%SCRIPT_DIR%\%FOLDER_2%"
if %errorlevel% neq 0 (
    echo Error: Failed to clone hg2259_code.
    pause
    exit /b %errorlevel%
)
echo ************************************************************************
echo Successfully cloned MPTool and hg2259_code...
echo.
:: 选择切换到分支或者版本号
cd /d %SCRIPT_DIR%\%FOLDER_2%
echo +-----------------------------------------------------------------------+
echo ^|              Choose the options you need to switch!                    ^|
echo ^|                                                                       ^|
echo ^|     *************************  1: Branch  *************************   ^|
echo ^|     *************************  2: Tag     *************************   ^|
echo ^|                                                                       ^|
echo ^|         Press the "Enter" key means you chose the "default" option.   ^|
echo +-----------------------------------------------------------------------+

:menu
echo ************************************************************************
:: 提示用户输入选择
set /p "options=Enter your choice (1: Branch, 2: Tag, Default: Branch): "

if "%options%"=="" set "options=1"

if "%options%"=="1" (
    :: 分支模式
    set /p "branch_name=Please enter the Branch name (Default: master): "
    if "!branch_name!"=="" (
        set "branch_name=master"
    )
    echo Processing: !branch_name!
    echo git checkout !branch_name!
    git checkout -B !branch_name! origin/!branch_name!
    if errorlevel 1 (
        echo Git command failed.
        pause
        goto end
    )
) else if "%options%"=="2" (
    :: 标签模式
    set /p "tag_name=Please enter the Tag name: "
    if "!tag_name!"=="" (
        echo Tag name cannot be empty.
        goto menu
    )
    echo Processing: !tag_name!
    git checkout !tag_name!
    if errorlevel 1 (
        echo Git command failed.
        pause
        goto end
    )
    git switch -c !tag_name!
    if errorlevel 1 (
        echo Git switch failed.
        pause
        goto end
    )
) else (
    echo Invalid option selected. Please enter 1 or 2.
    goto menu
)

echo.
:choose_flash_type
cd /d %SCRIPT_DIR%\%FOLDER_2%\build
:: 显示选项
echo +-----------------------------------------------------------------------+
echo ^|             Choose the flash type you want to compile!                 ^|
echo ^|                                                                       ^|
echo ^|     ********************  0: HYNIX_V6       ********************      ^|
echo ^|     ********************  1: YMTC_TAS_TLC   ********************      ^|
echo ^|     ********************  2: HYNIX_V7_TLC   ********************      ^|
echo ^|     ********************  3: HYNIX_V7_QLC   ********************      ^|
echo ^|     ********************  4: YMTC_EMS_QLC   ********************      ^|
echo ^|     ********************  5: SANDISK_BICSS_TLC   ***************      ^|
echo ^|                                                                       ^|
echo ^|         Press the "Enter" key means you chose the "default" option.   ^|
echo +-----------------------------------------------------------------------+

:: 提示用户输入选择
set /p "flash_type=Enter your choice (Default: HYNIX_V7_TLC): "

:: 如果用户没有输入，则将 flash_type 设置为默认值
if "%flash_type%"=="" set "flash_type=2"

:: 验证输入是否有效
if "%flash_type%"=="0" (
    set "default_fw_version=HDFEB1.0"
    set "default_burner_version=HDBEB1.0"
    set "default_rdt_version=HDREB1.0"
) else if "%flash_type%"=="1" (
    set "default_fw_version=HDFFA1.0"
    set "default_burner_version=HDBFA1.0"
    set "default_rdt_version=HDRFA1.0"
) else if "%flash_type%"=="2" (
    set "default_fw_version=HDFED1.0"
    set "default_burner_version=HDBED1.0"
    set "default_rdt_version=HDRED1.0"
) else if "%flash_type%"=="3" (
    set "default_fw_version=HDFEE1.0"
    set "default_burner_version=HDBEE1.0"
    set "default_rdt_version=HDREE1.0"
) else if "%flash_type%"=="4" (
    set "default_fw_version=HDFFB1.0"
    set "default_burner_version=HDBFB1.0"
    set "default_rdt_version=HDRFB1.0"
) else if "%flash_type%"=="5" (
    set "default_fw_version=HDFDA1.0"
    set "default_burner_version=HDBDA1.0"
    set "default_rdt_version=HDRDA1.0"
) else (
    echo Invalid flash_type selected. Please enter a number between 0 and 5.
    pause
    goto choose_flash_type
)

:: 提示用户输入固件版本
set /p "fw_version=Enter Firmware version (default: %default_fw_version%): "

:: 如果用户没有输入，则将 fw_version 设置为默认值
if "%fw_version%"=="" set "fw_version=%default_fw_version%"

:: 提示用户输入烧录器版本
set /p "burner_version=Enter Burner version (default: %default_burner_version%): "

:: 如果用户没有输入，则将 burner_version 设置为默认值
if "%burner_version%"=="" set "burner_version=%default_burner_version%"

:: 提示用户输入RDT版本
set /p "rdt_version=Enter RDT version (default: %default_rdt_version%): "

:: 如果用户没有输入，则将 rdt_version 设置为默认值
if "%rdt_version%"=="" set "rdt_version=%default_rdt_version%"

cd /d %SCRIPT_DIR%\%FOLDER_2%\ver 
:: 调用第一个脚本并传递用户输入的值
call setVer.bat %flash_type% %fw_version% %burner_version% %rdt_version%

:end
echo ************************************************************************

echo.
cd /d %SCRIPT_DIR%\%FOLDER_2%\build

echo make clean
make -j FLASH_TYPE=%flash_type% clean 
if %errorlevel% neq 0 (
    echo Error: Failed to execute 'make clean'.
    pause
    exit /b %errorlevel%
)

echo make all
make -j FLASH_TYPE=%flash_type% all 
if %errorlevel% neq 0 (
    echo Error: Failed to execute 'make all'.
    pause
    exit /b %errorlevel%
)

echo make genBin
make -j FLASH_TYPE=%flash_type% genBin 
if %errorlevel% neq 0 (
    echo Error: Failed to execute 'make genBin'.
    pause
    exit /b %errorlevel%
)

echo make genRDT
make -j FLASH_TYPE=%flash_type% genRDT 
if %errorlevel% neq 0 (
    echo Error: Failed to execute 'make genRDT'.
    pause
    exit /b %errorlevel%
)


:: 根据 flash_type 设置 file2_name
if "%flash_type%"=="2" (
    set "file2_name=HDFED1.0"
) else if "%flash_type%"=="0" (
    set "file2_name=HDFEB1.0"
) else if "%flash_type%"=="1" (
    set "file2_name=HDFFA1.0"
) else if "%flash_type%"=="3" (
    set "file2_name=HDFEE1.0"
) else if "%flash_type%"=="4" (
    set "file2_name=HDFFB1.0"
) else if "%flash_type%"=="5" (
    set "file2_name=HDFDA1.0"
) else (
    echo Unknown fw_version.
    pause
    exit /b 1
)

:: 根据 flash_type 设置 file3_name
if "%flash_type%"=="2" (
    set "file3_name=HDRED1.0"
) else if "%flash_type%"=="0" (
    set "file3_name=HDREB1.0"
) else if "%flash_type%"=="1" (
    set "file3_name=HDRFA1.0"
) else if "%flash_type%"=="3" (
    set "file3_name=HDREE1.0"
) else if "%flash_type%"=="4" (
    set "file3_name=HDRFB1.0"
) else if "%flash_type%"=="5" (
    set "file3_name=HDRDA1.0"
) else (
    echo Unknown RDT_version.
    pause
    exit /b 1
)

:: 复制Bin文件
set "target_dir=%SCRIPT_DIR%\%FOLDER_1%\Bin"

:: 搜索包含 FileMerge 的文件夹
for /d %%d in ("%SCRIPT_DIR%\%FOLDER_2%\tool\FileMerge*") do (
    set "filemerge_dir=%%d"
)

set "search_dir1=%filemerge_dir%\MP"
set "search_dir2=%filemerge_dir%\RDT"

set "file1_name=HG2259_BURNER.bin"
for /r "%search_dir1%" %%i in (*%file1_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo copy BURNER_BIN
)

for /r "%search_dir1%" %%i in (*%file2_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo copy MP_BIN
)

for /r "%search_dir2%" %%i in (*%file3_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo copy RDT_BIN
)
echo.

cd %SCRIPT_DIR%\%FOLDER_2%
echo ************************************************************************
:: 提示用户输入信息
echo Now you need to get the SHA of the current branch or tag.
set /p "current_tag=Please Press the "Enter" key(Default current SHA): "

:: 创建并切换到分支
if "%current_tag%" == "" (
    :: 使用git rev-parse获取当前commit的SHA值
    for /f "delims=" %%a in ('git rev-parse HEAD') do set "current_sha=%%a"
    echo Now_SHA: !current_sha!
) 

:: 提取SHA的前7位数字
set "short_sha=!current_sha:~0,7!"
echo First 7 characters of current SHA: !short_sha!
echo.
echo ************************************************************************

:: 提示用户输入信息
set /p "old_tag=Please enter a version you would like to compare:"
echo ************************************************************************
:: 使用git rev-parse获取指定tag commit的SHA值
for /f "delims=" %%a in ('git rev-parse !old_tag!') do set "old_sha=%%a"
echo ************************************************************************
:: 输出read me文件
set "output_file=readme.txt" 

if "%current_tag%" == "" (
	set "current_tag=%short_sha%"
	echo Tag Name: !current_tag! > %output_file%
	echo *****************!short_sha! and !old_tag! PR***************** >> %output_file%
) else (
	echo Tag Name: !current_tag! > %output_file%
	echo *****************!current_tag! and !old_tag! PR***************** >> %output_file%
)

:: 使用git log列出两个commit之间的提交，并通过findstr搜索PR信息
git log --pretty=format:"%%h %%s" %old_sha%..%current_sha% | findstr /i /c:"Pull request #" >> "%output_file%"
echo *************************************************************************************** >> %output_file%
echo PR information has been written to %output_file%
echo.
:: 复制readme.txt到MP Tool并删除原本的readme.txt
copy "%output_file%" "%SCRIPT_DIR%\%FOLDER_1%"
del %output_file%

:: 定义要搜索的文件路径
set file_path=%search_dir1%\%file2_name%.bin

:: 检查文件是否存在
if not exist "%file_path%" (
    echo File not found: %file_path%
	pause
    exit /b 1
)
:: 读取文件内容并搜索十六进制字符串
set found=0
for /f "tokens=*" %%i in ('findstr /c:"%short_sha%" "%file_path%"') do (
    set found=1
)

if %found%==1 (
    echo Hex string '%short_sha%' found in the file.
) else (
    echo Hex string '%short_sha%' not found in the file.
)

echo ************************************************************************
cd /d %SCRIPT_DIR%\%FOLDER_2%
for /f "delims=" %%G in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%G"

::	判断返回值是否以 "heads/" 开头
set "PREFIX=heads/"
if "%BRANCH:~0,6%"=="%PREFIX%" (
    :: 去掉开头的 "heads/"
    set "BRANCH=%BRANCH:~6%"
)

:: 判断是否以 "feature/" 开头
set "FEATURE_PREFIX=feature/"
if "%BRANCH:~0,8%"=="%FEATURE_PREFIX%" (
    :: 去掉开头的 "feature/"
    set "BRANCH=%BRANCH:~8%"
)

:: 获取当前日期和时间并格式化为 YYYYMMDDHHMM
for /f %%i in ('powershell -command "Get-Date -Format \"yyyyMMddHHmm\""') do set formatted_datetime=%%i

set "originalFolder=%SCRIPT_DIR%\%FOLDER_1%"
set "newFolder=%SCRIPT_DIR%\%FOLDER_1%_%BRANCH%_%formatted_datetime%"

:: 复制并重命名文件夹
xcopy "%originalFolder%" "%newFolder%" /E /I /H /Y

:: 删除新文件夹中的 .git 子文件夹
rd /s /q "%newFolder%\.git"

:: 进入新文件夹
cd /d "%newFolder%\Bin"

:: 修改子文件夹中的某个文件名
ren "%file2_name%.bin" "%fw_version%.bin"
ren "%file3_name%.bin" "%rdt_version%.bin"
 
echo ***************************************************************************************************************	
echo	We've finished compiling the code and Newest mptool produce.
echo.
echo	Please manually check the SHA value in the bin file for correctness.
echo.
echo	Please manually modify FlashInfo.
echo.
echo	If you want to be able to achieve a green pass for your card results, 
echo.
echo	press "enter" key and we'll give you a tutorial below!
echo.  
echo ***************************************************************************************************************
echo.
pause
echo +---------------------------------------------------------------------------------------------------------+
echo 	Step 1, Double-click to run FlashInfoEditor.exe in mp_package_hg2259
echo 	Step 2, Drag FlashInfo.dat into FlashInfoEditor.exe and the editable page will appear.
echo		Step 3, Select your PartNumber and change the RDT FW and MP FW version you need.
echo 	Step 4, Click Save (ctrl^+s) at the top of.
echo 	Step 5, A new FlashInfo_new.dat file will be automatically generated in the mp_package_hg2259 folder.
echo 	Step 6, Delete the old FlashInfo.dat and rename FlashInfo_new.dat to FlashInfo.dat.	
echo +---------------------------------------------------------------------------------------------------------+				


endlocal

:end
echo ************************************************************************
pause
