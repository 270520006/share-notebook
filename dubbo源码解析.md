# dubbo源码

​	这里的dubbo源码是基于dubbo2.6.2的，用其他版本可能会有所不同，请注意！尤其dubbo3.0和2.0的差别很大，请注意！特别注意，这里的进入方法就是：ctrl+鼠标左键。

​	源码下载传送门：https://github.com/apache/dubbo/archive/refs/tags/dubbo-2.6.3.zip

## 模块介绍

​	因为模块较多，为了对dubbo有个整体概念，这里先看一眼每个模块的作用再开始深入：

### 注册中心模块(dubbo-registy)

官方文档的解释：基于注册中心下发地址的集群方式，以及对各种注册中心的抽象。

我的理解是：dubbo的注册中心实现有Multicast注册中心、Zookeeper注册中心、Redis注册中心、Simple注册中心（具体怎么实现我在后面文章中会介绍），这个模块就是封装了dubbo所支持的注册中心的实现。

* dubbo-registry-api：抽象了注册中心的注册和发现，实现了一些公用的方法，让子类只关注部分关键方法。
* 以下四个包是分别是四种注册中心实现方法的封装，其中dubbo-registry-default就是官方文档里面的Simple注册中心。

![image-20211110095632765](dubbo源码解析/image-20211110095632765.png)

### 集群模块(dubbo-cluster)

​	官方文档的解释：将多个服务提供方伪装为一个提供方，包括：负载均衡, 容错，路由等，集群的地址列表可以是静态配置的，也可以是由注册中心下发。

​	我的理解：它就是一个解决出错情况采用的策略，这个模块里面封装了多种策略的实现方法，并且也支持自己扩展集群容错策略，cluster把多个Invoker伪装成一个Invoker，并且在伪装过程中加入了容错逻辑，失败了，重试下一个。

![cluster流程图](dubbo源码解析/bV8Kih.jpeg)

查看cluster的目录结构：

* configurator包：配置包，dubbo的基本设计原则是采用URL作为配置信息的统一格式，所有拓展点都通过传递URL携带配置信息，这个包就是用来根据统一的配置规则生成配置信息。
* directory包：Directory 代表了多个 Invoker，并且它的值会随着注册中心的服务变更推送而变化 。这里介绍一下Invoker，Invoker是Provider的一个调用Service的抽象，Invoker封装了Provider地址以及Service接口信息。
* loadbalance包：封装了负载均衡的实现，负责利用负载均衡算法从多个Invoker中选出具体的一个Invoker用于此次的调用，如果调用失败，则需要重新选择。
* merger包：封装了合并返回结果，分组聚合到方法，支持多种数据结构类型。
* router包：封装了路由规则的实现，路由规则决定了一次dubbo服务调用的目标服务器，路由规则分两种：条件路由规则和脚本路由规则，并且支持可拓展。
* support包：封装了各类Invoker和cluster，包括集群容错模式和分组聚合的cluster以及相关的Invoker。

![image-20211110101040454](dubbo源码解析/image-20211110101040454.png)

### 公共逻辑模块（dubbo-common）

官方文档的解释：包括 Util 类和通用模型。

我的理解：这个应该很通俗易懂，工具类就是一些公用的方法，通用模型就是贯穿整个项目的统一格式的模型，比如URL，上述就提到了URL贯穿了整个项目。

### 配置模块（dubbo-config）

官方文档的解释：是 Dubbo 对外的 API，用户通过 Config 使用Dubbo，隐藏 Dubbo 所有细节。

我的理解：用户都是使用配置来使用dubbo，dubbo也提供了四种配置方式，包括XML配置、属性配置、API配置、注解配置，配置模块就是实现了这四种配置的功能。

* dubbo-config-api：实现了API配置和属性配置的功能。
* dubbo-config-spring：实现了XML配置和注解配置的功能。

![dubbo-config](dubbo源码解析/bVbioKd.png)

	###  远程调用模块（dubbo-rpc）

官方文档的解释：抽象各种协议，以及动态代理，只包含一对一的调用，不关心集群的管理。

我的理解：远程调用，最主要的肯定是协议，dubbo提供了许许多多的协议实现，不过官方推荐时使用dubbo自己的协议。

* dubbo-rpc-api：抽象了动态代理和各类协议，实现一对一的调用
* 另外的包都是各个协议的实现。

### 远程通信模块（dubbo-remoting）

官方文档的解释：相当于 Dubbo 协议的实现，如果 RPC 用 RMI协议则不需要使用此包。

我的理解：提供了多种客户端和服务端通信功能，比如基于Grizzly、Netty、Tomcat等等，RPC用除了RMI的协议都要用到此模块。

* dubbo-remoting-api：定义了客户端和服务端的接口。
* dubbo-remoting-grizzly：基于Grizzly实现的Client和Server。
* dubbo-remoting-http：基于Jetty或Tomcat实现的Client和Server。
* dubbo-remoting-mina：基于Mina实现的Client和Server。
* dubbo-remoting-netty：基于Netty3实现的Client和Server。
* Dubbo-remoting-netty4：基于Netty4实现的Client和Server。
* dubbo-remoting-p2p：P2P服务器，注册中心multicast中会用到这个服务器使用。
* dubbo-remoting-zookeeper：封装了Zookeeper Client ，和 Zookeeper Server 通信。

![image-20211110110949313](dubbo源码解析/image-20211110110949313.png)

### 容器模块（dubbo-container）

​	官方文档的解释：是一个 Standlone 的容器，以简单的 Main 加载 Spring 启动，因为服务通常不需要 Tomcat/JBoss 等 Web 容器的特性，没必要用 Web 容器去加载服务。

​	我的理解：因为后台服务不需要Tomcat/JBoss 等 Web 容器的功能，不需要用这些厚实的容器去加载服务提供方，既资源浪费，又增加复杂度。服务容器只是一个简单的Main方法，加载一些内置的容器，也支持扩展容器。

* dubbo-container-api：定义了Container接口，实现了服务加载的Main方法。
* 其他三个分别提供了对应的容器，供Main方法加载。

![dubbo-container](dubbo源码解析/bVbioLV.png)

### 监控模块(dubbo-monitor)

官方文档的解释：统计服务调用次数，调用时间的，调用链跟踪的服务。

我的理解：这个模块很清楚，就是对服务的监控。

* dubbo-monitor-api：定义了monitor相关的接口，实现了监控所需要的过滤器。
* dubbo-monitor-default：实现了dubbo监控相关的功能。

![dubbo-monitor](dubbo源码解析/bVbioL3.png)

### 清理模块(dubbo-bootstrap)

​	这个模块只有一个类，是作为dubbo的引导类，并且在停止期间进行清理资源。具体的介绍我在后续文章中讲解。

### 示例模块(dubbo-demo)

​	这个模块是快速启动示例，其中包含了服务提供方和调用方，注册中心用的是multicast，用XML配置方法，后续我们介绍源码将从这个模块起来举例。

### 过滤器模块(dubbo-filter)

​	这个模块提供了内置的一些过滤器：

* dubbo-filter-cache：提供缓存过滤器。
* dubbo-filter-validation：提供参数验证过滤器。

![dubbo-filter](dubbo源码解析/bVbioMA.png)

### 插件模块(dubbo-plugin)

​	提供了内置的插件：

* dubbo-qos：提供了在线运维的命令。

![dubbo-plugin](dubbo源码解析/bVbioMI.png)

### 序列化模块

​	该模块中封装了各类序列化框架的支持实现：

* dubbo-serialization-api：定义了Serialization的接口以及数据输入输出的接口。
* 其他的包都是实现了对应的序列化框架的方法。dubbo内置的就是这几类的序列化框架，序列化也支持扩展。

![dubbo-serialization](dubbo源码解析/bVbioMO.png)

### 测试模块(dubbo-test)

这个模块封装了针对dubbo的性能测试、兼容性测试等功能。

* dubbo-test-benchmark：对性能的测试。
* dubbo-test-compatibility：对兼容性的测试，对spring3对兼容性测试。
* dubbo-test-examples：测试所使用的示例。
* dubbo-test-integration：测试所需的pom文件

![dubbo-test](dubbo源码解析/bVbioMS.png)

## dubbo源码解析（一）

### 标签解析和bean的初始化

* 首先找到程序入口，在dubbo-demo下的dubbo-demo-consumer中的consumer文件中：

![image-20211105163013383](dubbo源码解析/image-20211105163013383.png)

​	进入查看代码发现依赖了一个配置类，META-INF/spring/dubbo-demo-consumer.xml。

```java
    public static void main(String[] args) {
        //Prevent to get IPV6 address,this way only work in debug mode
        //But you can pass use -Djava.net.preferIPv4Stack=true,then it work well whether in debug mode or not
        System.setProperty("java.net.preferIPv4Stack", "true");
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext(new String[]{"META-INF/spring/dubbo-demo-consumer.xml"});
        context.start();
        DemoService demoService = (DemoService) context.getBean("demoService"); // get remote service proxy

        while (true) {
            try {
                Thread.sleep(1000);
                String hello = demoService.sayHello("world"); // call remote method
                System.out.println(hello); // get result

            } catch (Throwable throwable) {
                throwable.printStackTrace();
            }
        }
    }
```

* 追踪META-INF/spring/dubbo-demo-consumer.xml这个配置类，我们发现它引用的xsd文件包括spring的**spring-beans-4.3.xsd文件和dubbo.xsd，dubbo.xsd文件定义了xml文件的解析规则**。 例如看dubbo: reference，在xsd文件中可以看到reference对应的配置，对应ReferenceConfig类。**所以我们现在要追踪的是：
  * dubbo.xsd

```xml
<beans xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://dubbo.apache.org/schema/dubbo"
       xmlns="http://www.springframework.org/schema/beans"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.3.xsd
       http://dubbo.apache.org/schema/dubbo http://dubbo.apache.org/schema/dubbo/dubbo.xsd">

    <!-- consumer's application name, used for tracing dependency relationship (not a matching criterion),
    don't set it same as provider -->
    <dubbo:application name="dub-consumer"/>

    <!-- use multicast registry center to discover service -->
    <dubbo:registry address="multicast://224.5.6.7:1234"/>

    <!-- generate proxy for the remote service, then demoService can be used in the same way as the
    local regular interface -->
    <dubbo:reference id="demoService" check="false" interface="com.alibaba.dubbo.demo.DemoService"/>
</beans>
```

* ctrl+鼠标左键进入到dubbo.xsd，这里主要查看

  * service
  * reference

  注：这里的\<xsd:annotation>使用DubboBeanDefinitionParser方法转译成的bean，所以看不懂，往下看即可。

```xml
    <xsd:element name="service" type="serviceType">
        <xsd:annotation>
            <xsd:documentation><![CDATA[ Export service config ]]></xsd:documentation>
        </xsd:annotation>
    </xsd:element>

    <xsd:element name="reference" type="referenceType">
        <xsd:annotation>
            <xsd:documentation><![CDATA[ Reference service config ]]></xsd:documentation>
        </xsd:annotation>
    </xsd:element>
```

* 找到dubbo.xsd的上级目录下的spring.handles：
  * 因为handles这里配置了DubboNamespaceHandler，进入这个类查看：可以发现这个类使用了DubboBeanDefinitionParser帮我们解析上面的标签,并且自定义了ServiceBean和ReferenceBean。

```properties
http\://dubbo.apache.org/schema/dubbo=com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler
http\://code.alibabatech.com/schema/dubbo=com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler	
```

内部机制都是依托于<dubbo:annotation />标签。 通过源码分析，Dubbo对于Spring xml解析处理由      com.alibaba.dubbo.config.spring.schema.DubboNamespaceHandler提供：DubboNamespaceHandler.java

```java
public class DubboNamespaceHandler extends NamespaceHandlerSupport {

    static {
        Version.checkDuplicate(DubboNamespaceHandler.class);
    }	
    @Override
    public void init() {
        registerBeanDefinitionParser("application", new DubboBeanDefinitionParser(ApplicationConfig.class, true));
        registerBeanDefinitionParser("module", new DubboBeanDefinitionParser(ModuleConfig.class, true));
        registerBeanDefinitionParser("registry", new DubboBeanDefinitionParser(RegistryConfig.class, true));
        registerBeanDefinitionParser("monitor", new DubboBeanDefinitionParser(MonitorConfig.class, true));
        registerBeanDefinitionParser("provider", new DubboBeanDefinitionParser(ProviderConfig.class, true));
        registerBeanDefinitionParser("consumer", new DubboBeanDefinitionParser(ConsumerConfig.class, true));
        registerBeanDefinitionParser("protocol", new DubboBeanDefinitionParser(ProtocolConfig.class, true));
        registerBeanDefinitionParser("service", new DubboBeanDefinitionParser(ServiceBean.class, true));
        registerBeanDefinitionParser("reference", new DubboBeanDefinitionParser(ReferenceBean.class, false));
        registerBeanDefinitionParser("annotation", new AnnotationBeanDefinitionParser());
    }
}
```

* 这里不急着看DubboBeanDefinitionParser，我们先来看一下registerBeanDefinitionParser这个类所需的元素，可以得到两个信息
  * elementName：传入元素名
  * BeanDefinitionParser：传入解析后的bean

  从这里我们可以看出DubboBeanDefinitionParser最终是返回了一个BeanDefinitionParser的类或者子类出来：

```java
    protected final void registerBeanDefinitionParser(String elementName, BeanDefinitionParser parser) {
        this.parsers.put(elementName, parser);
    }
```

* 点击进入DubboBeanDefinitionParser，可以发现：
  * DubboBeanDefinitionParser是一个构造函数，会根据传入的beanclass和required
    * beanclass：要被解析成的配置类（或者叫做，空的实体类）
    * required：是否进行解析
  * pares方法调用了内部方法parse，介绍一下传入参数：
    * element：表示 HTML 或 XML 文档中的元素。 元素可能有与之关联的属性
    * beanclass：要被解析成的配置类（或者叫做，空的实体类）
    * required：是否进行解析

```java
    public DubboBeanDefinitionParser(Class<?> beanClass, boolean required) {
        this.beanClass = beanClass;
        this.required = required;
    }
    public BeanDefinition parse(Element element, ParserContext parserContext) {
        return parse(element, parserContext, beanClass, required);
    }
```

* 下面跟进parse方法，查看发生了什么：
  * 解释一下传入参数
    * element：表示 HTML 或 XML 文档中的元素。 元素可能有与之关联的属性
    * parserContext：解析外部命名空间的bean，所需要用到的类。
    * beanClass：要被解析成的配置类（或者叫做，空的实体类）
    * required：如果id为空，则进行解析，解析成xml里的name、interface、或者bean的名字

```java
    @SuppressWarnings("unchecked")
    private static BeanDefinition parse(Element element, ParserContext parserContext, Class<?> beanClass, boolean required) {
        //创建一个RootBeanDefinition,作为要返回的类
        RootBeanDefinition beanDefinition = new RootBeanDefinition();
        //把我们需要注入的beanclass放入
        beanDefinition.setBeanClass(beanClass);
        //不设置懒加载
        beanDefinition.setLazyInit(false);
        //从xml里面获取id
        String id = element.getAttribute("id");//(*)
        //未获取到id或id为空，且是否需要解析为需要
        if ((id == null || id.length() == 0) && required) {
            //进行id的解析，根据结点属性解析成xml的标签属性或处理结点名#
            //从xml里获取bean的name
            String generatedBeanName = element.getAttribute("name");
            if (generatedBeanName == null || generatedBeanName.length() == 0) {
                //若为protocol处理结点，且name为空，则默认为  "dubbo"
                if (ProtocolConfig.class.equals(beanClass)) {
                    generatedBeanName = "dubbo";
                } else {
                //如果是普通结点则为其配置成interface的值
                    generatedBeanName = element.getAttribute("interface");
                }
            }
            if (generatedBeanName == null || generatedBeanName.length() == 0) {
                //如果id不为空，但generatedBeanName为空，则设置成对应的class名字
                generatedBeanName = beanClass.getName();
            }
            id = generatedBeanName;//将id改为置入的bean名(*)
            int counter = 2; //初始化counter为2
            while (parserContext.getRegistry().containsBeanDefinition(id)) {
                //为防止出现id重复，从parserContext中获取bean
                // 判断是否重复，重复则将generatedBeanName和counter进行拼串
                //重复则进行循环拼串，拼到不重复为止
                id = generatedBeanName + (counter++);//进行一个拼串(*)
            }
        }
        if (id != null && id.length() > 0) {//将id写入容器中
            //由于传入的required为true，所以这个位置必定会进入#
            //判断传入的id是否包含在parserContext中
            //包含则抛出异常
            if (parserContext.getRegistry().containsBeanDefinition(id)) {
                throw new IllegalStateException("Duplicate spring bean id " + id);
            }
            //注册id-beandefinetion到容器中
            parserContext.getRegistry().registerBeanDefinition(id, beanDefinition);
            //向我们要返回的beanDefinition传入id,前面一切的目的都是为了这一步，向里面放入id(*)
            beanDefinition.getPropertyValues().addPropertyValue("id", id);
        }
        // <dubbo:protocol/>标签处理
        if (ProtocolConfig.class.equals(beanClass)) { //如果是为protocol处理结点
            for (String name : parserContext.getRegistry().getBeanDefinitionNames()) {//迭代获取bean的名字
                BeanDefinition definition = parserContext.getRegistry().getBeanDefinition(name);//从拿到的名字里获取bean
                PropertyValue property = definition.getPropertyValues().getPropertyValue("protocol");//获取protocol处理结点
                if (property != null) {//如果结点不为空
                    Object value = property.getValue();//从处理结点中获取对象
                    if (value instanceof ProtocolConfig && id.equals(((ProtocolConfig) value).getName())) {
                        //如果value是ProtocolConfig的实体类或者子类，并且id的值和ProtocolConfig的妹子相同
                        //获取知识点：instanceof，表示左边的是否为右边的实体类或子类
                        //则为其添加对当前bean id的依赖
                        definition.getPropertyValues().addPropertyValue("protocol", new RuntimeBeanReference(id));
                    }
                }
            }
            // <dubbo:service/>标签
        } else if (ServiceBean.class.equals(beanClass)) {//如果是service
            //从标签中获取bean
            String className = element.getAttribute("class");
            //如果存在这个bean
            if (className != null && className.length() > 0) {
                // 构建配置的class的BeanDefinition
                RootBeanDefinition classDefinition = new RootBeanDefinition();
                // 设置beanClass
                classDefinition.setBeanClass(ReflectUtils.forName(className));
                //不设置懒加载
                classDefinition.setLazyInit(false);
                //解析<property/>子标签
                parseProperties(element.getChildNodes(), classDefinition);
                //添加ServiceBean ref属性的依赖
                beanDefinition.getPropertyValues().addPropertyValue("ref", new BeanDefinitionHolder(classDefinition, id + "Impl"));
            }
            // <dubbo:provider/>标签
        } else if (ProviderConfig.class.equals(beanClass)) {
            //解析嵌套元素,parseNested方法后面会讲。
            parseNested(element, parserContext, ServiceBean.class, true, "service", "provider", id, beanDefinition);
            // <dubbo:consumer/>标签
        } else if (ConsumerConfig.class.equals(beanClass)) {
            //解析嵌套元素
            parseNested(element, parserContext, ReferenceBean.class, false, "reference", "consumer", id, beanDefinition);
        }
        Set<String> props = new HashSet<String>();//初始化一个hashset名为props
        ManagedMap parameters = null;//初始化一个Managedmap
        for (Method setter : beanClass.getMethods()) {//遍历beanclass的方法
            String name = setter.getName();//获取方法名
            //判断是否是public的有参数的setter方法
            if (name.length() > 3 && name.startsWith("set")
                    && Modifier.isPublic(setter.getModifiers())
                    && setter.getParameterTypes().length == 1) {
                //获取参数类型
                Class<?> type = setter.getParameterTypes()[0];
                // 将驼峰命名去除改成由-连接，如setApplicationContext --> application-context
                String property = StringUtils.camelToSplitName(name.substring(3, 4).toLowerCase() + name.substring(4), "-");
                //加入我们定义的hashset中
                props.add(property);

                Method getter = null;//初始化一个方法命名为getter方法
                try {
                    //获取以get开头的方法
                    getter = beanClass.getMethod("get" + name.substring(3), new Class<?>[0]);
                } catch (NoSuchMethodException e) { //捕获没有这个方法的异常
                    try {
                        //获取以is开头的方法
                        getter = beanClass.getMethod("is" + name.substring(3), new Class<?>[0]);
                    } catch (NoSuchMethodException e2) {//捕获没有这个方法的异常
                    }
                }
                //如果获取方法为空，或者方法不为公共，又或者setter方法的类型和getter方法返回类型不同，则退出循环
                // 注:type是setter方法的传入参数类型
                if (getter == null
                        || !Modifier.isPublic(getter.getModifiers())
                        || !type.equals(getter.getReturnType())) {
                    continue;
                }
                if ("parameters".equals(property)) {
                    /* parameters属性解析 */
                    parameters = parseParameters(element.getChildNodes(), beanDefinition);
                } else if ("methods".equals(property)) {
                    /* methods属性解析 */
                    parseMethods(id, element.getChildNodes(), beanDefinition, parserContext);
                } else if ("arguments".equals(property)) {
                    /* arguments属性解析 */
                    parseArguments(id, element.getChildNodes(), beanDefinition, parserContext);
                } else {
                    //如果都不是，则从标签里获取标签名为property的值
                    String value = element.getAttribute(property);
                    if (value != null) {
                    //值不为空，则去除值的头部和尾部的空字符
                        value = value.trim();
                        if (value.length() > 0) { //如果字符长度大于1
                            //如果property的值是registry，并且忽略大小写它的值是为N/A
                            if ("registry".equals(property) && RegistryConfig.NO_AVAILABLE.equalsIgnoreCase(value)) {
                                RegistryConfig registryConfig = new RegistryConfig();
                                //创建registryConfig，将其地址设置为N/A
                                registryConfig.setAddress(RegistryConfig.NO_AVAILABLE);
                                //将registryConfig设置进要返回的beanDefinition中
                                beanDefinition.getPropertyValues().addPropertyValue(property, registryConfig);
                                //如果property不为registry，且不含有','
                            } else if ("registry".equals(property) && value.indexOf(',') != -1) {
                                //遍历设置成registries，也可以跟进查看一下parseMultiRef方法
                                parseMultiRef("registries", value, beanDefinition, parserContext);
                            } else if ("provider".equals(property) && value.indexOf(',') != -1) {
                                //遍历设置成providers
                                parseMultiRef("providers", value, beanDefinition, parserContext);
                            } else if ("protocol".equals(property) && value.indexOf(',') != -1) {
                                //遍历设置成protocols
                                parseMultiRef("protocols", value, beanDefinition, parserContext);
                            } else {
                                Object reference;
                                //判断是否为基本数据类型和包装类型，类似Long，String，Short等
                                //以下的代码全部都是为了版本兼容，看到这里就差不多了，当然也可以继续看
                                if (isPrimitive(type)) {
                                    // 向后兼容旧版本的xsd中的默认值，因为每个版本的xsd都配有默认值，例如
                                    // <xsd:attribute name="version" type="xsd:string" use="optional" default="0.0.0">
                                    if ("async".equals(property) && "false".equals(value)
                                            || "timeout".equals(property) && "0".equals(value)
                                            || "delay".equals(property) && "0".equals(value)
                                            || "version".equals(property) && "0.0.0".equals(value)
                                            || "stat".equals(property) && "-1".equals(value)
                                            || "reliable".equals(property) && "false".equals(value)) {
                                        // backward compatibility for the default value in old version's xsd
                                        value = null;
                                    }
                                    reference = value;
                                } else if ("protocol".equals(property)
                                        //如果属性为 protocol 那么要判断protocol对应的拓展点配置有没有
                                        && ExtensionLoader.getExtensionLoader(Protocol.class).hasExtension(value)
                                        //满足当前值没有在容器内 或者 在容器内类的名字不同
                                        && (!parserContext.getRegistry().containsBeanDefinition(value)
                                        || !ProtocolConfig.class.getName().equals(parserContext.getRegistry().getBeanDefinition(value).getBeanClassName()))) {
                                    if ("dubbo:provider".equals(element.getTagName())) {
                                        //标签的值如果等于dubbo:provider，则输出警告
                                        logger.warn("Recommended replace <dubbo:provider protocol=\"" + value + "\" ... /> to <dubbo:protocol name=\"" + value + "\" ... />");
                                    }

                                    ProtocolConfig protocol = new ProtocolConfig();
                                    protocol.setName(value);
                                    // 兼容旧版本配置
                                    reference = protocol;
                                } else if ("onreturn".equals(property)) {
                                    //回调方法 类似onSuccess
                                    int index = value.lastIndexOf(".");
                                    // bean的名字
                                    String returnRef = value.substring(0, index);
                                    String returnMethod = value.substring(index + 1);
                                    reference = new RuntimeBeanReference(returnRef);
                                    // 添加onreturnMethod属性值
                                    beanDefinition.getPropertyValues().addPropertyValue("onreturnMethod", returnMethod);
                                } else if ("onthrow".equals(property)) {
                                    //回调 异常执行的方法 ,类似 onError
                                    int index = value.lastIndexOf(".");
                                    String throwRef = value.substring(0, index);
                                    String throwMethod = value.substring(index + 1);
                                    //获取ref和方法，将ref放入RuntimeBeanReference中
                                    reference = new RuntimeBeanReference(throwRef);
                                    //向我们自定义类里添加onthrowMethod的值
                                    beanDefinition.getPropertyValues().addPropertyValue("onthrowMethod", throwMethod);
                                } else if ("oninvoke".equals(property)) {
                                    int index = value.lastIndexOf(".");
                                    String invokeRef = value.substring(0, index);
                                    String invokeRefMethod = value.substring(index + 1);
                                    //获取ref和方法，将ref放入RuntimeBeanReference中
                                    reference = new RuntimeBeanReference(invokeRef);
                                    //向我们自定义类里添加oninvokeMethod的值
                                    beanDefinition.getPropertyValues().addPropertyValue("oninvokeMethod", invokeRefMethod);
                                }else {
                                    //如果以上都没进行操作，并且property的字符等于ref，容器包含它的值，
                                    if ("ref".equals(property) && parserContext.getRegistry().containsBeanDefinition(value)) {
                                        //从ref里面获取这个bean
                                        BeanDefinition refBean = parserContext.getRegistry().getBeanDefinition(value);
                                        /*
                                            必须是单例bean(singleton),原型bean（prototype）不行,sevice初始化一次,在spring容器里也只有一个 实例
                                            是不是和dubbo的幂等有关，如果为原型bean，那么服务就变成有状态的了
                                         */
                                        if (!refBean.isSingleton()) {//如果不是单例的bean
                                            throw new IllegalStateException("The exported service ref " + value + " must be singleton! Please set the " + value + " bean scope to singleton, eg: <bean id=\"" + value + "\" scope=\"singleton\" ...>");
                                        }
                                    }
                                    reference = new RuntimeBeanReference(value);
                                }
                                 /*
                                    设置属性，值为另外一个关联的bean
                                    RuntimeBeanReference 固定占位符类，当在beanfactory中作为另外一个bean的引用时，作为属性值对象，将在运行时进行解析
                                 */
                                beanDefinition.getPropertyValues().addPropertyValue(property, reference);
                            }
                        }
                    }
                }
            }
        }
        NamedNodeMap attributes = element.getAttributes();
        //获取解析完后的下一个元素，就是还没被解析的元素
        //没见过这样的map，试了一下里面存储类Node，Node是一个包含很多信息的结点。
        int len = attributes.getLength();
        //遍历获取attributes
        for (int i = 0; i < len; i++) {
            //获取第i个索引对应节点
            Node node = attributes.item(i);
            //获取此结点的名字
            String name = node.getLocalName();
            if (!props.contains(name)) {//查看props否包含name
                if (parameters == null) {//如果parameters为空，则给与新的ManagedMap
                    parameters = new ManagedMap();
                }
                String value = node.getNodeValue();//获取node的值
                //向parameters放入结点名字，将value转成String类型
                parameters.put(name, new TypedStringValue(value, String.class));
            }
        }
        //如果parameters不为空
        if (parameters != null) {
            //将获取到的元素全部添加进自定义的bean中
            beanDefinition.getPropertyValues().addPropertyValue("parameters", parameters);
        }
        //返回自定义的bean
        return beanDefinition;
    }

```

* 下面讲一下parse里面用到的方法，一些简单的就略过了：

```java
    private static void parseNested(Element element, ParserContext parserContext, Class<?> beanClass, boolean required, String tag, String property, String ref, BeanDefinition beanDefinition) {
        //获取标签的子节点
        NodeList nodeList = element.getChildNodes();
        //链表结点不为空
        if (nodeList != null && nodeList.getLength() > 0) {
            //初始化first为真
            boolean first = true;
            for (int i = 0; i < nodeList.getLength(); i++) {
                //传入索引i获取对应的结点node
                Node node = nodeList.item(i);
                //如果node和Element同类型或子类
                if (node instanceof Element) {
                     //传入的标签名和结点名相同 或者 和类名相同
                    if (tag.equals(node.getNodeName())
                            || tag.equals(node.getLocalName())) {
                        if (first) {
                            //把first设置为false
                            first = false;
                            String isDefault = element.getAttribute("default");
                            // 如果第一个子节点default属性为null，则设置为false
                            if (isDefault == null || isDefault.length() == 0) {
                                beanDefinition.getPropertyValues().addPropertyValue("default", "false");
                            }
                        }
                        // 递归解析嵌套的子节点
                        BeanDefinition subDefinition = parse((Element) node, parserContext, beanClass, required);
                        if (subDefinition != null && ref != null && ref.length() > 0) {
                            subDefinition.getPropertyValues().addPropertyValue(property, new RuntimeBeanReference(ref));
                        }
                    }
                }
            }
        }
    }
//遍历nodeList，解析出对应的方法，放入我们自定义的bean里
    @SuppressWarnings("unchecked")
    private static void parseMethods(String id, NodeList nodeList, RootBeanDefinition beanDefinition,
                                     ParserContext parserContext)
        
// 遍历元素，将元素存入map中，返回这个map
    @SuppressWarnings("unchecked")
    private static ManagedMap parseParameters(NodeList nodeList, RootBeanDefinition beanDefinition)
```

### Bean的初始化

​	这里我们通过ServiceBean来分析一下bean的初始化过程。由上文可知，service标签解析出来的BeanDefinition时单例非懒加载的，该BeanDefinition会在容器启动时直接初始化，下面我们来分析一下ServiceBean这个Bean的初始化过程。

* 先找到dubbo-config-spring下的ServiceBean，这里包含6个主要的方法，这些方法来自于它实现的接口，我们这里提一嘴这些接口。
   * InitializingBean 		--afterPropertiesSet方法  spring会在对象实例化之后调用该方法  一般用于初始化一些属性
   * DisposableBean  		--destroy方法，spring容器关闭时调用，在销毁单例时由 BeanFactory 调用。
   * ApplicationContextAware	--setApplicationContext方法  会传入一个ApplicationContext的实例。如果对象需要访问文件资源，即想要调用getResource ，想要发布应用程序事件，或者需要访问 MessageSource，也可以实现此接口。

   * ApplicationListener		--onApplicationEvent方法 添加了上下文刷新的一个监听事件
   * BeanNameAware			--setBeanName方法  设置BeanName，在创建此 bean 的 bean 工厂中设置 bean 的名称。

```java
public class ServiceBean<T> extends ServiceConfig<T> implements InitializingBean, DisposableBean, ApplicationContextAware, ApplicationListener<ContextRefreshedEvent>, BeanNameAware {
...实现了6个主要方法
}
```

继承关系如下图所示：

![image-20211112110113500](dubbo源码解析/image-20211112110113500.png)

 其中实现的接口有几个涉及到spring Bean的生命周期接口，这里我们分析一下具体的方法内容。

（查看一个关系图的具体接口，右键点击这个接口，然后jump to source即可）

#### Aware接口实现

* BeanNameAware的setBeanName方法实现：
  * 接口介绍：由想要在 bean 工厂中知道其 bean 名称的 bean 实现的接口。 请注意，通常不建议对象依赖于它的 bean 名称，因为这表示对外部配置的潜在脆弱依赖，以及对 Spring API 的可能不必要的依赖。

```java
//由想要在 bean 工厂中知道其 bean 名称的 bean 实现的接口。
//请注意，通常不建议对象依赖于它的 bean 名称，因为这表示对外部配置的潜在脆弱依赖，以及对 Spring API 的可能不必要的依赖
    @Override
    public void setBeanName(String name) {
        this.beanName = name;
    }
```

* ApplicationContextAware的setApplicationContext方法实现：
  * SpringExtensionFactory的作用在于dubbo的SPI机制中的依赖注入，当有扩展类需要注入其他bean的时候，可能会从SpringExtensionFactory这个类中通过applicationContext获取Bean对象。

```java
//当一个对象需要访问一组协作 bean 时，实现这个接口是有意义的。 请注意，通过 bean 引用进行配置比仅出于 bean 查找目的实现此接口更可取。
//如果对象需要访问文件资源，即想要调用getResource ，想要发布应用程序事件，或者需要访问 MessageSource，也可以实现此接口
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
        //将applicationContext设置到SpringExtensionFactory中,用于后续从SpringExtensionFactory中获取Bean
        //SpringExtensionFactory是dubbo自定义的一个类
        SpringExtensionFactory.addApplicationContext(applicationContext);
        if (applicationContext != null) {
            SPRING_CONTEXT = applicationContext;
            try {
                Method method = applicationContext.getClass().getMethod("addApplicationListener", new Class<?>[]{ApplicationListener.class}); // backward compatibility to spring 2.0.1
                method.invoke(applicationContext, new Object[]{this});
                supportedApplicationListener = true;
            } catch (Throwable t) {
                if (applicationContext instanceof AbstractApplicationContext) {
                    try {
                        Method method = AbstractApplicationContext.class.getDeclaredMethod("addListener", new Class<?>[]{ApplicationListener.class}); // backward compatibility to spring 2.0.1
                        if (!method.isAccessible()) {
                            method.setAccessible(true);
                        }
                        method.invoke(applicationContext, new Object[]{this});
                        supportedApplicationListener = true;
                    } catch (Throwable t2) {
                    }
                }
            }
        }
    }
```

* InitializingBean的afterPropertiesSet方法实现：
  * 接口介绍：例如，当一个对象需要访问一组协作 bean 时，实现这个接口是有意义的。 请注意，通过 bean 引用进行配置比仅出于 bean 查找目的实现此接口更可取。
    如果对象需要访问文件资源，即想要调用getResource ，想要发布应用程序事件，或者需要访问 MessageSource，也可以实现此接口。

```java
    @Override
    @SuppressWarnings({ "deprecation"})
    public void afterPropertiesSet() throws Exception {
    	//如果当前ServiceBan的provider为空
    	if (getProvider() == null) {
            Map<String, ProviderConfig> providerConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProviderConfig.class, false, false);
            if (providerConfigMap != null && providerConfigMap.size() > 0) {
                Map<String, ProtocolConfig> protocolConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProtocolConfig.class, false, false);
                if ((protocolConfigMap == null || protocolConfigMap.size() == 0)
                        && providerConfigMap.size() > 1) { // backward compatibility
                    List<ProviderConfig> providerConfigs = new ArrayList<ProviderConfig>();
                    for (ProviderConfig config : providerConfigMap.values()) {
                        if (config.isDefault() != null && config.isDefault().booleanValue()) {
                            providerConfigs.add(config);
                        }
                    }
                    if (!providerConfigs.isEmpty()) {
                        setProviders(providerConfigs);
                    }
                } else {
                    ProviderConfig providerConfig = null;
                    for (ProviderConfig config : providerConfigMap.values()) {
                        if (config.isDefault() == null || config.isDefault().booleanValue()) {
                            if (providerConfig != null) {
                                throw new IllegalStateException("Duplicate provider configs: " + providerConfig + " and " + config);
                            }
                            providerConfig = config;
                        }
                    }
                    if (providerConfig != null) {
                        setProvider(providerConfig);
                    }
                }
            }
        }
        
        //如果当前ServiceBan的application为空，则为该Service设置application
        if (getApplication() == null
                && (getProvider() == null || getProvider().getApplication() == null)) {
            Map<String, ApplicationConfig> applicationConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ApplicationConfig.class, false, false);
            if (applicationConfigMap != null && applicationConfigMap.size() > 0) {
                ApplicationConfig applicationConfig = null;
                for (ApplicationConfig config : applicationConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (applicationConfig != null) {
                            throw new IllegalStateException("Duplicate application configs: " + applicationConfig + " and " + config);
                        }
                        applicationConfig = config;
                    }
                }
                if (applicationConfig != null) {
                    setApplication(applicationConfig);
                }
            }
        }
        //如果当前ServiceBan的module为空，则为该Service设置module
        if (getModule() == null
                && (getProvider() == null || getProvider().getModule() == null)) {
            Map<String, ModuleConfig> moduleConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ModuleConfig.class, false, false);
            if (moduleConfigMap != null && moduleConfigMap.size() > 0) {
                ModuleConfig moduleConfig = null;
                for (ModuleConfig config : moduleConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (moduleConfig != null) {
                            throw new IllegalStateException("Duplicate module configs: " + moduleConfig + " and " + config);
                        }
                        moduleConfig = config;
                    }
                }
                if (moduleConfig != null) {
                    setModule(moduleConfig);
                }
            }
        }
        //如果当前ServiceBan的Registries为空，则为该Service设置Registries
        if ((getRegistries() == null || getRegistries().isEmpty())
                && (getProvider() == null || getProvider().getRegistries() == null || getProvider().getRegistries().isEmpty())
                && (getApplication() == null || getApplication().getRegistries() == null || getApplication().getRegistries().isEmpty())) {
            Map<String, RegistryConfig> registryConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, RegistryConfig.class, false, false);
            if (registryConfigMap != null && registryConfigMap.size() > 0) {
                List<RegistryConfig> registryConfigs = new ArrayList<RegistryConfig>();
                for (RegistryConfig config : registryConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        registryConfigs.add(config);
                    }
                }
                if (registryConfigs != null && !registryConfigs.isEmpty()) {
                    super.setRegistries(registryConfigs);
                }
            }
        }
        //如果当前ServiceBan的Monitor为空，则为该Service设置Monitor
        if (getMonitor() == null
                && (getProvider() == null || getProvider().getMonitor() == null)
                && (getApplication() == null || getApplication().getMonitor() == null)) {
            Map<String, MonitorConfig> monitorConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, MonitorConfig.class, false, false);
            if (monitorConfigMap != null && monitorConfigMap.size() > 0) {
                MonitorConfig monitorConfig = null;
                for (MonitorConfig config : monitorConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        if (monitorConfig != null) {
                            throw new IllegalStateException("Duplicate monitor configs: " + monitorConfig + " and " + config);
                        }
                        monitorConfig = config;
                    }
                }
                if (monitorConfig != null) {
                    setMonitor(monitorConfig);
                }
            }
        }
        //如果当前ServiceBan的Protocol为空，则为该Service设置Protocol
        if ((getProtocols() == null || getProtocols().isEmpty())
                && (getProvider() == null || getProvider().getProtocols() == null || getProvider().getProtocols().isEmpty())) {
            Map<String, ProtocolConfig> protocolConfigMap = applicationContext == null ? null : BeanFactoryUtils.beansOfTypeIncludingAncestors(applicationContext, ProtocolConfig.class, false, false);
            if (protocolConfigMap != null && protocolConfigMap.size() > 0) {
                List<ProtocolConfig> protocolConfigs = new ArrayList<ProtocolConfig>();
                for (ProtocolConfig config : protocolConfigMap.values()) {
                    if (config.isDefault() == null || config.isDefault().booleanValue()) {
                        protocolConfigs.add(config);
                    }
                }
                if (protocolConfigs != null && !protocolConfigs.isEmpty()) {
                    super.setProtocols(protocolConfigs);
                }
            }
        }
        // 设置服务名称
        if (getPath() == null || getPath().length() == 0) {
            if (beanName != null && beanName.length() > 0
                    && getInterface() != null && getInterface().length() > 0
                    && beanName.startsWith(getInterface())) {
                setPath(beanName);
            }
        }
        if (!isDelay()) {	//若非延迟加载
            export();	//服务暴露
        }
    }
```

* ApplicationListener的onApplicationEvent方法实现：
  * 接口介绍：应用程序事件侦听器要实现的接口。

```java
    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
    	// 服务没有延迟加载 && 服务没有发布 && 服务没有下线过 。 满足这三个条件，则进行服务暴露
        if (isDelay() && !isExported() && !isUnexported()) {
            if (logger.isInfoEnabled()) {
                logger.info("The service ready on spring started. service: " + getInterface());
            }
            export();	//进行服务暴露
        }
    }
 
    private boolean isDelay() {
    	// 获取延迟加载的设置 ， 延迟注册服务时间(毫秒)- ，设为-1时，表示延迟到Spring容器初始化完成时暴露服务
        Integer delay = getDelay();
        ProviderConfig provider = getProvider();
        if (delay == null && provider != null) {
            delay = provider.getDelay();
        }
        // 加入上下文刷新监听，并且没有设置延迟加载，
        return supportedApplicationListener && (delay == null || delay == -1);
    }
```

* DisposableBean的destroy方法:
  * 接口介绍：由想要在销毁时释放资源的 bean 实现的接口。 如果 BeanFactory 处理缓存的单例，它应该调用 destroy 方法。 应用程序上下文应该在关闭时处理其所有单例。

```java
    @Override
    public void destroy() throws Exception {
        // no need to call unexport() here, see
        // org.apache.dubbo.config.spring.extension.SpringExtensionFactory.ShutdownHookListener
    }
```

整个初始化过程：

> InitializingBean（*afterPropertiesSet*进行初始化)
> --->BeanNameAware(*setBeanName*设置 bean 的名称)
> --->ApplicationContextAware（ApplicationContextAware用将用于初始化对象）
> --->ApplicationListener(onApplicationEvent应用程序事件侦听器要实现的接口)
> --->DisposableBean(destroy在销毁单例时由 BeanFactory 调用)

至此，bean的初始化过程就结束了。从上面的代码可以看出，Dubbo服务暴露是在afterPropertiesSet或onApplicationEvent两个方法中完成的，具体实现就是export方法，下面就涉及到《服务暴露》了，我先去学rocket mq了，下次再说。

### 服务暴露

#### 检查配置

​	由上篇的代码我们已经找到了服务暴露的方法export，下面我们来讲述一下dubbo服务暴露的过程。找到上次代码，然后鼠标滑轮点击或者ctrl+左键进入export方法：

* 先找到上次使用了export的方法：
  * isDelay()：判断是否延迟
  * isExported()：判断是否导出过
  * isUnexported()：判断是否被取消导出过

```java
public void onApplicationEvent(ContextRefreshedEvent event) {
    // 是否有延迟导出 && 是否已导出 && 是不是已被取消导出
    if (isDelay() && !isExported() && !isUnexported()) {
        if (logger.isInfoEnabled()) {
            logger.info("The service ready on spring started. service: " + getInterface());
        }
        //导出服务
        export();
    }
}
```

* 进入export方法

  * export：判断是否暴露，可以在标签中设置

  ><dubbo:provider export="false" />

  * delay：直接赋值要延时开始的时间，单位是秒

```java
    public synchronized void export() {
        if (provider != null) { //服务提供者不为空
            if (export == null) { //获取导入判断，如果为空。则重新获取
                export = provider.getExport();
            }
            if (delay == null) {//获取延时判断，如果为空。则重新获取
                delay = provider.getDelay();
            }
        }
        if (export != null && !export) {
            // 如果 export 为 false，则不导出服务
            return;
        }
            //如果延迟判断不为空，且延迟时间大于0
        if (delay != null && delay > 0) {
            //使用单线程预定执行器，在延迟一定时间后执行任务，
            delayExportExecutor.schedule(new Runnable() {
                @Override
                public void run() {
                    doExport();
                }
            }, delay, TimeUnit.MILLISECONDS);
        } else {
            //立刻导出服务
            doExport();
        }
    }
```

* export方法中，最后又使用doExport方法，这里我们继续跟进：

```java
    protected synchronized void doExport() {
        if (unexported) {//如果是已经取消暴露的，则抛出异常
            throw new IllegalStateException("Already unexported!");
        }
        if (exported) {//如果是已经暴露过的，则直接返回
            return;
        }
        exported = true;//因为我们要开始暴露了，所以先把已暴露打上true，防止多次跑到这个过程
        // 检测 interfaceName 是否为空，为空则抛出异常
        if (interfaceName == null || interfaceName.length() == 0) {
            throw new IllegalStateException("<dubbo:service interface=\"\" /> interface not allow null!");
        }
        checkDefault();//检测 provider 是否为空，为空则新建一个，并通过系统变量为其初始化
        // 下面几个 if 语句用于检测 provider、application 等核心配置类对象是否为空，
        // 若为空，则尝试从其他配置类对象中获取相应的实例。
        if (provider != null) { //经过了上面的方法，这里是必进入的
            // 下面几个 if 语句用于检测 provider、application 等核心配置类对象是否为空，
            // 若为空，则尝试从其他配置类对象中获取相应的实例。
            if (application == null) {
                application = provider.getApplication();
            }
            if (module == null) {//模块配置
                module = provider.getModule();
            }
            if (registries == null) { //注册表
                registries = provider.getRegistries();
            }
            if (monitor == null) {//监控配置
                monitor = provider.getMonitor();
            }
            if (protocols == null) { //协议配置
                protocols = provider.getProtocols();
            }
        }
        if (module != null) {//模块配置不为空
            if (registries == null) {//从模块中获取注册表
                registries = module.getRegistries();
            }
            if (monitor == null) {//监控配置
                monitor = module.getMonitor();
            }
        }
        if (application != null) { //判断应用配置是否为空
            if (registries == null) {//从应用配置读取注册表
                registries = application.getRegistries();
            }
            if (monitor == null) {//从应用配置中获取监控配置
                monitor = application.getMonitor();
            }
        }
        //检测ref是否为泛化服务类型
        if (ref instanceof GenericService) {
            //是的话，则把接口的class类型设置成泛化类型
            interfaceClass = GenericService.class;
            if (StringUtils.isEmpty(generic)) {
                //表明使用了泛化
                generic = Boolean.TRUE.toString();
            }
        } else {// ref 非 GenericService 类型
            try {
                //使用Class.forName获取对象类型
                interfaceClass = Class.forName(interfaceName, true, Thread.currentThread()
                        .getContextClassLoader());
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException(e.getMessage(), e);
            }
            //对 interfaceClass，以及 <dubbo:method> 标签中的必要字段进行检查
            checkInterfaceAndMethods(interfaceClass, methods);
            //检测ref不为空 且 必须是interfaceClass的子类或者同类
            checkRef();
            //说明不是泛化类型
            generic = Boolean.FALSE.toString();
        }
            //local 和 stub 在功能应该是一致的，用于配置本地存根
            //local:服务接口的本地实现类名
            //stub:服务接口的本地存根类名
        if (local != null) {
            if ("true".equals(local)) {
                local = interfaceName + "Local";
            }
            Class<?> localClass;
            try {
                // 获取本地存根类（提供给定名称对应的类，即local对应的类）
                localClass = ClassHelper.forNameWithThreadContextClassLoader(local);
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException(e.getMessage(), e);
            }
            // 检测本地存根类是否可赋值给接口类，若不可赋值则会抛出异常，提醒使用者本地存根类类型不合法
            if (!interfaceClass.isAssignableFrom(localClass)) {
                throw new IllegalStateException("The local implementation class " + localClass.getName() + " not implement interface " + interfaceName);
            }
        }
        if (stub != null) { //这里和上面的local一样，都是本地存根
            if ("true".equals(stub)) {
                stub = interfaceName + "Stub";
            }
            Class<?> stubClass;
            try {
                // 获取本地存根类（提供给定名称对应的类，即local对应的类）
                stubClass = ClassHelper.forNameWithThreadContextClassLoader(stub);
            } catch (ClassNotFoundException e) {
                throw new IllegalStateException(e.getMessage(), e);
            }
            // 检测本地存根类是否可赋值给接口类，若不可赋值则会抛出异常，提醒使用者本地存根类类型不合法
            //这里有个点不是很懂，本地存根为什么要建立两个，而且方法一致。
            if (!interfaceClass.isAssignableFrom(stubClass)) {
                throw new IllegalStateException("The stub implementation class " + stubClass.getName() + " not implement interface " + interfaceName);
            }
        }
        checkApplication(); //检查应用配置，没有就获取，还没有就抛异常
        checkRegistry(); //检查配置表，没有就获取，还没有就抛异常
        //协议为空，服务提供者不为空则设置服务提供者的协议。
        //如果都为空，则设置默认协议，dubbo协议！！！
        checkProtocol();
        //添加进配置，配置为空则返回
        appendProperties(this);
        //校验sub local 和mock、
        //local:服务接口的本地实现类名
        //stub:服务接口的本地存根类名
        checkStubAndMock(interfaceClass);
        //如果服务名不存在，则使用接口名字
        if (path == null || path.length() == 0) {
            path = interfaceName;
        }
        // 导出服务
        doExportUrls();
        // ProviderModel 表示服务提供者模型，此对象中存储了与服务提供者相关的信息。
        // 比如服务的配置信息，服务实例等。每个被导出的服务对应一个 ProviderModel。
        // ApplicationModel 持有所有的 ProviderModel。
        ProviderModel providerModel = new ProviderModel(getUniqueServiceName(), this, ref);
        ApplicationModel.initProviderModel(getUniqueServiceName(), providerModel);
    }
```

总结：上面过程有点多，这里总结一下。

>1. 检测 <dubbo:service> 标签的 interface 属性合法性，不合法则抛出异常
>2. 检测 ProviderConfig、ApplicationConfig 等核心配置类对象是否为空，若为空，则尝试从其他配置类对象中获取相应的实例。
>3. 检测并处理泛化服务和普通服务类
>4. 检测本地存根配置，并进行相应的处理
>5. 对 ApplicationConfig、RegistryConfig 等配置类进行检测，为空则尝试创建，若无法创建则抛出异常

​	配置检查并非本文重点，因此这里不打算对 doExport 方法所调用的方法进行分析（doExportUrls 方法除外）。在这些方法中，除了 appendProperties 方法稍微复杂一些，其他方法逻辑不是很复杂。因此，大家可自行分析。

#### 多协议多注册中心导出服务

* 上面的最后，调用了doExportUrls方法导出服务，我们跟进在看一下：
  * Dubbo 允许我们使用不同的协议导出服务，也允许我们向多个注册中心注册服务。Dubbo 在 doExportUrls 方法中对多协议，多注册中心进行了支持。相关代码如下，我们重点关注两点：
    * loadRegistries：加载注册中心链接
    * doExportUrlsFor1Protocol：组装 URL

```java
    private void doExportUrls() {
        //加载注册中心链接，就是你要引用的那个接口网址 /user/selectOne
        List<URL> registryURLs = loadRegistries(true);
        //遍历协议，并在每个协议下导出服务
        for (ProtocolConfig protocolConfig : protocols) {
            doExportUrlsFor1Protocol(protocolConfig, registryURLs);
        }
    }
```

​	上面代码首先是通过 loadRegistries 加载注册中心链接，然后再遍历 ProtocolConfig 集合导出每个服务。并在导出服务的过程中，将服务注册到注册中心。下面，我们先来看一下 loadRegistries 方法的逻辑。

```java
protected List<URL> loadRegistries(boolean provider) {
    // 检测是否存在注册中心配置类，不存在则抛出异常
    checkRegistry();
    List<URL> registryList = new ArrayList<URL>();
    if (registries != null && !registries.isEmpty()) {
        for (RegistryConfig config : registries) {
            String address = config.getAddress();
            if (address == null || address.length() == 0) {
                // 若 address 为空，则将其设为 0.0.0.0
                address = Constants.ANYHOST_VALUE;
            }
 
            // 从系统属性中加载注册中心地址
            String sysaddress = System.getProperty("dubbo.registry.address");
            if (sysaddress != null && sysaddress.length() > 0) {
                address = sysaddress;
            }
            // 检测 address 是否合法
            if (address.length() > 0 && !RegistryConfig.NO_AVAILABLE.equalsIgnoreCase(address)) {
                Map<String, String> map = new HashMap<String, String>();
                // 添加 ApplicationConfig 中的字段信息到 map 中
                appendParameters(map, application);
                // 添加 RegistryConfig 字段信息到 map 中
                appendParameters(map, config);
                
                // 添加 path、pid，protocol 等信息到 map 中
                map.put("path", RegistryService.class.getName());
                map.put("dubbo", Version.getProtocolVersion());
                map.put(Constants.TIMESTAMP_KEY, String.valueOf(System.currentTimeMillis()));
                if (ConfigUtils.getPid() > 0) {
                    map.put(Constants.PID_KEY, String.valueOf(ConfigUtils.getPid()));
                }
                if (!map.containsKey("protocol")) {
                    if (ExtensionLoader.getExtensionLoader(RegistryFactory.class).hasExtension("remote")) {
                        map.put("protocol", "remote");
                    } else {
                        map.put("protocol", "dubbo");
                    }
                }
 
                // 解析得到 URL 列表，address 可能包含多个注册中心 ip，
                // 因此解析得到的是一个 URL 列表
                List<URL> urls = UrlUtils.parseURLs(address, map);
                for (URL url : urls) {
                    url = url.addParameter(Constants.REGISTRY_KEY, url.getProtocol());
                    // 将 URL 协议头设置为 registry
                    url = url.setProtocol(Constants.REGISTRY_PROTOCOL);
                    // 通过判断条件，决定是否添加 url 到 registryList 中，条件如下：
                    // (服务提供者 && register = true 或 null) 
                    //    || (非服务提供者 && subscribe = true 或 null)
                    if ((provider && url.getParameter(Constants.REGISTER_KEY, true))
                            || (!provider && url.getParameter(Constants.SUBSCRIBE_KEY, true))) {
                        registryList.add(url);
                    }
                }
            }
        }
    }
    return registryList;
}
```

loadRegistries 方法主要包含如下的逻辑：

>1. 检测是否存在注册中心配置类，不存在则抛出异常
>2. 构建参数映射集合，也就是 map
>3. 构建注册中心链接列表
>4. 遍历链接列表，并根据条件决定是否将其添加到 registryList 中

#### 组装 URL

​	配置检查完毕后，紧接着要做的事情是根据配置，以及其他一些信息组装 URL。前面说过，URL 是 Dubbo 配置的载体，通过 URL 可让 Dubbo 的各种配置在各个模块之间传递。URL 之于 Dubbo，犹如水之于鱼，非常重要。大家在阅读 Dubbo 服务导出相关源码的过程中，要注意 URL 内容的变化。既然 URL 如此重要，那么下面我们来了解一下 URL 组装的过程。

```java
private void doExportUrlsFor1Protocol(ProtocolConfig protocolConfig, List<URL> registryURLs) {
    String name = protocolConfig.getName();
    // 如果协议名为空，或空串，则将协议名变量设置为 dubbo
    if (name == null || name.length() == 0) {
        name = "dubbo";
    }
 
    Map<String, String> map = new HashMap<String, String>();
    // 添加 side、版本、时间戳以及进程号等信息到 map 中
    map.put(Constants.SIDE_KEY, Constants.PROVIDER_SIDE);
    map.put(Constants.DUBBO_VERSION_KEY, Version.getProtocolVersion());
    map.put(Constants.TIMESTAMP_KEY, String.valueOf(System.currentTimeMillis()));
    if (ConfigUtils.getPid() > 0) {
        map.put(Constants.PID_KEY, String.valueOf(ConfigUtils.getPid()));
    }
 
    // 通过反射将对象的字段信息添加到 map 中
    appendParameters(map, application);
    appendParameters(map, module);
    appendParameters(map, provider, Constants.DEFAULT_KEY);
    appendParameters(map, protocolConfig);
    appendParameters(map, this);
  	// methods 为 MethodConfig 集合，MethodConfig 中存储了 <dubbo:method> 标签的配置信息
    //这块先不分析，if和for各种嵌套，看着不像源码，像同事写的代码
    if (methods != null && !methods.isEmpty()) {
        //......
        // 这段代码用于添加 Callback 配置到 map 中，代码太长，待会单独分析
    }
 
    // 检测 generic 是否为 "true"，并根据检测结果向 map 中添加不同的信息
    if (ProtocolUtils.isGeneric(generic)) {
        map.put(Constants.GENERIC_KEY, generic);
        map.put(Constants.METHODS_KEY, Constants.ANY_VALUE);
    } else {
        String revision = Version.getVersion(interfaceClass, version);
        if (revision != null && revision.length() > 0) {
            map.put("revision", revision);
        }
 
        // 为接口生成包裹类 Wrapper，Wrapper 中包含了接口的详细信息，比如接口方法名数组，字段信息等
        String[] methods = Wrapper.getWrapper(interfaceClass).getMethodNames();
        // 添加方法名到 map 中，如果包含多个方法名，则用逗号隔开，比如 method = init,destroy
        if (methods.length == 0) {
            logger.warn("NO method found in service interface ...");
            map.put(Constants.METHODS_KEY, Constants.ANY_VALUE);
        } else {
            // 将逗号作为分隔符连接方法名，并将连接后的字符串放入 map 中
            map.put(Constants.METHODS_KEY, StringUtils.join(new HashSet<String>(Arrays.asList(methods)), ","));
        }
    }
 
    // 添加 token 到 map 中
    if (!ConfigUtils.isEmpty(token)) {
        if (ConfigUtils.isDefault(token)) {
            // 随机生成 token
            map.put(Constants.TOKEN_KEY, UUID.randomUUID().toString());
        } else {
            map.put(Constants.TOKEN_KEY, token);
        }
    }
    // 判断协议名是否为 injvm
    if (Constants.LOCAL_PROTOCOL.equals(protocolConfig.getName())) {
        protocolConfig.setRegister(false);
        map.put("notify", "false");
    }
 
    // 获取上下文路径
    String contextPath = protocolConfig.getContextpath();
    if ((contextPath == null || contextPath.length() == 0) && provider != null) {
        contextPath = provider.getContextpath();
    }
 
    // 获取 host 和 port
    String host = this.findConfigedHosts(protocolConfig, registryURLs, map);
    Integer port = this.findConfigedPorts(protocolConfig, name, map);
    // 组装 URL
    URL url = new URL(name, host, port, (contextPath == null || contextPath.length() == 0 ? "" : contextPath + "/") + path, map);
    // 省略无关代码
}
```

​	上面的代码首先是将一些信息，比如版本、时间戳、方法名以及各种配置对象的字段信息放入到 map 中，map 中的内容将作为 URL 的查询字符串。构建好 map 后，紧接着是获取上下文路径、主机名以及端口号等信息。最后将 map 和主机名等数据传给 URL 构造方法创建 URL 对象。需要注意的是，这里出现的 URL 并非 java.net.URL，而是 com.alibaba.dubbo.common.URL。

* 下面来分析一下，上面if和for互相嵌套的代码，这段代码用于检测 <dubbo:method> 标签中的配置信息，并将相关配置添加到 map 中：

```java
 if (methods != null && !methods.isEmpty()) {
            for (MethodConfig method : methods) { //第一层嵌套
                // 添加 MethodConfig 对象的字段信息到 map 中，键 = 方法名.属性名。
                // 比如存储 <dubbo:method name="sayHello" retries="2"> 对应的 MethodConfig，
                // 键 = sayHello.retries，map = {"sayHello.retries": 2, "xxx": "yyy"}
                appendParameters(map, method, method.getName());
                String retryKey = method.getName() + ".retry";
                //概括：设置重试次数
                if (map.containsKey(retryKey)) {
                    String retryValue = map.remove(retryKey);
                    // 检测 MethodConfig retry 是否为 false，若是，则设置重试次数为0
                    if ("false".equals(retryValue)) {
                        map.put(method.getName() + ".retries", "0");
                    }
                }
                // 获取 ArgumentConfig 列表（argument是方法参数配置）
                List<ArgumentConfig> arguments = method.getArguments();
                if (arguments != null && !arguments.isEmpty()) {//第二层嵌套，保证argument不为空
                    //遍历argument配置，里面配有类型，是否有返回（argument是方法参数配置）
                    for (ArgumentConfig argument : arguments) {
                        // 判断argument类型不为空且长度大于0，否则（argument是方法参数配置）
                        if (argument.getType() != null && argument.getType().length() > 0) {//第三层嵌套
                            Method[] methods = interfaceClass.getMethods();//获取接口的所有方法
                            //如果方法不为空，则开始遍历方法
                            if (methods != null && methods.length > 0) { //第四层嵌套
                                for (int i = 0; i < methods.length; i++) {
                                    String methodName = methods[i].getName();
                                    // target the method, and get its signature
                                    //对比方法名，开始寻找目标方法
                                    if (methodName.equals(method.getName())) {//第五层嵌套
                                        Class<?>[] argtypes = methods[i].getParameterTypes();//获取传入参数，如果没有数组则为0
                                        // one callback in the method
                                        if (argument.getIndex() != -1) {
                                            //传入的参数和方法参数配置参数相同则添加进去
                                            if (argtypes[argument.getIndex()].getName().equals(argument.getType())) {
                                                // 添加 ArgumentConfig 字段信息到 map 中，
                                                // 键前缀 = 方法名.index，比如:
                                                // map = {"sayHello.3": true}
                                                appendParameters(map, argument, method.getName() + "." + argument.getIndex());
                                            } else {
                                                //如果名称不一致则抛出异常
                                                throw new IllegalArgumentException("argument config error : the index attribute and type attribute not match :index :" + argument.getIndex() + ", type:" + argument.getType());
                                            }
                                        } else {
                                            //argument.getIndex() == -1表明没有设置
                                            // multiple callbacks in the method
                                            for (int j = 0; j < argtypes.length; j++) {
                                                Class<?> argclazz = argtypes[j];
                                                // 从参数类型列表中查找类型名称为 argument.type 的参数
                                                if (argclazz.getName().equals(argument.getType())) {
                                                    appendParameters(map, argument, method.getName() + "." + j);
                                                    if (argument.getIndex() != -1 && argument.getIndex() != j) {
                                                        throw new IllegalArgumentException("argument config error : the index attribute and type attribute not match :index :" + argument.getIndex() + ", type:" + argument.getType());
                                                    }
                                                }
                                            }
                                        }
                                    }//第四层嵌套
                                }
                            }//第四层嵌套
                        }//第三层嵌套
                        //用户没有设置类型，但配置了index，所以index不为-1
                        else if (argument.getIndex() != -1) {
                            // 添加 ArgumentConfig 字段信息到 map 中
                            appendParameters(map, argument, method.getName() + "." + argument.getIndex());
                        } else {
                            //抛出异常，用户没有设置参数类型也没设置index属性，抛出异常
                            throw new IllegalArgumentException("argument config must set index or type attribute.eg: <dubbo:argument index='0' .../> or <dubbo:argument type=xxx .../>");
                        }

                    }
                }//第二层嵌套
            } // 第一层嵌套结束。end of methods for,
        }
```

​	appendParameters 这个方法出现的次数比较多，该方法用于将对象字段信息添加到 map 中。实现上则是通过反射获取目标对象的 getter 方法，并调用该方法获取属性值。然后再通过 getter 方法名解析出属性名，比如从方法名 getName 中可解析出属性 name。如果用户传入了属性名前缀，此时需要将属性名加入前缀内容。最后将 <属性名，属性值> 键值对存入到 map 中就行了。限于篇幅原因，这里就不分析 appendParameters 方法的源码了，大家请自行分析。

### 导出dubbo服务

​	前置工作做完，接下来就可以进行服务导出了。服务导出分为导出到本地 (JVM)，和导出到远程。在深入分析服务导出的源码前，我们先来从宏观层面上看一下服务导出逻辑。如下：
