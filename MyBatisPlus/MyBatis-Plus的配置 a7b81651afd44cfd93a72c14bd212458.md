# MyBatis-Plus的配置

## 开启sql打印输出信息

### properties配置

```bash
mybatis-plus.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl
```

### yml配置

```yaml
mybatis-plus:
  config-location: classpath:mybatis/mybatis-config.xml
  mapper-locations: classpath:mybatis/mappers/*.xml
		# 开启sql语句日志打印
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```