# Java.Class.Lang类的理解

## 类的加载过程

1.程序经过javac.exe命令以后，会生成一个或者多个字节码文件（.class结尾）。
接着我们使用Java.exe命令对某个字节码文件进行解释运行。相当于某个字节码文件加载到内存中，此过程就
称为类的加载，加载在内存中的类，我们称为运行时类，此运行时类，就成为(大Class)Class的实例

2.换句话说，class的实例就对应着一个运行时的类

3.加载到内存中的运行时的类，会缓存一定的时间，在此时间内，我们可以跟据不同的方式来获取此运行时类

## 获取Class的方式

1. Class class=对象.class;
2. 对象 对象名=new 对象();
Class class=对象名.getClass();
3. Class class=Class.forName("指定Class实例的类");
4. ClassLoader classLoader=ReflectionTest.class.getClassLoader();
Class class=classLoader.loadClass("指定Class实例的类");