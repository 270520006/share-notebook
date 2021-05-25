# Nginx的坑

## nginx上传大小限制  request entry too large

413 请求体过大   

解决方案

在nginx http快配置文件大小添加设置

client max body size 1024m;