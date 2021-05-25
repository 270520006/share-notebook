# MyBatisPlus 学习笔记

# **一、快速入门**

文档：https://mp.baomidou.com/

使用第三方组件：

1. 导入对应依赖
2. 研究依赖如何配置
3. 代码如何编写
4. 提高扩展技术能力

> 步骤

1、创建数据库 `mybatis_plus`

2、创建user表

```
DROP TABLE IF EXISTS user;

CREATE TABLE user
(
	id BIGINT(20) NOT NULL COMMENT '主键ID',
	name VARCHAR(30) NULL DEFAULT NULL COMMENT '姓名',
	age INT(11) NULL DEFAULT NULL COMMENT '年龄',
	email VARCHAR(50) NULL DEFAULT NULL COMMENT '邮箱',
	PRIMARY KEY (id)
);
-- 真实开发中，version(乐观锁)、deleted(逻辑删除)、gmt_create、gmt_modified1234567891011
```

3、创建项目

4、导入依赖

```xml
<!--数据库驱动-->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.20</version>
        </dependency>
				<!--mybatis-plus-->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.0.5</version>
        </dependency>
        <!--lombok-->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
```

> 说明：我们使用mybatis-plus可以节省我们大量的代码，尽量不要同时导入mybatis和mybatis-plus！

5、连接数据库，这一步和mybatis相同

```bash
# mysql
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.url=jdbc:mysql://localhost:3306/mybatis_plus?userSSL=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=UTC
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
12345
```

6、传统方式：pojo-dao（连接mybatis，配置mapper.xml文件）- service - controller

6、使用了mybatis-plus 之后

- pojo

    ```
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public class User {
        
        private Long id;
        private String name;
        private Integer age;
        private String email;
    }
    12345678910
    ```

- mapper接口

    ```
    // 在对应的Mapper上面继承基本的接口 BaseMapper@Repository // 代表持久层public interface UserMapper extends BaseMapper<User> {
        // 所有的CRUD操作都已经基本完成了// 你不需要像以前的配置一大堆文件了}
    123456
    ```

- **注意点：我们需要在主启动类上去扫描我们的mapper包下的所有接口**

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-w9etjbRi-1596161859946)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200726172410154.png)]

- 测试类中测试

    ```
    @SpringBootTest
    class MybatisPlusApplicationTests {

        // 继承了BaseMapper,所有的方法都来自父类// 我们也可以编写自己的扩展方法@Autowired
        UserMapper userMapper;

        @Test
        void contextLoads() {
            // 参数是一个 Wrapper , 条件构造器，这里我们先不用 null// 查询全部用户
            List<User> users = userMapper.selectList(null);
            users.forEach(System.out::println);
        }
    }
    12345678910111213141516
    ```

> 思考问题：

1、SQL是谁帮我们写的？MyBatis-Plus都写好了

2、方法哪里来的？MyBatis-Plus 都写好了

# **二、配置日志**

我们所有的sqld现在都是不可见的，我们希望知道它是怎么执行的，所以我们必须要看日志！

```
# 配置日志 (系统自带的，控制台输出)
mybatis-plus.configuration.log-impl=org.apache.ibatis.logging.stdout.StdOutImpl
12
```

[外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-IEkwJlTh-1596161859950)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200726175200015.png)]

配置完毕日志之后，后面的学习就需要注意这个自动生成的SQL，你们就会喜欢上MyBatis-Plus !

# **三、CRUD**

### **1. 插入操作**

> Insert 插入

```
@Test
public void testInsert() {
    User user = new User();
    user.setName("Dainel");
    user.setAge(3);
    user.setEmail("daniel@alibaba.com");

    int result = userMapper.insert(user);// 帮我们自动生成id
    System.out.println(result);// 受影响的行数
    System.out.println(user);// 发现: id自动回填}
1234567891011
```

> 数据库插入的id默认值为：全局的唯一id

### **2. 主键生成策略**

> 默认 ID_WORKER 全局唯一id

分布式系统唯一id生成：https://www.cnblogs.com/haoxinyue/p/5208136.html

**雪花算法：**

snowflake是Twitter开源的分布式ID生成算法，结果是一个long型的ID。其核心思想是：使用41bit作为毫秒数，10bit作为机器的ID（5个bit是数据中心，5个bit的机器ID），12bit作为毫秒内的流水号（意味着每个节点在每毫秒可以产生 4096 个 ID），最后还有一个符号位，永远是0。可以保证几乎全球唯一！

> 主键自增

我们需要配置主键自增：

1. 实体类字段上 `@TableId(type = IdType.AUTO)`
2. 数据库字段上一定是自增的

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-PMhTDEIu-1596161859951)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200726181541822.png)]

3. 再次测试即可

> 其余的源码解释

```
public enum IdType {
    AUTO(0), // 数据库id自增NONE(1), // 未设置主键INPUT(2), // 手动输入，自己写idID_WORKER(3), // 默认的全局唯一idUUID(4), // 全局唯一id uuidID_WORKER_STR(5); // ID_WORKER 字符串表示法}
12345678
```

### **3. 更新操作**

```
//测试更新@Test
public void testUpdate(){
    User user = new User();
    // 通过条件自动拼接动态sql
    user.setId(6L);
    user.setName("关注我的微信公众号");
    user.setAge(18);
    // 注意： updateById 但是参数是一个 对象int i = userMapper.updateById(user);
    System.out.println(i);
}
123456789101112
```

[外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-p8ZH7E5R-1596161859954)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200726191144465.png)]

所有的sql都是自动帮你动态配置的！

### **4. 自动填充**

创建时间、修改时间！这些个操作一般都是自动化完成的，我们不希望手动更新！

- *阿里巴巴开发手册：**所有的数据库表：gmt_create、gmt_modified几乎所有的表都要配置上！而且需要自动化！

> 方式一：数据库级别（工作中不允许修改数据库）

1. 在表中新增字段 create_time,update_time

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-vICYcDwE-1596161859956)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727113214241.png)]

2. 再次测试插入方法，我们需要先把实体类同步

    ```
    private Date createTime;
    private Date updateTime;
    12
    ```

3. 再次查看更新结果即可

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-sA3Bs6T5-1596161859958)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727113807561.png)]

> 方式二：代码级别

1. 删除数据库中的默认值、更新操作

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-JF4qgn6l-1596161859959)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727113914574.png)]

2. 实体类的字段属性上需要增加注解

    ```
    //字段添加填充内容@TableField(fill = FieldFill.INSERT)
    private Date createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private Date updateTime;
    123456
    ```

3. 编写处理器来处理这个注解即可

    ```
    package com.kuang.handler;

    import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
    import lombok.extern.slf4j.Slf4j;
    import org.apache.ibatis.reflection.MetaObject;
    import org.springframework.stereotype.Component;

    import java.util.Date;

    @Slf4j
    @Component // 一定不要忘记把处理器加到IOC容器中public class MyMetaObjectHandler implements MetaObjectHandler {

        // 插入时候的填充策略@Override
        public void insertFill(MetaObject metaObject) {
            log.info("start insert fill ...");
            // setFieldValByName(String fieldName, Object fieldVal, MetaObject metaObject)this.setFieldValByName("createTime", new Date(), metaObject);
            this.setFieldValByName("updateTime", new Date(), metaObject);
        }

        // 更新时的填充策略@Override
        public void updateFill(MetaObject metaObject) {
            log.info("start update fill ...");
            this.setFieldValByName("updateTime", new Date(), metaObject);
        }

    }
    123456789101112131415161718192021222324252627282930
    ```

4. 测试插入
5. 测试更新，观察时间

### **5. 乐观锁**

在面试过程中，我们经常会被问到乐观锁，悲观锁。

> 乐观锁：顾名思义，它总是认为不会出现问题，无论干什么都不去上锁！如果出现了问题，再次更新值测试！悲观锁：顾名思义，它总是认为总是出现问题，无论干什么都上锁！再去操作！

乐观锁实现方式：

- 取出记录时，获取当前version
- 更新时，带上这个version
- 执行更新时， set version = newVersion where version = oldVersion
- 如果version不对，就更新失败

[外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-nrRaPWcA-1596161859960)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727124418439.png)]

> 测试一下MyBatisPlus的插件：

1. 数据库中增加一个version字段

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-uPny1xOh-1596161859961)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727124741834.png)]

2. 需要实体类加上对应的字段

    ```
    @Version // 乐观锁的version注解private Integer version;
    12
    ```

3. 注册组件

    ```
    // 扫描我们的 mapper文件夹@MapperScan("com.kuang.mapper")
    @EnableTransactionManagement
    @Configuration
    public class MyBatisPlusConfig {

        // 注册乐观锁插件@Bean
        public OptimisticLockerInterceptor optimisticLockerInterceptor() {
            return new OptimisticLockerInterceptor();
        }
    }
    123456789101112
    ```

4. 测试一下

    ```
        // 测试乐观锁成功@Test
        public void testVersionSuccess(){
            // 1. 查询用户信息
            User user = userMapper.selectById(1L);
            // 2. 修改用户信息
            user.setName("fan");
            user.setAge(24);
            // 3. 执行更新操作
            userMapper.updateById(user);
        }

        // 测试乐观锁失败!多线程下@Test
        public void testVersionFall(){
            // 线程1
            User user1 = userMapper.selectById(1L);
            user1.setName("fan111");
            user1.setAge(14);

            // 线程2
            User user2 = userMapper.selectById(1L);
            user2.setName("fan222");
            user2.setAge(24);
            userMapper.updateById(user2);
            
            //自旋锁来多次尝试提交！
            userMapper.updateById(user1); //如果没有乐观锁就会覆盖插队线程的值}
    }
    123456789101112131415161718192021222324252627282930
    ```

5. 测试结果

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-5Gpmj9m4-1596161859962)(D:\我\MyBlog\MyBatisPlus 学习笔记.assets\image-20200727182757647.png)]

### **6. 查询操作**

```
// 测试查询@Test
public void testSelectById(){
    User user = userMapper.selectById(1);
    System.out.println(user);
}

// 批量查询@Test
public void testSelectByBatchIds(){
    List<User> users = userMapper.selectBatchIds(Arrays.asList(1, 2, 3));
    users.forEach(System.out::println);
}

// 按照条件查询之一使用 map@Test
public void testSelectByMap(){
    HashMap<String, Object> map = new HashMap<>();
    // 自定义要查询
    map.put("name","Dainel");
    map.put("age","6");
    List<User> users = userMapper.selectByMap(map);
    users.forEach(System.out::println);
}
123456789101112131415161718192021222324
```

### **7. 分页查询**

分页网站频繁使用

1. 原始使用limit进行分页
2. pageHelper第三方插件
3. MybatisPlus内置了分页插件

> 如何使用？

1. 配置拦截器

    ```
    // 分页插件@Bean
    public PaginationInterceptor paginationInterceptor() {
        return new PaginationInterceptor();
    }
    12345
    ```

2. 直接使用Page对象即可

    ```
    // 测试分页查询@Test
    public void testPage(){
        // 参数一: 当前页// 参数二： 页面大小// 使用了分页插件之后，所有的分页操作变得简单了
        Page<User> page = new Page<>(1,5);
        userMapper.selectPage(page, null);

        page.getRecords().forEach(System.out::println);
        System.out.println(page.getTotal());
    }
    123456789101112
    ```

### **8. 删除操作**

```
// 测试删除@Test
public void testdelete(){
    userMapper.deleteById(6L);
}

// 测试批量删除@Test
public void testdeleteBatchId(){
    userMapper.deleteBatchIds(Arrays.asList(1287326823914405893L,1287326823914405894L));
}

//通过map删除@Test
public void testDeleteByMap(){
    HashMap<String, Object> map = new HashMap<>();
    map.put("name","KUANG");
    userMapper.deleteByMap(map);
}
12345678910111213141516171819
```

我们在工作中会遇到一些问题：逻辑删除！

### **9. 逻辑删除**

> 物理删除：从数据库中直接移除逻辑删除：在数据库中没有被移除，而是通过一个变量让他生效！deleted=0 --> deleted=1

管理员可以查看被删除的记录！防止数据的丢失！类似于回收站！

**测试：**

1. 在数据库表中增加一个deleted字段

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-635tYhpt-1596161859963)(D:\我\MyBlog\狂神说 MyBatisPlus 学习笔记.assets\image-20200727213504033.png)]

2. 实体类中增加属性

    ```
    @TableLogic // 逻辑删除private Integer deleted;
    12
    ```

3. 配置

    ```
    // 逻辑删除组件public ISqlInjector sqlInjector(){
        return new LogicSqlInjector();
    }
    1234
    ```

    ```
    # 配置逻辑删除
    mybatis-plus.global-config.db-config.logic-delete-value=1
    mybatis-plus.global-config.db-config.logic-not-delete-value=0
    123
    ```

4. 测试删除

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-3j76nnP5-1596161859964)(D:\我\MyBlog\狂神说 MyBatisPlus 学习笔记.assets\image-20200727214627234.png)]

5. 测试查询

    [外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-enzpaIBZ-1596161859965)(D:\我\MyBlog\狂神说 MyBatisPlus 学习笔记.assets\image-20200727214908774.png)]

> 以上所有的CRUD操作及其扩展操作，我们必须精通掌握！会大大提高工作效率！

# **四、性能分析插件**

我们在平时的开发中，会遇到一些慢sql。解决方案：测试，druid监控…

**作用：性能分析拦截器，用于输出每条SQL语句及其执行时间**

MyBatisPlus也提供性能分析插件，如果超过这个时间就停止运行！

1. 导入插件

    ```
    // SQL执行效率插件@Bean
    @Profile({"dev","test"})
    public PerformanceInterceptor performanceInterceptor(){
        PerformanceInterceptor performanceInterceptor = new PerformanceInterceptor();
        performanceInterceptor.setMaxTime(100); //ms 设置sql执行的最大时间，如果超过了则不执行
        performanceInterceptor.setFormat(true); // 是否格式化return performanceInterceptor;
    }
    123456789
    ```

    记住，要在SpringBoot中配置环境为dev或者test环境！

2. 测试使用

    ```
    // 测试查询@Test
    public void testSelectById(){
        User user = userMapper.selectById(3);
        System.out.println(user);
    }
    123456
    ```

    只要超出时间就会抛出异常

> 使用性能分析插件可以提高效率，新版本MP已经移除该拆件了，可以使用druid

# **五、条件构造器**

十分重要：wrapper

我们写一些复杂的sql就可以使用它来代替！

[外链图片转存失败,源站可能有防盗链机制,建议将图片保存下来直接上传(img-UfLuImuQ-1596161859966)(D:\我\MyBlog\狂神说 MyBatisPlus 学习笔记.assets\image-20200727234648077.png)]

# **六、代码生成器**

dao、pojo、service、controller都给我自己去编写完成！

ceptor.setMaxTime(100); //ms 设置sql执行的最大时间，如果超过了则不执行performanceInterceptor.setFormat(true); // 是否格式化return performanceInterceptor;}

```

记住，要在SpringBoot中配置环境为dev或者test环境！

2. 测试使用

```java
// 测试查询
@Test
public void testSelectById(){
    User user = userMapper.selectById(3);
    System.out.println(user);
}
123456789101112
```

只要超出时间就会抛出异常

> 使用性能分析插件可以提高效率，新版本MP已经移除该拆件了，可以使用druid

# **五、条件构造器**

十分重要：wrapper

我们写一些复杂的sql就可以使用它来代替！

[外链图片转存中…(img-UfLuImuQ-1596161859966)]

# **六、代码生成器**

dao、pojo、service、controller都给我自己去编写完成！

AutoGenerator 是 MyBatis-Plus 的代码生成器，通过 AutoGenerator 可以快速生成 Entity、Mapper、Mapper XML、Service、Controller 等各个模块的代码，极大的提升了开发效率