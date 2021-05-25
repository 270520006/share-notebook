# 分布式Dubbo + Zookeeper+SpringBoot

## **ZooKeeper是什么**

> ZooKeeper 是一个分布式的，开放源码的分布式应用程序协调服务，是Google的Chubby一个开源的实现，是Hadoop和Hbase的重要组件。它是一个为分布式应用提供一致性服务的软件，提供的功能包括：配置维护、域名服务、分布式同步、组服务等。

## 什么是dubbo?

Apache Dubbo 是一款高性能,轻量级的JavaRPC开源框架。它提供了三大核心能力:面向接口的远程方法调用,容错和负载均衡,以及服务注册和发现。

## Dubbo运行流程:

![%E5%88%86%E5%B8%83%E5%BC%8FDubbo%20+%20Zookeeper+SpringBoot%20afc770378bd043b6b55fd7f1698b2375/Dubbo.png](%E5%88%86%E5%B8%83%E5%BC%8FDubbo%20+%20Zookeeper+SpringBoot%20afc770378bd043b6b55fd7f1698b2375/Dubbo.png)

1.服务提供者(Provider):暴露服务的服务提供方,服务提供者在启动时,先注册中心注册自己的服务。
2.服务消费者(Consumer):远程服务的服务消费方,服务消费者在启动的时候,向注册中心订阅自己所需的服务,服务消费者,从提供者地址列表中,基于软负载均衡算法,选一台提供者进行调用,如果订阅失败,再选另一台调用
3.注册中心(Registry) 注册中心返回服务提供者地址列表给消费者,如果有变更,注册中心将基于长连接推送变更数据给消费者
4.monitor(监控中心) 服务消费者和提供者,在内存中累计调用次数和调用时间,定时每分钟发送一次数据到监控中心

## 调度关系说明

> 1.服务容器负责启动,加载、运行服务提供者。
2.服务提供者在启动时,向注册中心提供自己提供的的服务。
3.消费者在启动时,向注册中心订阅自己所需的服务。
4.注册中心中心返回服务提供者地址列表给消费者,如果有变更,注册中心将基于长连接推送变更给消费者。
5.消费者,从提供者地址列表中,基于软负载均衡算法,算一台提供者进行调用,如果调用失败,再选另一台调用。
6.消费者和提供者,在内存中计算调用次数和调用时间,定时每分钟发送一次统计数据到监控中心

## 环境搭建：(导入完依赖启动项目时如果报错,请适当降低以下配置版本)

### 需要导入依赖

```xml
<!--        导入依赖,Dubbo 加 Zookeeper-->
        <!-- https://mvnrepository.com/artifact/org.apache.dubbo/dubbo-spring-boot-starter -->
        <!--        导入Dubbo的启动场景-->
        <dependency>
            <groupId>org.apache.dubbo</groupId>
            <artifactId>dubbo-spring-boot-starter</artifactId>
            <version>2.7.3</version>
        </dependency>
        <!--        导入Zookeeper 的客户端依赖,注意是GitHub上的-->
        <!-- https://mvnrepository.com/artifact/com.github.sgroschupf/zkclient -->
        <dependency>
            <groupId>com.github.sgroschupf</groupId>
            <artifactId>zkclient</artifactId>
            <version>0.1</version>
        </dependency>
        <!--        导入zookeeper服务端-->
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.14</version>
            <!--            排除Zookeeper的slf4j-log4j12-->
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.apache.curator/curator-framework -->
        <!--        引入zookeeper  管理员  zookeeper服务端依赖-->
        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-framework</artifactId>
            <version>2.12.0</version>
        </dependency>
        <!--        zookeeper服务端依赖-->
        <dependency>
            <groupId>org.apache.curator</groupId>
            <artifactId>curator-recipes</artifactId>
            <version>2.12.0</version>
        </dependency>
```

可能会遇到的问题？
可能会遇到,日志冲突的问题,会与SpringBoot的日志会有冲突问题
把Zookeeper的  slf4j排除就可以解决
如上图黄色字体

## 进行配置文件配置

1. 服务应用名称
2. 注册中心地址
3. 哪些服务要被注册
- 查看官方配置

    ```yaml
    server.port=7001
    spring.velocity.cache=false
    spring.velocity.charset=UTF-8
    spring.velocity.layout-url=/templates/default.vm
    spring.messages.fallback-to-system-locale=false
    spring.messages.basename=i18n/message
    spring.root.password=root
    spring.guest.password=guest

    dubbo.registry.address=zookeeper://127.0.0.1:2181
    ```

## 将要注册的服务放入容器中(有坑勿踩)

- 通过Component注解将要注册的服务放入容器中
- (坑)在服务层我们为什么不推荐使用Service呢,因为Dubbo也提供了一个@Service注解,我们容易选错,正确的选着是我们要选着**Dubbo的包,而不是Spring的包**

![%E5%88%86%E5%B8%83%E5%BC%8FDubbo%20+%20Zookeeper+SpringBoot%20afc770378bd043b6b55fd7f1698b2375/Untitled.png](%E5%88%86%E5%B8%83%E5%BC%8FDubbo%20+%20Zookeeper+SpringBoot%20afc770378bd043b6b55fd7f1698b2375/Untitled.png)

> 1.查看被占用的端口号:
netstat -ano|findstr "进程ID"
 
2.强制结束被禁用的进程
taskkill /f /pid 进程ID

## 当我们配置完提供者后,注册成功后,我们就可以去订阅消费了

- 我们要在消费的模块导入与Provider相同的依赖
- 相关的依赖: [https://www.notion.so/liufugui/Dubbo-Zookeeper-SpringBoot-afc770378bd043b6b55fd7f1698b2375#6e309c295f1944feb638603d974b24eb](https://www.notion.so/liufugui/Dubbo-Zookeeper-SpringBoot-afc770378bd043b6b55fd7f1698b2375#6e309c295f1944feb638603d974b24eb)
- 提供者注册过了,我们就要想办法去配置怎么去调用,去使用
- 消费者配置,我们只需要配置消费者名称和zookeeper地址就行了,需要的话我们可以自己去拿

```yaml
#从消费者那里拿服务就需要暴露自己的名称,及细信息
dubbo.application.name: consumer-server
#获取注册中心的资源地址
dubbo:
  registry:
    address: zookeeper://127.0.0.1:2181
```

- 我们该怎么去获取注册中心注册好的服务呢？可以使用***@Reference***注解来使用远程调用,他是  **import org.apache.dubbo.config.annotation.Reference;下的类,注意不要调用错了**
- 有两种方法可以进进行引用注册中心注册好的服务
    1. 使用Pom坐标来进行引用(常用)
    2. 需要在消费者这方定义相同的路径和接口名不需要实现,只需要定义即可引用远程的服务

坑:当我们使用rpc远程调用实体对象的的时候,我们需要对实体类进行序列化,不然就会报错

java.lang.IllegalStateException: Serialized class com.sky.boot.entity.VehicleRecord must implement java.io.Serializable