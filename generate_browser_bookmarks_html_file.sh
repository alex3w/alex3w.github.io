# !/bin/bash
# -----------------------------------------------------
# 生成HTML格式浏览器书签文件
# 暂时只支持二级目录，其它未测试
# -----------------------------------------------------

DEBUG=false
OUTPUT_FILE_NAME='bookmarks.html' # 最终生成的文件
FILE_LIST=`ls -d Topsites|sed 's|[/]||g'` # 文件夹Topsites
# FILE_LIST=`ls -d */|sed 's|[/]||g'`  所有分类文件夹
let BASE_TITLE_FLAG_CHAR_NUM=2

log() {
    if [[ ${DEBUG} == true ]]; then
        echo ${*}
    fi
}


appendToFile() { # 给文件添加一行， 取全部内容作为参数
    echo ${*} >> ${OUTPUT_FILE_NAME} 
}

generate() {
    log '开始生成...'
    # 头
    appendToFile '<!-- 通过浏览器书签管理器将此HTML文件导入书签 -->'
    appendToFile '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">'
    appendToFile '<div class="mark"><dt><h3>bookmarks</h3><dt>'
    appendToFile '<dl>'

    generateContent

    # 尾
    appendToFile '</dl>'
    appendToFile '</div>'
    log '生成完毕...'
}

generateContent() {
    log '开始遍历生成内容...'

    # :-)
    appendToFile '<dt><A HREF="https://alex3w.github.io/">Alex3w</A></dt>'
    
    for file in ${FILE_LIST}
    do  
        log '##################################################################################################'
        log '## 当前分类文件夹 >>> '${file}
        log '##################################################################################################'

        # 每个文件夹分类都新建一级<dt>
        appendToFile '<dt><h3>'${file}'</h3></dt>'
        appendToFile '<dl>'

        isReadingSiteLine=false
        let titleNum=0
        let currentTitleFlagNum=${BASE_TITLE_FLAG_CHAR_NUM}
        shouldAppendTitleTail=false
        while read line # 读出每一行处理
        do ## TODO 多级标题时的处理
              if [[ ${line} == \#* ]]; then # 每一Markdown标题即为一分类
                  line=`echo ${line} | tr -d '\r' | tr -d '\n'`   # 某些会带有这特殊符号导致换行，去掉。。。
                  titleFlagChar=${line%%' '*}
                  let titleFlagNum=${#titleFlagChar}

                  if [ ${titleFlagNum} == ${BASE_TITLE_FLAG_CHAR_NUM} ] && [ ${shouldAppendTitleTail} == true ]; then
                      appendToFile '</dl>'
                  fi

                  if [[ ${titleFlagNum} > ${BASE_TITLE_FLAG_CHAR_NUM} ]]; then
                      shouldAppendTitleTail=true
                  else
                      shouldAppendTitleTail=false
                  fi

                  
                  log  $titleFlagChar'-'$titleFlagNum

                      
                  isReadingSiteLine=false
                  let titleNum=titleNum+1
                  log ${line}
                  log $titleNum
                  # echo ${line#*' '} # ‘#’后的标题文字
                  appendToFile '<dt><h4>'${line#*' '}'</h4></dt>'

                  appendToFile '<dl>'
              
              elif [[ ${line} == \[* ]]; then
                  
                  isReadingSiteLine=true
                  
                  # log '网址：'${line}
                  site_name=${line#*[}
                  site_name=${site_name%%]*}
                  
                  site_href=${line#*(}
                  site_href=${site_href%)*}                 

                  # log $site_name $site_href
                  appendToFile '<dt><a href="'${site_href}'">'${site_name}'</a></dt>'
 
              else
                  
                  if [[ ${isReadingSiteLine} == true ]]; then
                      appendToFile '</dl>'
                      let titleNum=0
                      isReadingSiteLine=false
                  fi
              fi

        done < ${file}"/index.md" # 每一文件夹分类里的README具体书签内容

        appendToFile '</dl>'
    done 
}



rm -f ${OUTPUT_FILE_NAME}
touch ${OUTPUT_FILE_NAME}
generate