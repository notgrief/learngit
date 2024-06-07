1.双击运行auto.bat

2.本脚本第一次使用需完善config.txt配置文件,包括Gitcmd路径，Git账号密码，AndeSight编译路径

********************************config.txt参考*****************************************
GitPath=D:\Program Files\Git\cmd
gitUsername=*******
gitPassword=*******
AndeSightPath1=C:\Andestech\AndeSight_STD_v521\cygwin\bin
AndeSightPath2=C:\Andestech\AndeSight_STD_v521\toolchains\nds32le-elf-mculib-v5\bin
************************************************************************************
以上路径仅供参考，区别一般是安装在C盘还是D盘，
手动输入一次后，即可自动生成Config.txt。

3.脚本运行过程中请不要打开任何文件夹。否则可能会出现进程被占用，Bat脚本无法正常执行，会出现切换分支失败、编译失败等问题,等待脚本结束后，再执行其他操作。

4.本脚本中所有Default XXX选项,按下Enter键即可默认操作选项

5.使用后请手动检查对比SHA：
	①在Git—Bash中输入git rev-parse xxx （xxx为你的分支名/版本号） 获取SHA（前7位）
	②二进制形式打开 .\mp_package_hg2259\Bin\HDFxxx.bin 搜寻文件中是否存在我们从Git中获取到的SHA
 
