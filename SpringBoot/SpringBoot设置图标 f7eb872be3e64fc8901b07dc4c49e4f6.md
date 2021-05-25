# SpringBoot设置图标

```html
# 必须使用 href指定一个路径,路径可以是发送一个请求来进行获取,或者通过直接路径获取

# 方式一
<link rel="shortcut icon" th:href="${configurations.get('websiteIcon')}"/>
# 方式二
<link rel="shortcut icon" href="/admin/dist/img/favicon.ico"/>
```