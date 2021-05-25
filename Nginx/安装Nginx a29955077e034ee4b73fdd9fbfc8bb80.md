# 安装Nginx

### nginx可以部署在window或Linux中,推荐安装到Linux中,发挥它的最大性能

## 安装过程

- 先去Nginx官网  [http://nginx.org/](http://nginx.org/en/download.html) 找到要下载的版本
    - 下载安装Nginx需要依赖素材  1.prce-8.37.tar.gz  2.openssl-1.0.1t.tar.gz  3. zlib-1.2.8.tar.gz
        - 依赖素材图片

            ![%E5%AE%89%E8%A3%85Nginx%20a29955077e034ee4b73fdd9fbfc8bb80/Untitled.png](%E5%AE%89%E8%A3%85Nginx%20a29955077e034ee4b73fdd9fbfc8bb80/Untitled.png)

        - 安装Pcre wget [`http://downloads.sourceforge.net/project/pcre/pcre/8.3.7/pcre-8.37.tar.gz`](https://sourceforge.net/projects/pcre/files/pcre/8.44/pcre-8.44.tar.gz/)
            - 解压文件, tar -zxvf 压缩包名称
            - 再执行  ./configure执行完成后  回到  Prce目录下执行  make && make install

            如果出现  **configure: error: You need a C++ compiler for C++ support.这样的提示
            安装一下这个即可：`yum install -y gcc gcc-c++`**

            - make完成后 可以查看pcrl的版本  pcre-config --version安装完成
        - **或者直接通过命令安装pcre  `yum install pcre-devel`**
        - 安装openSSL  和  zlib
            - 我们可以使用  `yum -y install make zlib zlib-devel gcc-c++ libtool opensll openssl-devle`

        ## 安装完以上依赖后,我们去安装Nginx

        - 将Nginx安装包放到Linux系统中
        - 解压安装包,进入解压目录先执行 ./configure 再执行 make && make install 命令
        - 安装完成之后我们可以在  /usr/local中看到里面会生成一个nginx文件  我们可以进去这个nginx文件夹里面的sbin的启动Nginx 的脚本
        - 修改Nginx访问端口号  在 /usr/local/nginx/conf/nginx.conf  里面的listen监听端口那里去修改端口号