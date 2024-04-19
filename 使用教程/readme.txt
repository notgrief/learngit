1.本脚本第一次使用需完善配置文件。打开脚本，按下面的环境配置参考寻找本机中的实际路径。

2.以管理员权限打开使用脚本<MPTool_Packaging.bat>

2.使用过程中请不要打开克隆文件夹，进行任何操作。否则可能会出现进程被占用，Bat脚本无法正常执行，会出现切换分支失败...编译失败...压缩失败等问题

3.本脚本中所有Default XXX选项,按下Enter键即可默认操作选项

4.出现任何失败解决步骤：①检查文件是否完整克隆到本地
		      ②检查本地hg2259文件是否成功切换到你输入的分支，对比SHA
		      ③检查环境配置是否配置正确，如果配置正确，仍无法使用，搜索系统环境变量进行修改。修改过程已放到使用该目录下
		      ④使用时发现返回错误信息是Too many arguments.可能是由于你的账号密码在保存到Config.txt文件时，多存空格，删掉空格即可

5.使用后请手动检查对比SHA以及分支或Tag是否切换成功：
			 ①在Git—Bash中输入git rev-parse xxx （xxx为你的分支名/版本号） 获取SHA（前7位）
			 ②二进制形式打开.\mp_package_hg2259\Bin\HDFED1.0.bin 搜寻文件中是否存在我们从Git中获取到的SHA

6.配置完Config.txt后，再次打开脚本后出现too many arguments.原因是存到Config.txt的账号密码存在空格，请仔细检查。
********************************环境配置参考*****************************************
GitPath=D:\Program Files\Git\cmd
gitUsername=sukzing
gitPassword=*******
AndeSightPath1=C:\Andestech\AndeSight_STD_v521\cygwin\bin
AndeSightPath2=C:\Andestech\AndeSight_STD_v521\toolchains\nds32le-elf-mculib-v5\bin
************************************************************************************
以上路径仅供参考，区别一般是安装在C盘还是D盘，
需要手动输入一次后，即可保存在生成的Config.txt。