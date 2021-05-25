# SpringBoot集成Redis

## 整合测试:

- 导入依赖
- 配置连接
- 测试

```xml
<!--引入Redis应用场景-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

## Spring操作数据：

- 使用SpringData操作数据,JPA,JDBC,mongoDB  Redis
- SpringData是和SpringBoot齐名的项目

在SpringBoot 2.x之后Redis  操作数据由原来的Jedis被替换成了Lettuce
使用jedis操作数据,采用直连,多线程操作数据是不安全的,如果想要避免安全问题,就要使用Jedis的pool连接池来解决 更像BIO模式

![SpringBoot%E9%9B%86%E6%88%90Redis%201623d5f7b36447ed942f86f47a0514d7/Untitled.png](SpringBoot%E9%9B%86%E6%88%90Redis%201623d5f7b36447ed942f86f47a0514d7/Untitled.png)

## 使用Lettuce:

- 底层采用netty高性能网络框架,异步请求,dubbo低沉也使用了
- 实例可以在多个线程中共享
- 不存在线程不安全问题,可以减少线程数据了,更像NIO模式

![SpringBoot%E9%9B%86%E6%88%90Redis%201623d5f7b36447ed942f86f47a0514d7/Untitled%201.png](SpringBoot%E9%9B%86%E6%88%90Redis%201623d5f7b36447ed942f86f47a0514d7/Untitled%201.png)

## 整个Spring里面给我们封装了大量的XXXTemplate供我们使用他们的封装好的方法

- Redis的Template

```java
@Bean
	//redis提供的 RedisTemplate,要想使用这个需要符合它下面的条件,只有没有配置RedisTemplate的时候我们就可以使用它封装好的,这个告述我们,我们还可以自定义template来使用
	@ConditionalOnMissingBean(name = "redisTemplate")
	//要想使用这个Template我们就需要连接工厂来初始化template,通过连接工厂接口,我们得知,有两个类实现了这个接口 1.JedisConnetionFactory 2.LettuceConnetionFactory 它们分别实现了这个接口我们都可以使用它
	public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory)
			throws UnknownHostException {
		//默认的RedisTemplate,没有过多的设置,Redis对象都是需要序列化的!如:Dubbo对象的实体类必须实例化
		//两个泛型都是Object类型,使用后我们都需要进行强制转换
		RedisTemplate<Object, Object> template = new RedisTemplate<>();
		template.setConnectionFactory(redisConnectionFactory);
		return template;
	}

	@Bean
	@ConditionalOnMissingBean
	//由于我们的String类型比较常用,所以单独为我们提出来一个Bean
	public StringRedisTemplate stringRedisTemplate(RedisConnectionFactory redisConnectionFactory)
			throws UnknownHostException {
		StringRedisTemplate template = new StringRedisTemplate();
		template.setConnectionFactory(redisConnectionFactory);
		return template;
	}
```

## 连接Redis配置文件

```java
spring.redis.host=192.168.230.139
spring.redis.port=6379
```

我们还可以使用Redis的连接池,来提升线程安全,但是在springboot 2.x之后我们可以使用Lettuce的连接池 ,为什么呢?因为JedisConnecionFactory中有很多的类不生效,所有导致很多无法使用,但是在lettuce中他全部引用,生效,所有可以全部使用

## 获取连接对象

```java
RedisConnection connection = redisTemplate.getConnectionFactory().getConnection();
```

## 自定义配置类

```java
package com.sky.boot.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.RedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * @author Administrator
 */
@Configuration
public class RedisConfig {

    @Bean(name = "redisTemplate")
    public RedisTemplate<String, Object> getRedisTemplate(RedisConnectionFactory redisConnectionFactory) {
        // 初始化配置RedisTemplate模板  为了开发方便我们一般使用<String,Object>类型
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        // 设置redisTemplate连接工程
        template.setConnectionFactory(redisConnectionFactory);

        // 初始化String类型初始化对象
        RedisSerializer<String> redisSerializer = new StringRedisSerializer();

        // Key设置String类型的序列化方式
        template.setKeySerializer(redisSerializer);
        // Hash Key设置 String类型的序列号方式
        template.setHashKeySerializer(redisSerializer);

        // value值设置String序列化方式
        template.setValueSerializer(redisSerializer);
        // HashValue值设置String序列化方式
        template.setHashValueSerializer(redisSerializer);

        template.afterPropertiesSet();
        return template;
    }
}package com.sky.boot.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.RedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * @author Administrator
 */
@Configuration
public class RedisConfig {

    @Bean(name = "redisTemplate")
    public RedisTemplate<String, Object> getRedisTemplate(RedisConnectionFactory redisConnectionFactory) {
        // 初始化配置RedisTemplate模板  为了开发方便我们一般使用<String,Object>类型
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        // 设置redisTemplate连接工程
        template.setConnectionFactory(redisConnectionFactory);

        // 初始化String类型初始化对象
        RedisSerializer<String> redisSerializer = new StringRedisSerializer();

        // Key设置String类型的序列化方式
        template.setKeySerializer(redisSerializer);
        // Hash Key设置 String类型的序列号方式
        template.setHashKeySerializer(redisSerializer);

        // value值设置String序列化方式
        template.setValueSerializer(redisSerializer);
        // HashValue值设置String序列化方式
        template.setHashValueSerializer(redisSerializer);

        template.afterPropertiesSet();
        return template;
    }
}
```

[工具类](SpringBoot%E9%9B%86%E6%88%90Redis%201623d5f7b36447ed942f86f47a0514d7/%E5%B7%A5%E5%85%B7%E7%B1%BB%20f24839112ccf4da2b177e515514350cf.md)