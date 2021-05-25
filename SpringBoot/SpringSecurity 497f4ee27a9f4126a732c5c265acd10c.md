# SpringSecurity

## 使用:

```xml
<!--        导入security 应用启动环境-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
```

web开发中安全是非常重要的,要防止用户的信息泄露,防止漏洞

是否为功能性需求 否

做网站:安全应该在设计之初开始考虑

- 如果后期修改需要改动大量代码

## shiro、springSecurity，很相像,除了类不一样,名字不一样,用途为:

authentication :认证    authorization:授权

- springSecurity是**链式编程**

## springsecurity简介

> SpringSecurity是针对spring项目的安全框架,也是springBoot底层安全默认模块的技术选型它可以实现强大的web安全控制,对于安全控制我们仅需要引入 spring-boot-start-security模块,进行少量配置,就能实现安全的安全管理功能

## security主要的,需要记住的类

1. WebSecurityConfigurerAdapter: 自定义Security 策略
2. AuthenticationManagerBuilder:自定义认证策略
3. @EnableWebSecurity 开启Security 模式  以后遇到 @EnableXxx就是开启某个功能

## 认证和授权在任何安全框架里面是通用的,不仅仅在security中存在

# 实现springSecurity的授权和认证功能

- 要想实现springSecurity的授权和认证功能需要继承**WebSecurityConfigurerAdapter**类
- **WebSecurityConfigurerAdapter** 类中有很多的方法如果要实现**授权**(authorization)的功能的需要实现父类的重载Configure(**HttpSecurity** http)方法

```java
@Override
    protected void configure(HttpSecurity http) throws Exception {
        //设置所有人都可以访问
        http.authorizeRequests().antMatchers("/").permitAll()
//                添加路径匹配器只有vip1可以访问
                .antMatchers("/level1/**").hasRole("vip1")
//        添加路径匹配器只有vip2可以访问
                .antMatchers("/level2/**").hasRole("vip2")
//        添加路径匹配器只有vip3可以访问
                .antMatchers("/level3/**").hasRole("vip3");

        //开启登录授权功能  loginPage() 填写用户信息的页面    loginProcessingUrl()具体处理用户信息
        http.formLogin().loginPage("/toLogin").loginProcessingUrl("/login");

        //开启注销功能  logout注销  deleteCookie删除 cookie  invalidateHttpSession()是否清空session true为清空,false 反之,logoutSuccessUrl()登出成功跳转到的页面
        http.logout().deleteCookies("remove").invalidateHttpSession(false).logoutSuccessUrl("/");
    }
```

- 如果要实现**认证**(authentication)的话也需要实现父类的重载方法 Configurer(**AuthenticationManagerBuilder** auth)

```java
@Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
//        inMemoryAuthentication  是在对内存中权限用户镜像判定  passwordEncoder 密码编码器用来加密,不加密的话版本可能不支持,使用 BCryptPasswordEncoder加密密码
        auth.inMemoryAuthentication().passwordEncoder(new BCryptPasswordEncoder())
                // withUser 内存中用户名   password 内存中的密码  roles 角色认证的类型,也就是对应的角色,可以访问页面的权限  and()方法用来拼接添加多内存用户实现不同用户权限
                .withUser("root").password(new BCryptPasswordEncoder().encode("root")).roles("vip1", "vip2", "vip3").and()
                .withUser("刘富贵").password(new BCryptPasswordEncoder().encode("liufugui")).roles("vip2", "vip3").and()
                .withUser("guests").password(new BCryptPasswordEncoder().encode("guests")).roles("vip1");
//使用数据库的用户信息进行授权
        auth.jdbcAuthentication();
    }
```

## 没有登录跳转到登录页面

```java
//开启登录授权功能
        http.formLogin();
```

## 注销功能使用

```java
//开启注销功能  logout注销  deleteCookie删除 cookie  invalidateHttpSession()是否清空session true为清空,false 反之,logoutSuccessUrl()登出成功跳转到的页面
        http.logout().deleteCookies("remove").invalidateHttpSession(false).logoutSuccessUrl("/");
```

## SpringSecurity 与 thymeleaf 整合需要一个整合包

```xml
<!--       导入Thymeleaf和SpringSecurity整合包可以在Thymeleaf模板引擎中使用security的东西-->
<!-- https://mvnrepository.com/artifact/org.thymeleaf.extras/thymeleaf-extras-springsecurity4 -->
<dependency>
    <groupId>org.thymeleaf.extras</groupId>
    <artifactId>thymeleaf-extras-springsecurity4</artifactId>
    <version>3.0.4.RELEASE</version>
</dependency>
```

如果SpringBoot版本大于2.0.9可能会不支持Thymeleaf 与 SpringSecurity整合的包,显示不出来

除了导入它们之间的整合包还需要在 thymeleaf中使用 security的信息需要在 thymeleaf中引入命名空间

```html
xmlns:sec="http://www.thymeleaf.org/thymeleaf-extras-springsecurity4"
```

引入命名空间之后就可以使用 sec 标签了:

有很多的标签供我们使用:

- sec:authorize="xxx"  来显示授权的信息
- sec:authentication="xxx" 使用来显示认证信息

## 开启记住我功能

```java
//        开启记住我功能   rememberMeParameter() 自定义记住我保存信息到cookie中,参数与表单name属性一直
        http.rememberMe().rememberMeParameter("rememberMe");
```

## 关闭csrf站点攻击功能

```java
//关闭csrf防攻击功能
        http.csrf().disable();
```