# !/bin/bash
# -----------------------------------------------------
# 把目录下所有 README.md 内容转换为 page 格式内容 
#
# -----------------------------------------------------

FILE_LIST=`ls -d */|sed 's|[/]||g'` 
OUTPUT=".output/"
rm -rf ${OUTPUT}
mkdir ${OUTPUT}

for file in ${FILE_LIST}
do  
    echo ${file}
    mkdir ${OUTPUT}${file} 
    cp ${file}"/README.md" ${OUTPUT}${file}"/index.md"
done 
