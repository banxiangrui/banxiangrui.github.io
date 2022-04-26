#!/bin/sh

if [ ! $1 ]
then
  echo "####### 请输入自己的项目 #######"
  exit;
fi
 
if [ ! $2 ]
then
  echo "####### 请输入commit值 #######"
  exit;
fi
 
#给出一个默认的项目路径
path="/Users/ys/Desktop/banxiangrui.github.io"
 
case "$1" in
  "nav")
  echo "navigation导航项目"
  path="/Users/ys/Desktop/banxiangrui.github.io"
  ;;
  "m")
  echo "小程序项目"
  path="/Users/duodian/Desktop/work/miniProgram"
  ;;
  "h")
  echo "H5项目"
  path="/Users/duodian/Desktop/work/web-h5"
  ;;
  "c")
  echo "后台项目"
  path="/Users/duodian/Desktop/work/circleManAdmin"
  ;;
esac
 
#先进入项目当中
 
cd $path
 
echo "####### 进入自己的项目 #######"
 
ls
 
echo "开始执行命令"
 
git add .
 
git status
 
#写个sleep 1s 是为了解决并发导致卡壳
 
sleep 1s
 
echo "####### 添加文件 #######"
 
git commit -m "$2"
 
echo "####### commit #######"
 
sleep 1s
 
echo "####### 开始推送 #######"
 
if [ ! $3 ]
then
  echo "####### 请输入自己提交代码的分支 #######"
  exit;
fi
 
git push origin "$3"
 
echo "####### 推送成功 #######"





