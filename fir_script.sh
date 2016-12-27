#!/bin/bash
#fir.cli 自动打包流程
startTime=`date +"%s.%N"`
#####################打包信息设置
# 指定打包的scheme:  xxx,xxx_Dev
schema="xxx_Dev"
# 指定打包的分支名称
branch="branch01"
# 设置更新日志
changeLog="1.beta环境打包"
# 是否打包本地工程
isArchiveLocalProject=true

# 下面的设置不用经常变
#判断是用的workspace还是直接project，workspace设置为true，否则设置为false
isWorkSpace=true
#设置打包.ipa输出路径
output_path="ipa输出路径"
#git仓库url
git_url="git 仓库地址"
#本地仓库地址
project_path="本地项目地址"
#fir.im API_TOKEN
api_Token="*******"

echo "=================开始打包流程=================="
#进入工程目录
cd "$project_path"
rm -rf "$output_path"/build
# 打包


if $isWorkSpace
then


if $isArchiveLocalProject
then
echo "*************打包本地工程***************"
#编译用 CocoaPods 做依赖管理的 .ipa 包
fir build_ipa "$output_path"/$schema -B "$branch" -o "$output_path"/build -w -C AdHoc -S "$schema"
else
echo "*************打包服务器工程*************"
#3.编译 Github 上的 workspace
fir build_ipa "$git_url" -B "$branch" -o "$output_path"/build -w -C AdHoc -S "$schema" GCC_PREPROCESSOR_DEFINITIONS="FOO=bar"
fi


else
#编译 project, 加上 changelog, 并发布到 fir.im 上并生成二维码图片
fir build_ipa "$project_path" -o "$output_path"/build -p -c "$changeLog"  -T "$api_Token"
fi

#判断编译结果
if test $? -eq 0
then
echo "~~~~~~~~~~~~~~~~~~~编译成功~~~~~~~~~~~~~~~~~~~"
else
echo "~~~~~~~~~~~~~~~~~~~编译失败~~~~~~~~~~~~~~~~~~~"
exit 1
fi

echo "*************打包信息******************"
echo "schema:$schema"
echo "branch:$branch"
echo "changeLog:$changeLog"
echo "*******************************"

#切换到ipa文件目录
cd "$output_path"/build
echo "================打包完毕，正在上传fir.im....================"
# 上传到fir.im
fir publish -Q -c "$changeLog" ${schema}*.ipa

#返回主目录
cd ~

endTime=`date +"%s.%N"`
echo `awk -v x1="$(echo $endTime | cut -d '.' -f 1)" -v x2="$(echo $startTime | cut -d '.' -f 1)" -v y1="$[$(echo $endTime | cut -d '.' -f 2) / 1000]" -v y2="$[$(echo $startTime | cut -d '.' -f 2) /1000]" 'BEGIN{printf "-----------------打包执行时间:%d分%.0fs-----------------",((x1-x2)+(y1-y2)/1000000)/60,((x1-x2)+(y1-y2)/1000000)%60}'`
