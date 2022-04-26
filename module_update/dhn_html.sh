#!/bin/sh

#需要更新的版本号
updateVersionCode=""

#当前版本号
currentVersionCode=""
#前缀
prefix=""


#git 路径
gitPath="/Users/ys/Desktop/banxiangrui.github.io/"
#dhn html 路径
dhnHtmlPath="/Users/ys/Desktop/banxiangrui.github.io/dhn/cn/"
#html地址
dhnHtml=${dhnHtmlPath}"index.html"

# rm  dhnHtml
#获取最新html
echo "####### 获取最新html并更新本地html #######"
# wget -O index.html  https://banxiangrui.github.io/dhn/cn/index.html 


if [ ! $1 ]
then
  echo "####### 请输入需要更新的库 #######"
  exit;
fi
if [ ! $2 ]
then
  echo "####### 请输入需要更新的版本号 #######"
  exit;
fi

 
case "$1" in
  "user")
  echo "####### User库更新 #######"
  path="/Users/ys/Desktop/banxiangrui.github.io"
  prefix="User_"
  ;;
  "base")
  echo "####### base库更新 #######"
  path="/Users/duodian/Desktop/work/circleManAdmin"
  prefix="Base_"
  ;;
  "gift")
  echo "####### base库更新 #######"
  path="/Users/duodian/Desktop/work/circleManAdmin"
  prefix="Gift_"
  ;;
esac

while read line
do
    if [[ $line =~ $prefix ]]
    then
      echo
      #找到定位地址
      echo "####### 截取 找到定位地址行"$line
      #根据前缀
      echo "####### 根据前缀：$prefix 截取" 
      firstStr=${line#*$prefix}
      echo "####### 截取结果：$firstStr"
      #获得最后的版本号
      currentVersionCode=${firstStr%%"<"*}
      echo "####### 最后截取结果 当前版本号：$currentVersionCode"
    fi
done < $dhnHtml

#替换版本号内容
updateVersionCode=$2
echo
if [[ $currentVersionCode == "" ]]
then
  echo "####### 全局版本号为空，请重新尝试 #######"
  exit;
fi

if [[ $updateVersionCode == "" ]]
then
  echo "####### 全局更新版本号为空，请重新尝试 #######"
  exit;
fi


echo "####### 前缀：${prefix}"
echo "####### 前缀+当前版本号：${prefix}${currentVersionCode}"
echo "####### 前缀+更新版本号：${prefix}${updateVersionCode}"


sed -i "_bak_`date`" "s/${prefix}${currentVersionCode}/${prefix}${updateVersionCode}/g"  "index.html"

sh dhn_html_git.sh  "nav" "增加脚本" ""






