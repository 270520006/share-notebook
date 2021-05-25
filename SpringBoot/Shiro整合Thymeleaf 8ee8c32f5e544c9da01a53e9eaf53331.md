# Shiro整合Thymeleaf

导入整合包:

```xml
				<!--        thymeleaf整合 shiro-->
        <!-- https://mvnrepository.com/artifact/com.github.theborakompanioni/thymeleaf-extras-shiro -->
        <dependency>
            <groupId>com.github.theborakompanioni</groupId>
            <artifactId>thymeleaf-extras-shiro</artifactId>
            <version>2.0.0</version>
        </dependency>
```

## 注入shiro方言

```java
// 引入shiro方言
@Bean
public ShiroDialect getShiroDialect() {
    return new ShiroDialect();
}
```

## 导入命名空间

```html
xmlns:shiro="http://www.thymeleaf.org/thymeleaf-extras-shiro"
```

## 判断是否有没有指定权限的方法

```haskell
shiro:hasPermission="指定权限(例如  'user:add')"
```

## 可以通过shiro的session来判断用户信息,此session并非httpSession

```haskell
th:if="${session.user!=null}"
```