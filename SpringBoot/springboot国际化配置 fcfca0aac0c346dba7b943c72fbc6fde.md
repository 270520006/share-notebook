# springboot国际化配置

通过 Message Source Properties 去指定国际化配置目录

### thyme leaf  a标签 参数配置

在 thyme leaf中 a标签 不是用  “?"传参 而是用括号 (参数名='参数值')

# 页面国际化配置

1. 需要配置 i18n下的bundle resource 下的properties
2. 如果要根据请求更换语言,需要自定义配置 localeResolver 配置解析器实现页面更换语言
3. 最后将自定义的组件添加到springboot创建的ioc容器中

# 注解@Componnent和 @Bean的区别

## 两者的目的是一样的，都是注册bean到Spring容器

1. @Component注解表明一个类会作为组件类，并告知Spring要为这个类创建bean。
2. @Bean注解告诉Spring这个方法将会返回一个对象，这个对象要注册为Spring应用上下文中的bean。通常方法体中包含了最终产生bean实例的逻辑。

## 区别

1. @Component（@Controller、@Service、@Repository）通常是通过类路径扫描来自动侦测以及自动装配到Spring容器中
2. 而@Bean注解通常是我们在标有该注解的方法中定义产生这个bean的逻辑
3. @Component 作用于类，@Bean作用于方法