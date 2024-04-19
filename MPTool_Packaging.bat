@echo off
set PowerShellPath=C:\Windows\System32\WindowsPowerShell\v1.0
setlocal enabledelayedexpansion
set path=%path%;C:\Windows\System32;
:: 获取脚本所在目录路径
for %%I in ("%~dp0.") do set "SCRIPT_DIR=%%~fI"

:: 设置 Git 配置文件路径
set PATH_CONFIG=%SCRIPT_DIR%\config.txt

cd %SCRIPT_DIR%
:: 设置要拉取的文件夹名称
set FOLDER_1=mp_package_hg2259
set FOLDER_2=hg2259

:: 检查并删除之前的文件夹（如果存在）
if exist "%SCRIPT_DIR%\%FOLDER_1%" (
    rd /s /q "%SCRIPT_DIR%\%FOLDER_1%"
)
if exist "%SCRIPT_DIR%\%FOLDER_2%" (
    rd /s /q "%SCRIPT_DIR%\%FOLDER_2%"
)

if not exist "%PATH_CONFIG%" (
    echo config.txt file does not exist.
	echo ***********************************************************
	echo We can't find the Software path.
	echo Please enter enter your account number, password and path.
	:: 提示用户手动输入账号和密码
	set /p GitPath="GitPath: "
    set /p gitUsername="Git_Username: "
    set /p gitPassword="gitPassword: "	
    set /p AndeSightPath1="AndeSightPath__1: " 
    set /p AndeSightPath2="AndeSightPath__2: " 	
	echo ***********************************************************
    :: 将信息写入配置文件
    >"%PATH_CONFIG%" (
		echo GitPath=!GitPath!
        echo gitUsername=!gitUsername!
        echo gitPassword=!gitPassword!	
        echo AndeSightPath1=!AndeSightPath1!
        echo AndeSightPath2=!AndeSightPath2!
    )
) else (
    :: 从配置文件中读取信息
    for /f "usebackq tokens=1,* delims== " %%a in ("%PATH_CONFIG%") do (
	    if /i "%%a"=="GitPath" set "GitPath=%%b"		
        if /i "%%a"=="gitUsername" set "gitUsername=%%b"
        if /i "%%a"=="gitPassword" set "gitPassword=%%b"	
        if /i "%%a"=="AndeSightPath1" set "AndeSightPath1=%%b"
        if /i "%%a"=="AndeSightPath2" set "AndeSightPath2=%%b"
    )
)

set path=%path%;%GitPath%;

:: 拉取最新的文件夹
git clone http://%gitUsername%:%gitPassword%@192.168.18.188:7990/scm/hg2259/mp_package_hg2259.git "%SCRIPT_DIR%\%FOLDER_1%"
git clone http://%gitUsername%:%gitPassword%@192.168.18.188:7990/scm/hg2259/hg2259.git "%SCRIPT_DIR%\%FOLDER_2%"

echo Successfully cloned MP_Tool and hg2259...
echo ***********************************************************
cd /d %SCRIPT_DIR%\%FOLDER_2%
:: 显示选项
echo 1: Branch
echo 2: Tag
echo ***********************************************************
:: 提示用户输入选择
set /p "mode=Enter your choice(Default: Branch): "

if "%mode%"=="" set "mode=1" 

if "%mode%"=="1" (
    :: 分支模式
    set /p "branch_name=Please enter the branch name (Default master): "
    if "!branch_name!"=="" (
        echo Processing: master
        echo git checkout master
        git checkout -B master origin/master || goto checkoutFailed
    ) else (
        echo Processing: !branch_name!
        echo git checkout !branch_name!
        git checkout -B !branch_name! origin/!branch_name! || goto checkoutFailed
    )
) else if "%mode%"=="2" (
    :: 标签模式
    set /p "tag_name=Please enter the tag name: "
    echo Processing: !tag_name!
    git checkout !tag_name!
    git switch -c !tag_name! || goto checkoutFailed
) else (
    echo Invalid mode selected.
    goto failed
)

::	选择Flah type类型
cd /d %SCRIPT_DIR%\%FOLDER_2%\build
echo ***********************************************************
:: 显示选项
echo 0: HYNIX_V6
echo 1: YMTC_TAS
echo 2: HYNIX_V7
echo ***********************************************************
:: 提示用户输入选择
set /p "flash_type=Enter your choice(Default: HYNIX_V7):"

:: 如果用户没有输入，则将 flash_type 设置为默认值
if "%flash_type%"=="" set "flash_type=2" 

:: 提示用户输入固件版本
set /p "fw_version=Enter firmware version (default: HDFED1.0): "

:: 如果用户没有输入，则将 fw_version 设置为默认值
if "%fw_version%"=="" set "fw_version=HDFED1.0"

:: 提示用户输入烧录器版本
set /p "burner_version=Enter burner version (default: HDBED1.0): "

:: 如果用户没有输入，则将 burner_version 设置为默认值
if "%burner_version%"=="" set "burner_version=HDBED1.0"

:: 提示用户输入RDT版本
set /p "rdt_version=Enter RDT version (default: HDRED1.0): "

:: 如果用户没有输入，则将 rdt_version 设置为默认值
if "%rdt_version%"=="" set "rdt_version=HDRED1.0"

cd /d %SCRIPT_DIR%\%FOLDER_2%\ver 
:: 调用第一个脚本并传递用户输入的值
call setVer.bat %flash_type% %fw_version% %burner_version% %rdt_version%

cd /d %SCRIPT_DIR%\%FOLDER_2%\build

echo make clean
make -j FLASH_TYPE=%flash_type% clean 
echo make all
make -j FLASH_TYPE=%flash_type% all 
echo make genBin
make -j FLASH_TYPE=%flash_type% genBin 
echo make genRDT
make -j FLASH_TYPE=%flash_type% genRDT 
	

:: 复制Bin文件
set "target_dir=%SCRIPT_DIR%\%FOLDER_1%\Bin"

set "search_dir1=%SCRIPT_DIR%\%FOLDER_2%\tool\FileMerge 20240131\MP"
set "file1_name=HG2259_BURNER.bin"
for /r "%search_dir1%" %%i in (*%file1_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo copy BURNER BIN
)

set "search_dir3=%SCRIPT_DIR%\%FOLDER_2%\tool\FileMerge 20240131\MP"
set "file3_name=HDFED1.0"
for /r "%search_dir3%" %%i in (*%file3_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo copy MP BIN
)

set "search_dir4=%SCRIPT_DIR%\%FOLDER_2%\tool\FileMerge 20240131\RDT"
set "file4_name=HDRED1.0"
for /r "%search_dir4%" %%i in (*%file4_name%*) do (
    copy "%%~fsi" "%target_dir%"
    echo echo copy RDT BIN
)

cd %SCRIPT_DIR%\%FOLDER_2%
echo ***********************************************************
:: 提示用户输入信息
echo If the tag is updated, the last tag name must be entered
set /p "current_tag=Please enter the current Tag name(Default current commit): "

:: 创建并切换到分支
if "%current_tag%" == "" (
    :: 使用git rev-parse获取当前commit的SHA值
    for /f "delims=" %%a in ('git rev-parse HEAD') do set "current_sha=%%a"
    echo Now_SHA: !current_sha!
) else (
    :: 使用git rev-parse获取指定tag commit的SHA值
    for /f "delims=" %%a in ('git rev-parse !current_tag!') do set "current_sha=%%a"
    echo Now_SHA: !current_sha!
)

:: 提取SHA的前7位数字
set "short_sha=!current_sha:~0,7!"
echo First 7 characters of SHA: !short_sha!

echo ***********************************************************
:: 提示用户输入信息
set /p "old_tag=Please enter the old Tag name: "
echo ***********************************************************
:: 使用git rev-parse获取指定tag commit的SHA值
for /f "delims=" %%a in ('git rev-parse !old_tag!') do set "old_sha=%%a"
echo Old_SHA: !old_sha!

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
echo ************************************************************************** >> %output_file%

echo PR information has been written to %output_file%
:: 复制readme.txt到MP Tool并删除原本的readme.txt
copy "%output_file%" "%SCRIPT_DIR%\%FOLDER_1%"
del %output_file%

cd /d %SCRIPT_DIR%\%FOLDER_2%
for /f "delims=" %%G in ('git rev-parse --abbrev-ref HEAD') do set "BRANCH=%%G"

::	判断返回值是否以 "heads/" 开头
set "PREFIX=heads/"
if "%BRANCH:~0,6%"=="%PREFIX%" (
    REM 去掉开头的 "heads/"
    set "BRANCH=%BRANCH:~6%"
)

:: 判断是否以 "feature/" 开头
set "FEATURE_PREFIX=feature/"
if "%BRANCH:~0,8%"=="%FEATURE_PREFIX%" (
    REM 去掉开头的 "feature/"
    set "BRANCH=%BRANCH:~8%"
)

cd %SCRIPT_DIR%
set path=%path%;%PowerShellPath%;
:: 执行 PowerShell 脚本并检查执行结果
powershell.exe -ExecutionPolicy Bypass -File "search_binary.ps1" "!short_sha!"
if %errorlevel% neq 0 (
    echo PowerShell script execution failed.
    echo Comparison error, please check the logs for more details.
    exit /b %errorlevel%
	goto comparefailed
)

:: 如果 PowerShell 执行成功，继续执行后续命令
echo PowerShell script executed successfully, continuing with the process...

:: 获取当前日期和时间
for /f "delims=" %%i in ('powershell -Command "Get-Date -Format yyyyMMddHHmmss"') do set formattedDateTime=%%i

powershell -Command "Compress-Archive -Path '%SCRIPT_DIR%\%FOLDER_1%\*' -DestinationPath '%SCRIPT_DIR%\%FOLDER_1%_!BRANCH!_!formattedDateTime!.zip'"
:: 显示压缩完成消息
echo *************************************************************************************************
echo **************************           Execution Succeeded            *****************************
echo **************************              zip completed               *****************************
echo ********   zip path:%SCRIPT_DIR%\%FOLDER_1%_!BRANCH!_!formattedDateTime!.zip   ***********
echo *************************************************************************************************

goto compressed 

:checkoutFailed
	echo 	Git checkout Failed,Please enter the correct branch name or Tag name.
:Clonefailed
	echo Clone Failed,Please check Your gitUsername and gitPassword.
:Make failed
	echo Make Failed~~~
:comparefailed
	echo Compared Failed~~~
:compressed
	echo MP_TOOL has checked the Bin file and successfully compressed it!

endlocal
pause