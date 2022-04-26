# ！！！！module路径，需要git
gitProjectPath="/Users/yc/AndroidStudioProjects/ZZZZZZZZZZZ/lucky"
# ！！！！这是是需要修改的记录上次打印提交的commitid，找老大建一个文件就可以，然后把最近一次提交的commitid写进去就可以
lastCommitIdFilePath="/Users/yc/AndroidStudioProjects/ZZZZZZZZZZZ/commitHistory"
# !!!!下载路径前缀 , 可以去https://test.pengpengla.com/android/lamour.html 把自己项目的链接截取出来
dowloadPreUrl="https://g-cdn.upliveapp.com/background/dhn_android/apk/FancyMe/test"
# 二维码名称
qrFileName="qr.png"

#获取飞书上传图片所需的token
getToken(){
    res=$(curl -X POST 'https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal' \
    -H 'content-type:application/json; charset=utf-8' \
    -d '{
        "app_id": "cli_a139d7414238100d",
        "app_secret": "IdVKGxBJM3DWuKjSDEsHyeOyx4kcoSoH"
    }' )
    # 截取 "tenant_access_token":" 右侧字符
    temp1=${res##*\"tenant_access_token\":\"}
    # 截取”左侧字符  最终获得了token
    echo ${temp1%%\"*}
}
# 获取apkname 遍历了路径中以.apk结尾的文件
getApknameFromReleasePath(){
    paramReleasePath=$1
    allFile=`ls $paramReleasePath`
    releaseFileArray=(${allFile// / })  
    apkName=""
    for filename in ${releaseFileArray[@]}
    do
        if [[ $filename =~ ".apk" ]]
        then
        apkName=$filename
        fi
    done
    echo $apkName
}

# ！！！！根据文件名字获取版本号 这里是按一定的规则去做匹配，需要查看项目打出来的包是否符合此规则，不符合请自行修改一下
getVersionCodeFromApkname(){
    # 获取了外部传进来的apkname   fancyme传进来的是 FancyMe_2021.12.29_3.6.0_8348.production_fancyMeLocalDevelop.apk
    paramApkname=$1
    # 这里截取了.production左侧的所有字符并保存 即 FancyMe_2021.12.29_3.6.0_8348
    versionCodeTemp=${paramApkname%%.production*}
    # 这里截取了最后一个 _ 右侧的所有字符 即 8348
    echo ${versionCodeTemp##*_}
}

# ！！！！根据文件名字获取版本名 这里是按一定的规则去做匹配，需要查看项目打出来的包是否符合此规则，不符合请自行修改一下
getVersionNameFromApkname(){
    # 获取了外部传进来的apkname   fancyme传进来的是 FancyMe_2021.12.29_3.6.0_8348.production_fancyMeLocalDevelop.apk
    paramApkname=$1
    # 获取了外部传进来的版本号 即上面的8348
    paramVersionCode=$2
    # 截取了 _8384左侧的所有字符 即FancyMe_2021.12.29_3.6.0
    versionNameTemp=$(eval echo '$'"{paramApkname%%_$paramVersionCode*}")
    # 截取了最后一个 _ 符号右侧所有的字符 即3.6.0
    echo ${versionNameTemp##*_} 
}

# 上传二维码到飞书
getImageKey(){
    res=$(curl --header POST 'content-type:multipart/form-data' \
    --header "Authorization:Bearer $token" \
    'https://open.feishu.cn/open-apis/image/v4/put/' \
    --form 'image_type="message"' \
    --form "image=@$qrFilePath")
    # 截取 "image_key":" 右侧字符
    temp1=${res##*\"image_key\":\"}
    # 截取”左侧字符  最终获得了token
    echo ${temp1%%\"*}
}


# ---------------- 生成二维码、一些必要参数的组合----------------
token=$(getToken)
buildDirPath=$gitProjectPath"/build"
apkDirPaht=$buildDirPath"/outputs/apk"
flavor=`ls $apkDirPaht`
flavorPath=$apkDirPaht"/"$flavor
# 这里给写死了，如果你们项目打包用了release命令则可以直接改为releaseType=`ls $flavorPath`
releaseType="release"
releasePath=$flavorPath"/"$releaseType
apkName=$(getApknameFromReleasePath "$releasePath")
versionCode=$(getVersionCodeFromApkname "$apkName")
versionName=$(getVersionNameFromApkname "$apkName" "$versionCode")
downApkUrl=$dowloadPreUrl"/"$apkName
qrFilePath=$buildDirPath"/"$qrFileName
# 生成了二维码  二维码生成在build目录下，每次clean就被清除了
qrencode -o "$qrFilePath" "$downApkUrl"
# 获取了飞书的image_key
imageKey=$(getImageKey)

# ---------------- 准备gitLog变更日志----------------
# 先调到项目目录下
cd $gitProjectPath
# 因为之前编译了项目所以应该fetch过了，不要再fetch了防止在这期间又有提交
# git fetch
# 获取上次打印过的commitId
lastCommitId=`cat $lastCommitIdFilePath`
# 获取当前的commitid
currentCommitId=`git rev-parse HEAD`
echo 当前commitId:$currentCommitId
echo 上次记录的commitId:$lastCommitId
# 获取这两次提交之间的变更说明
gitLog=`git log $lastCommitId..$currentCommitId --pretty=format:"%s\t%cn#"`
# 把中文冒号换成英文的
gitLog=${gitLog//：/:}
#按#进行了分割
array=(${gitLog//#/ }) 
changeResult=""
index=1
#开始遍历
for var in ${array[@]}
do
    if [[ $var =~ "]:" ]]
    then
        #按#进行了分割
        tempArray=(${var//"]:"/ }) 
        if [ ${#tempArray[@]} == 2 ]
        then
        nextChange="$index"、"${tempArray[1]}\n"
        echo $nextChange
        changeResult=$changeResult$nextChange
        index=`expr $index + 1`
        fi
    fi
done 

# ---------------- 发送飞书-------------------
url=""
curl -X POST -H "Content-Type: application/json"  \
    -d '{
        "msg_type": "post",
        "content": {
            "post": {
                "zh_cn": {
                    "title": "FancyMe-Android打包完成",
                                        "content": [
                        [
                            {
                              "tag": "at",
                              "user_id": "",
                              "user_name": "丛燕"
                            },{
                              "tag": "at",
                              "user_id": "",
                              "user_name": "天骄"
                            },
                            {
                                "tag": "text",
                                "text": "\n版本号：'$versionName'('$versionCode')，渠道为 '$flavor',版本为 '$releaseType'\n"
                            },
                            {
                                "tag": "a",
                                "text": "下载链接\n",
                                "href": "'$downApkUrl'"
                            },
                            {
                                "tag":"text",
                                "text":"手机下载请使用浏览器扫描下方二维码\n"
                            },
                            {
                                "tag": "img",
                                "image_key": "'$imageKey'"
                            },
                            {
                                "tag":"text",
                                "text":"\n\n更新日志:\n'$changeResult'"
                            }
                        ]
                    ]
                }
            }
        }
    }' \
    $url

# 把本次的打印完成的commitId添加到文件中
echo $currentCommitId > $lastCommitIdFilePath