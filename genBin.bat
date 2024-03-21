@echo off

::显示当前目录
echo %~dp0
set path=%path%;C:\Program Files\Git\cmd

::检查mp_package_hg2259文件夹是否存在
set folder=mp_package_hg2259
if exist %folder% (
    echo Folder mp_package_hg2259 exists. Deleting folder...
    rmdir /s /q %folder%
)

echo Clone MP_Tool
git clone http://192.168.18.188:7990/scm/hg2259/mp_package_hg2259.git || goto failed

cd /d %~dp0/mp_package_hg2259 || goto failed
echo git pull mp_package_hg2259
::拉取最新的mp_package_hg2259
git pull || goto failed
cd /d %~dp0/mp_package_hg2259 || goto failed
rmdir /s /q .git


cd /d %~dp0 || goto failed
set folder=hg2259
if exist %folder% (
    echo Folder hg2259 exists. Deleting folder...
    rmdir /s /q %folder%
)

echo Clone HG2259
git clone http://192.168.18.188:7990/scm/hg2259/hg2259.git || goto failed

cd /d %~dp0/hg2259 || goto failed
echo git pull hg2259
::拉取最新的hg2259
git pull || goto failed


@echo off
setlocal enabledelayedexpansion

:: 提示用户输入信息
set /p "branch_name=Please enter the branch name(Default master): "

::创建并切换到分支
if "%branch_name%" == "" (
	echo Processing: master
	echo git checkout
	git checkout -B master origin/master || goto failed
) else (
	:: 使用用户输入的信息作为参数
	echo Processing: !branch_name!
	echo git checkout
	git checkout -B %branch_name% origin/%branch_name% || goto failed
)

endlocal

@REM compile
@REM set path=%path%;D:\software\Andestech\AndeSight_STD_v511\toolchains\nds32le-elf-mculib-v5\bin;D:\software\Andestech\AndeSight_STD_v511\cygwin\bin;
set path=%path%;C:\Andestech\AndeSight_STD_v521\toolchains\nds32le-elf-mculib-v5\bin;C:\Andestech\AndeSight_STD_v521\cygwin\bin;

cd /d %~dp0/hg2259/build || goto failed
if "%2" == "" (
    @REM FLASH_TYPE = HYNIX_V7
	echo make clean
	make -j20 FLASH_TYPE=2 clean || goto failed
	echo make all
	make -j20 FLASH_TYPE=2 all || goto failed
	echo make genBin
	make -j20 FLASH_TYPE=2 genBin || goto failed
	echo make genRDT
	make -j20 FLASH_TYPE=2 genRDT || goto failed
) else (
	echo make clean 
	make -j20 FLASH_TYPE=%2 clean || goto failed
	echo make all
	make -j20 FLASH_TYPE=%2 all || goto failed
	echo make genBin
	make -j20 FLASH_TYPE=%2 genBin || goto failed
	echo make genRDT
	make -j20 FLASH_TYPE=%2 genRDT || goto failed
)

echo %~dp0
set "SEARCH_PATH=%~dp0\hg2259\tool"
:: 设置包含的指定内容
set "SEARCH_CONTAINS=FileMerge"
 
:: 遍历目标目录下的所有文件夹
for /d %%F in ("%SEARCH_PATH%\*") do (
	echo %%F | findstr /C:%SEARCH_CONTAINS% >nul 2>&1
    :: 检查文件夹名是否包含指定内容
	if errorlevel 1 (
		@REM echo NO
	) else (
		@REM echo YES
		@REM echo %%~nF
		set "SEARCH_RESULT=%%~nF"
	)
)

@REM cp '../tool/FileMerge*/MP/HDFED1.0.bin' ../tool/mp_package_hg2259/Bin || goto failed
echo copy BURNER BIN
cp '%~dp0/hg2259/tool/%SEARCH_RESULT%/MP/HG2259_BURNER.bin' %~dp0/mp_package_hg2259/Bin || goto failed
echo copy MP elf
cp '%~dp0/hg2259/output/HG2259_MP.elf' %~dp0/mp_package_hg2259/Bin || goto failed
echo copy MP BIN
cp '%~dp0/hg2259/tool/%SEARCH_RESULT%/MP/HDFED1.0.bin' %~dp0/mp_package_hg2259/Bin || goto failed
echo copy RDT BIN
cp '%~dp0/hg2259/tool/%SEARCH_RESULT%/RDT/HDRED1.0.bin' %~dp0/mp_package_hg2259/Bin || goto failed

set path=%path%;C:\Program Files\Git\cmd
cd %~dp0\hg2259

@echo off
setlocal enabledelayedexpansion

:: 提示用户输入信息
echo If the tag is updated, the latest tag name must be entered
set /p "current_tag=Please enter the current Tag name(Default current commit): "

::创建并切换到分支
if "%current_tag%" == "" (
	:: 使用git rev-parse获取当前commit的SHA值
	for /f "delims=" %%a in ('git rev-parse HEAD') do set "current_sha=%%a"
	echo !current_sha!
) else (
	:: 使用git rev-parse获取指定tag commit的SHA值
	for /f "delims=" %%a in ('git rev-parse %current_tag%') do set "current_sha=%%a"
	echo !current_sha!
)

:: 提示用户输入信息
set /p "old_tag=Please enter the compare Tag name: "

:: 使用git rev-parse获取指定tag commit的SHA值
for /f "delims=" %%a in ('git rev-parse %old_tag%') do set "old_sha=%%a"
echo !old_sha!

:: 输出文件
set "output_file=readme.txt" 

if exist %output_file% del %output_file%
type nul > %output_file%

@REM echo Commit Count: !commit_count! >> readme.txt
@REM echo Commit Hash: !commitnew! >> %output_file%

:: 使用PowerShell内嵌在批处理中转换字符串为16进制
for /f "delims=" %%a in ('powershell -Command "$inputString = '%current_sha%'; $bytes = [System.Text.Encoding]::ASCII.GetBytes($inputString); $hex = [BitConverter]::ToString($bytes); Write-Output $hex.Replace('-', '')"') do (
    set "outputHex=%%a"
)

:: 获取前14位并存储到新的变量中
for /f "delims=" %%a in ('powershell -Command "$str = '%outputHex%'; $str.Substring(0, 14)"') do (
    set "SHAoutputHex=%%a"
)

@REM :: 获取前14位并存储到新的变量中
@REM for /f "delims=" %%a in ('echo.%outputHex%^|cut -c1-14') do set "SHAoutputHex=%%a"

echo %SHAoutputHex%

@echo off

:: 获取前14位并存储到新的变量中
for /f "delims=" %%a in ('powershell -Command "$str = '%current_sha%'; $str.Substring(0, 9)"') do (
    set "shortcommitnew=%%a"
)

if "%current_tag%" == "" (
	set "current_tag=%old_tag%"
	echo Tag Name: !current_tag! > %output_file%
	echo *****************!shortcommitnew! and !old_tag! PR***************** >> %output_file%
) else (
	echo Tag Name: !current_tag! > %output_file%
	echo *****************!current_tag! and !old_tag! PR***************** >> %output_file%
)

:: 使用git log列出两个commit之间的提交，并通过findstr搜索PR信息
git log --pretty=format:"%%h %%s" %old_sha%..%current_sha% | findstr /i /c:"Pull request #" >> "%output_file%"

echo ************************************************************************** >> %output_file%

echo PR information has been written to %output_file%

::copy readme.txt到MP Tool并删除原本的readme.txt
cp '%~dp0/hg2259/%output_file%' '%~dp0/mp_package_hg2259' || goto failed
del %output_file%


cd %~dp0\mp_package_hg2259\Bin

@echo off

set "hexfile=input.txt"
set "outputfile=output.txt"
:: 需要根据 bin 文件 sha 的位置来修改
set "offset=492544"
@REM set "offset=459776"
set "bytes=7"

::使用certutil将二进制文件解码为16进制文件
powershell -Command "Get-Content -Encoding Byte -ReadCount 0 -Path 'HDFED1.0.bin' | ForEach-Object { '{0:X2}' -f $_ }" > "%hexfile%"

::使用certutil将16进制文件解码为二进制文件
certutil -decodehex "%hexfile%" "%~dp0\tmpfile.bin" >nul

::使用PowerShell提取指定位置的数据，并转换为16进制格式
powershell -Command "$bytes = [System.IO.File]::ReadAllBytes('%~dp0\tmpfile.bin'); $result = ''; for ($i = %offset%; $i -lt (%offset% + %bytes%); $i++) { $result += '{0:X2}' -f $bytes[$i]; }; Write-Output $result" > "%outputfile%"

::清理临时文件
del "%~dp0\tmpfile.bin"
del "%hexfile%"

echo %outputfile%

::设置文本文件路径
set "myFile=%~dp0/mp_package_hg2259/Bin/%outputfile%"

::使用PowerShell内嵌在批处理中比较字符串
for /f "delims=" %%a in ('powershell -Command "$fileContent = Get-Content '%myFile%' | Select-Object -First 1; if ('%SHAoutputHex%' -eq $fileContent.Substring(0,14)) {'success'} else {'fail'}"') do (
    echo gitSHA and Bin file compare %%a
	if "%%a" == "fail" (
		goto failed
	)
)
del %outputfile%

set path=%path%;C:\Program Files\Git\cmd
cd %~dp0\hg2259
for /f "delims=" %%a in ('git rev-parse --abbrev-ref HEAD') do (
    set "branchName=%%a"
)

:: 获取当前日期和时间
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "alldatetime=%%a"

:: 获取前12位并存储到新的变量中
for /f "delims=" %%a in ('powershell -Command "$str = '%alldatetime%'; $str.Substring(0, 12)"') do (
    set "datetime=%%a"
)

@REM :: 获取前12位并存储到新的变量中
@REM for /f "delims=" %%a in ('echo.%alldatetime%^|cut -c1-12') do set "datetime=%%a"

echo %datetime%

:: 设置要打包的文件夹路径和压缩文件的基本名称
set "folderPath=%~dp0/mp_package_hg2259"
set "zipBaseName=mp_package_hg2259"

:: 调用7-Zip进行压缩，并将格式化后的日期和时间添加到压缩文件名中
"%~dp0\7z2401-extra\7za.exe" a -tzip "%~dp0\!zipBaseName!_!branchName!_!datetime!.zip" "%folderPath%\*"

:: 显示压缩完成消息
echo *************************************************************************************************
echo **************************           Execution Succeeded            *****************************
echo **************************              zip completed               *****************************
echo ************   zip path:%~dp0\!zipBaseName!_!branchName!_!datetime!.zip   ***********
echo *************************************************************************************************

endlocal

pause
exit


:failed
echo Command execution Failed
pause