# SpringBoot整合mybatis

## mybatis请求头

> <?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
PUBLIC "-[//mybatis.org//DTD](notion://mybatis.org//DTD) Mapper 3.0//EN"
"[http://mybatis.org/dtd/mybatis-3-mapper.dtd](http://mybatis.org/dtd/mybatis-3-mapper.dtd)">

- 引入mybatis提供的 start 启动场景

```xml
<!-- https://mvnrepository.com/artifact/org.mybatis.spring.boot/mybatis-spring-boot-starter -->
<!--        导入Mybatis启动场景依赖-->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.3</version>
</dependency>
```

- @Mapper注解的作用标注了这是一个mybatis的mapper的接口,除了@Mapper注解还可以启动类上标注@MapperScan注解配置指定mapper接口所在位置的包,并自动扫描
- application.yml配置 mybatis配置文件生效

```yaml
#  配置加载mapper映射文件
mapper-locations: classpath:mybatis/mappers/*.xml
#配置mybatis  alias别名
type-aliases-package: com.sky.idea.entity
#  配置mybatis主核心配置文件
  config-location: classpath:mybatis/mybatis-config.xml
```