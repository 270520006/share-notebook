# Shiro认证

## 认证流程:

- 首先用户如果没有登录,让用户登录,使用SecurityUtils.getSubject()获取当前登录的用户
- 然后根据用户登陆的信息(username,userpassword)生成一个令牌 token
- 使用当前的subject用户的subjectUser.login(token)方法,去认证用户请求的登录信息封装的的token令牌

```java
// 获取当前登录的用户
        Subject subject = SecurityUtils.getSubject();
        //设置令牌
        UsernamePasswordToken loginUserToken = new UsernamePasswordToken(username, password);

        try {
            //登录校验
            subject.login(loginUserToken);
            return "/index";
        } catch (UnknownAccountException uae) {  // 账户不存在
            model.addAttribute("error", "无效的用户名");
            return "/user/login";
        } catch (IncorrectCredentialsException ice) { //密码错误
            model.addAttribute("error", "无效的密码");
            return "/user/login";
        }
```

- 具体的认证,通过**login**()方法交给 执行认证信息处理,将拿过来的token令牌,进行校验,最后返回认证的信息

```java
/**
     * 用于用户认证
     */
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
        System.out.println("执行了认证");
        // 模仿数据库用户信息
        String username = "root";
        String password = "root";
        // 将提交的用户令牌对象转化为用户令牌
        UsernamePasswordToken currentUserToken = (UsernamePasswordToken) authenticationToken;
        if (!username.equals(currentUserToken.getUsername())) {
            // return null;相当于抛出了 UnKnowAccountException
            return null;
        }
        // 密码不用进行校验,因为密码设计安全信息,shiro帮助我们完成了校验
        return new SimpleAuthenticationInfo("", password, "");
    }
```

# 盐值加密认证:

## 加密:

```java
String hashAlgorithmName = "MD5";//加密方式
        Object crdentials = "用户密码";//密码原值
        ByteSource salt = ByteSource.Util.bytes("加密的盐,一般使用数据库唯一值得值");//以账号作为盐值
        int hashIterations = 1024;//加密1024次
        Object result = new SimpleHash(hashAlgorithmName, crdentials, salt, hashIterations);//返回的md5盐值加密后的结果
```

## 盐值加密认证：

```java
/**
 * 用于用户认证
 */
@Override
protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
    System.out.println("执行了认证");
    // 将提交的用户令牌对象转化为用户令牌
    UsernamePasswordToken currentUserToken = (UsernamePasswordToken) authenticationToken;

    User user = userService.queryUserByName(currentUserToken.getUsername());
    if (user != null) {
        if (!user.getName().equals(currentUserToken.getUsername())) {
            // return null;相当于抛出了 UnKnowAccountException
            return null;
        }
    } else {
        return null;
    }
    // principal: 认证的实体信息. 可以是 username, 也可以是数据表对应的用户的实体类对象
    Object principal = user;
    // credentials 密码
    String credentials = user.getName();

    // realmName:当前realm对象的name,调用父类的getName()方法即可
    String realm = getName();

    // credentials 的盐值加密
    ByteSource salt = ByteSource.Util.bytes(user.getName());

    // 密码校验,使用 盐值加密方式来获取认证信息 密码校验shiro帮助我们校验
    return new SimpleAuthenticationInfo(principal, credentials, salt, realm);
}
```

1）在doGetAuthenticationInfo方法返回值创建SimpleAuthenticationInfo对象的时候，需要使用

SimpleAuthenticationInfo(principal, credentials, credentialsSalt, realmName)构造器。

2）使用ByteSource.Util.bytes()来计算盐值

3）盐值需要唯一，一般使用随机字符串或者userid

4）使用new SimpleHash(hashAlgorithmName,crdentials,salt,hashIterations)来计算盐值加密

后的密码的值。