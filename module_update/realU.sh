#!/bin/sh
#app的源码路径
approot="~/Documents/AndroidProject/RealBak/RealU/pengpeng2019"
#七牛的上传文件路径
zpath="/Users/ys/Desktop/upload_sh/index/z/"
appname="RealU"
appnamezh="RealU"
#RealU_2020_11_12_realULocalDevelopRelease_1.3.0_13000.apk
versionnameindex=42
versioncodeindex=48

cd $approot
# gradle clean
# gradle assembleRealULocalDevelopRelease
apkpath=${approot}"/build/outputs/apk/realUGoogle/release/"
uploadpath=${zpath}"qiniu/android"
indexpath=${zpath}"lamour.html"
qupload=${zpath}".qshell/qupload"
# echo $apkpath
# echo $uploadpath
# echo $indexpath
# echo $qupload

cd $apkpath

for filename in `ls`
do
# production="fancyUGoogleRelease"
# echo "$filename"|grep -q $production
production="realUGoogle"
if echo "$filename"|grep -q $production;
then
	echo $filename 
	versionname=${filename:versionnameindex:5}
	echo $versionname
	#echo `expr match "$filename" : 'production'`
	#echo $filename | sed -n "s/[$production].*//p" | wc -c
	versioncode=${filename:versioncodeindex:5}
	echo $versioncode
	#清空七牛的上传记录和上传文件
	rm $uploadpath/* 
	rm $qupload/* 
	cp $apkpath/$filename $uploadpath/$filename 
	#备份html
	cp $indexpath "${zpath}${appname}`date '+ %s'`.html"
	#复制线上html
	# rm -rf $indexpath
	# wget https://test.pengpengla.com/android/lamour.html --http-user=test --http-passwd=Test@chirou -P $zpath
	indexhtml=`cat $indexpath`
	#echo `expr "$indexpath" : '.*\(up_*.production_localDevelop.apk)\'`
	newindexhtml=${indexhtml/${appname}_*btn_${appname}/${filename}\"class=\"btn_${appname}}
	echo ${newindexhtml/${appnamezh}_[1-9]\.[0-9]\.[0-9]([1-9][0-9][0-9][0-9][0-9])/${appnamezh}_${versionname}(${versioncode})} > ${indexpath}
	#上传apk html
	cd  $zpath
	#./qrsync conf.json
	# ./qshell qupload 10 qshell_conf.json
	# scp -P 7922 lamour.html bbb-android@134.175.22.63:/data/work/ppdemo/android
fi
done 


