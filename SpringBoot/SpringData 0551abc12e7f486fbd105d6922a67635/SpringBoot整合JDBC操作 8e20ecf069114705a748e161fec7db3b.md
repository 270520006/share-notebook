# SpringBoot整合JDBC操作

## 核心思想就是，将数据整合成一个个的Bean,可以使用Spring Data

- 使用的是springboot自带的 **`hikari`**链接池

## 如果使用 jdbc操作链接池呢

- springboot提供了配置好的模板bean哪里即用 ： jdbctemplate封装好的操作数据操作

## 如果切换数据类型

- 使用 spring.datasource.type方法切换数据源

## 德鲁伊配置:导入德鲁伊依赖

```xml
<!-- https://mvnrepository.com/artifact/com.alibaba/druid -->
        <!--        导入Druid数据源依赖-->
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid</artifactId>
            <version>1.1.22</version>
        </dependency>
```

配置 application.yml 配置 

```java
spring:
  datasource:
    username: root
    password: 543210
    url: jdbc:mysql://localhost:3306/warehouse?serverTimezone=UTC&useUnicode=true&characterEncoding=utf-8&useSSL=false
    driver-class-name: com.mysql.cj.jdbc.Driver
    type: com.alibaba.druid.pool.DruidDataSource
    # 下面为连接池的补充设置，应用到上面所有数据源中
    # 初始化大小，最小，最大
    initial-size: 5
    min-idle: 5
    max-active: 20
    # 配置获取连接等待超时的时间
    max-wait: 60000
    # 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
    time-between-eviction-runs-millis: 60000
    # 配置一个连接在池中最小生存的时间，单位是毫秒
    min-evictable-idle-time-millis: 300000
    validation-query: SELECT 1 FROM DUAL
    test-while-idle: true
    test-on-borrow: false
    test-on-return: false
    # 打开PSCache，并且指定每个连接上PSCache的大小
    pool-prepared-statements: true
    #   配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
    max-pool-prepared-statement-per-connection-size: 20
    filters: stat,wall,log4j
    use-global-data-source-stat: true
    # 通过connectProperties属性来打开mergeSql功能；慢SQL记录
    connect-properties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000
```

# 德鲁伊 druid数据源配置参数

[参数](SpringBoot%E6%95%B4%E5%90%88JDBC%E6%93%8D%E4%BD%9C%208e20ecf069114705a748e161fec7db3b/%E5%8F%82%E6%95%B0%204148b400b7384858907a27dd8fd8dffd.csv)

- WEB方式监控配置

```xml
<servlet>
	<servlet-name>DruidStatView</servlet-name>
	<servlet-class>com.alibaba.druid.support.http.StatViewServlet</servlet-class>
</servlet>
<servlet-mapping>
	<servlet-name>DruidStatView</servlet-name>
	<url-pattern>/druid/*</url-pattern>
</servlet-mapping>
<filter>
	<filter-name>druidWebStatFilter</filter-name>
	<filter-class>com.alibaba.druid.support.http.WebStatFilter</filter-class>
	<init-param>
		<param-name>exclusions</param-name>
		<param-value>/public/*,*.js,*.css,/druid*,*.jsp,*.swf</param-value>
	</init-param>
	<init-param>
		<param-name>principalSessionName</param-name>
		<param-value>sessionInfo</param-value>
	</init-param>
	<init-param>
		<param-name>profileEnable</param-name>
		<param-value>true</param-value>
	</init-param>
</filter>
<filter-mapping>
	<filter-name>druidWebStatFilter</filter-name>
	<url-pattern>/*</url-pattern>
</filter-mapping>

```

## 德鲁伊后台监视系统服务

- ServletRegistrationBean 的配置
- 遵循人家默认格式,初始化默认的参数  loginUsername登录后台的用户名  loginPassword 登录后台密码  allow 允许访问的用户和ip地址

## 与配置文件进行绑定,注入Druid数据源

```java
/**
     * @ConfigurationProperties 与配置文件绑定
     * @Bean 将数据源引入到容器中
     */
    @ConfigurationProperties(prefix = "spring.datasource")
    @Bean
    public DataSource DruidDataSources() {
        return new DruidDataSource();
    }
```

```java
/**
     * 放置springboot容器中
     * 配置 druid 后台监视系统
     *
     * @return
     */
    @Bean
    public ServletRegistrationBean getServletBean() {
        ServletRegistrationBean<Servlet> servletBean = new ServletRegistrationBean<>();
        //设置访问路径
        servletBean.setServlet(new StatViewServlet());
        servletBean.addUrlMappings("/druid/*");
        //初始化初始化参数
        Map<String, String> initParameters = new HashMap<String, String>();
//        配置初始化参数 设置用户名和密码
        initParameters.put("loginUsername", "sky");
        initParameters.put("loginPassword", "sky");
//        允许谁可以访问,如果 第一个参数为空,代表所有人都可以访问
        initParameters.put("allow", "127.0.0.1");
        //设置禁止某些客户端访问
//        initParameters.put("用户名", "用户ip");
        servletBean.setInitParameters(initParameters);
        return servletBean;
    }
```

## servlet过滤器

```java
/**
     * 配置过滤器
     *
     * @return
     */
    @Bean
    public FilterRegistrationBean getFilterBean() {
        FilterRegistrationBean<Filter> filterBean = new FilterRegistrationBean<>();
//        设置网络统计过滤器
        filterBean.setFilter(new WebStatFilter());
        //初始化配置参数
        Map<String, String> initParameters = new HashMap<>();
        //排除过滤统计的路径
        initParameters.put("exclusions", "*.css,*.js,/druid/*");
        return filterBean;
    }
```