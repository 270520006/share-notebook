# 宋红康 JVM 中篇



## 指令集

### 类型转换指令

##### 1.宽化类型转换

###### 	1.1精度损失问题

​		宽化类型是不会因为超过目标类型最大值而丢失信息的，例如：从 int 转换到 long ，int  转换到 double，都不会丢失任何信息，转换前后的指都是精确相等的

​		从 int、long 类型数值转换到 float，或者 long 类型数值转换到 double，将可能发生精度丢失（可能丢失掉几个最低有效位上的值，转换后的浮点数值是根据 IEEE754  最接近舍入模式 所得到的正确正整数值）











``` 
Byte i = 100;
(int)  i = i + 10;   // Error
(byte) i += 10;		 // no Error, 自动转换类型
```



&、|、~、





**在不涉及到其它运算的时候**
**i++、++i   字节码是一样的： iinc 1 by 1, 直接在局部变量表中进行自增，第一个 1 是局部变量表中的索引**

```
int i = 10;
i = i++;
System.out.println(i);   // 10
先把局部变量表 i 的值压入 stack，再把局部变量表中的 i 自增加 1，再把 stack 中的值赋值给局部变量表中的 i

int i = 10;
i = ++i;
System.out.println(i);   // 11
先把局部变量表中的 i 自增 1，再把 i 值压入 stack，再把 stack 中的值赋值给局部变量表中的 i


```

##### 窄化类型

当将一个 double 类型窄化转换为 float 类型时，将遵循一下原则

原则：通过向最接近数舍入模式舍入一个可以使用 float 类型表示的数字

1.如果转换结果的绝对值太小而无法使用 float 表示，将返回 float 类型的 正负零

2.如果转换结果的绝对值太大而无法使用 float 表示，将返回 float 类型的正负无穷大

3.对于 double 类型的 NaN 值将规定转换为 float 类型的 NaN 值





### 对象的创建与访问指令



#### 创建类和数组实例的指令

创建基本数据类型的数组：newarray

创建引用类型的数据：anewarray

创建多维数组：multianewarray



此处创建

```

int[][] mintArray = new int[10][10];
	bipush 10
	bipush 10
	multianewarray #6 <[[I> dim 2
	astore_3
	
String[][] strArray = new String[10][];
	bipush 10
	anewarray #7 <[Ljava/lang/String;>          //此时 只开辟了 String[10]  都是 null，还是一维的情况
    astore 4
```



#### 字段访问指令（field 字段）

对象创建后，就可以通过对象访问指令获取对象实例或数组实例中的字段或者数组元素



- 访问类字段（static 字段，或称为类变量）的指令：getstatic、putstatic
- 访问类实例字段（非static 字段，或称为实例变量）的指令：getfield、putfield

举例：以 getstatic 为例，含有一个操作数，为指向常量池的 Fieldref 索引，它的作用就是获取 Fieldref 指定的对象或值，并将其**压入操作数栈。**



```

public void sayHello() {
	System.out.println("hello");
}

0 getstatic #8 <java/lang/System.out>       //System.out 是 static field
3 ldc #9 <hello>
5 invokevirtual #10 <java/io/PrintStream.println>
8 return
```









#### 数组操作指令

数组操作指令主要有：xastore 和 xaload 指令。具体为

- ​	把一个数组元素加载到操作数栈的指令：baload、caload、saload、iaload、laload、faload、daload、aaload

- ​    将一个操作数栈的值存储到数组元素中的指令：bastore、castore、sastore、iastore、lastore、fastore、dastore、aastore

  |    数组类型     | 加载指令 | 存储指令 |
  | :-------------: | -------- | -------- |
  | byte（boolean） | baload   | bastore  |
  |      char       | caload   | castore  |
  |      short      | saload   | sastore  |
  |       int       | iaload   | iastore  |
  |      long       | laload   | lastore  |
  |      float      | faload   | fastore  |
  |     double      | daload   | dastore  |
  |    reference    | aaload   | aastore  |

  





- 取数组长度的指令：arraylength
  - 该指令弹出栈顶的数组元素（数组的地址值），获取数组的长度，将长度压入栈

说明

- xaload 表示将数组的元素压栈，指令 xaload 在执行时，要求操作数栈中栈顶元素为数组的索引 i ，栈顶顺位第 2 个元素为数组引用 a，该指令会弹出栈顶这两个元素，并将 a[i] （值）重新压入栈。

- xastore 则专门针对数组操作，以 iastore 为例，它用于给一个 int 数组的给定索引赋值。在 iastore 执行前，操作数栈顶需要以此准备 3 个元素：**值、索引、数组引用**， iastore 会弹出这三个值，并将值赋给数组中指定索引的位置。





类型检查指令

检查类实例或数组类型的指令：instanceof、checkcast

- 指令 checkcast 用于检查类型强制转换是否可以进行，如果可以进行，那么 checkcast 指令不会改变操作数栈，否则会抛出 ClassCastException 异常

- 指令 instanceof 用来判断给定对象是否是某一个类的实例，会将判断结果压入操作数栈

  

```
public String checkCast(Object obj) {
    if (obj instanceof String) {
        return (String) obj;
    } else {
        return null;
    }
}

0 aload_1                                  // 将局部变量表中的 obj 加载进 操作数栈
1 instanceof #17 <java/lang/String>
4 ifeq 12 (+8)                             // if 的判断
7 aload_1
8 checkcast #17 <java/lang/String>         // (String) obj  这就是强转，因为if进行判断了，此处不会抛出 ClassCastException 
11 areturn
12 aconst_null							  // if 判断不成立，直接从这一行开始执行
13 areturn

```





### 方法调用与方法返回指令



#### 方法调用指令补充知识点

```
interface AA{
	public static void method1() {                // invokestatic
	
	}
	
	public default void method2() {               // invokespecial
	
	}


}
```







#### 方法返回指令

方法调用结束前，需要进行返回，方法返回指令是根据返回值的类型区分的。



举例：

- 通过 ireturn 指令，将当前函数的操作数栈的顶层元素弹出，并将这个元素压入调用者函数的操作数栈中（因为调用者非常关心函数的返回值），所有当前函数操作数栈中的其它元素都会被丢弃。

- 如果当前返回的是 synchronized 方法，那么还会执行一个隐含的  monitorexit 指令，退出临界区，
- 最后，会丢弃当前方法的整个帧，恢复调用者的帧，并将控制权交给调用者





### 操作数栈管理指令



- 复制栈顶一个或两个数值并将复制值或双份的复制值重新压入栈顶：dup、dup2、dup_x1、dup2_x1、dup_x2、dup2_x2
- 将栈最顶端的两个 slot 数值位置继续宁交换：swap，Java 虚拟机没有提供交换两个 64 位数据类型（float、double）数值的指令
- 指令 nop，是一个特殊的指令，字节码 0x00，和汇编语言中的 nop 一样，表示什么都不做，这条指令一般可用于调试、占位等





注意点 dup 

- 不带 _x  的指令
  - dup 复制 1 个 slot 的数据，例如 1 个int 或 1 个 reference 类型数据
  - dup2 复制 2 个 slot 的数据，例如 1个long，或 2 个int

- 带   _x  的指令是复制栈顶数据并插入栈顶以下的某个位置，共有四个指令 dup_x1，dup2_x1，dup_x2，dup2_x2，对于带  _x 的复制插入指令，只要将指令的 dup 和 x 的系数相加，结果既为需要插入的位置
  - dup_x1 插入位置：1 + 1 =2，即栈顶 2 个 slot 下面。	
  - dup_x2 插入位置：1 + 2 =3，即栈顶 3 个 slot 下面。	
  - dup2_x1 插入位置：2 + 1 =3，即栈顶 3 个 slot 下面。	
  - dup2_x2 插入位置：2 + 2 =4，即栈顶 4 个 slot 下面。						 





```

public long nextIndex() {
		return index++;         // 此时 return 0,在字节码指令的层面上解释
}

private long index = 0;

0 aload_0    // this 对象
1 dup
2 getfield #2 <com/.../StackOperateTest.index>
5 dup_2x1      // 因为index 是 long 类型占用 2 个 slot
6 lconst_1
7 ladd
8 putfield #2 <com/.../StackOperateTest.index>
11 lreturn
```





### 控制转移指令



#### 比较指令

float、double、long

作用：是比较栈顶两个元素的大小，并将比较结果入栈。

比较指令有：dcmpg、dcmpl、fcmpg、fcmpl、lcmp：（比较的是 double、float、long，没有byte/short/char/int）

- 对于 double 和 float 类型的数字，由于 NaN 的存在，各有两个版本的比较指令，
- 以 float 指令为例，有 fcmpg、fcmpl 两个指令，区别是在数字比较时，若遇到 NaN 值，处理结果不同，fcmpg、fcmpl 都从栈中弹出两个操作数，并将他们作比较，栈顶元素为 v2，栈顶顺位第二位元素为 v1，若 v2=v1.则压入 0，若 v1> v2则压入 - 1，若遇到 NaN ，fcmpg 压入 1，fcmpl 压入 -1





#### 一、条件跳转指令



- **条件跳转指令通常和比较指令结合使用。（float、double、long要先进行比较指令 转换成 int 之后，再与  0 进行比较完成条件跳转指令）**

  ​	先比较指令：       dcmpg

  ​	再条件跳转指令：ifge 20

- **如果是 byte、short、char、int 直接进行条件跳转指令   （因为可以直接与  0  进行比较）**

  

**统一含义：弹出栈顶元素，测试它是否满足某一条件，如果满足条件，则跳转到给定位置**

| ifeq          | 当栈顶 int 类型数值 = 0 时跳转       |
| ------------- | ------------------------------------ |
| **ifne**      | **当栈顶 int 类型数值 ！= 0 时跳转** |
| **iflt**      | **当栈顶 int 类型数值 < 0 时跳转**   |
| **ifle**      | **当栈顶 int 类型数值 <= 0 时跳转**  |
| **ifgt**      | **当栈顶 int 类型数值 > 0 时跳转**   |
| **ifge**      | **当栈顶 int 类型数值 >= 0 时跳转**  |
| **ifnull**    | **为 null 时跳转**                   |
| **ifnonnull** | **不为 null 时跳转**                 |



ne ： not equals，lt：less than，le：less equals，gt：greater than，ge：greater equals



#### 二、比较条件跳转指令



比较条件跳转指令 = 比较指令 + 条件跳转指令

- 在执行指令时，栈顶需要准备两个元素进行比较，指令执行完成后，栈顶这两个元素被清空，且没有任何数据入栈，如果预设条件成立，则进行跳转，否则，继续执行下一条语句。

  

| **if_icmpeq** | **比较栈顶两 int 类型数值大小，当前者 = 后者 时跳转**  |
| ------------- | ------------------------------------------------------ |
| **if_icmpne** | **比较栈顶两 int 类型数值大小，当前者 != 后者 时跳转** |
| **if_icmplt** | **比较栈顶两 int 类型数值大小，当前者 < 后者 时跳转**  |
| **if_icmple** | **比较栈顶两 int 类型数值大小，当前者 <= 后者 时跳转** |
| **if_icmpgt** | **比较栈顶两 int 类型数值大小，当前者 > 后者 时跳转**  |
| **if_icmpge** | **比较栈顶两 int 类型数值大小，当前者 >= 后者 时跳转** |
| **if_acmpeq** | **比较栈顶两引用类型数值，当结果相等时跳转**           |
| **if_acmpne** | **比较栈顶两引用类型数值，当结果不相等时跳转**         |





#### 三、多条件分支跳转指令

多条件分支跳转是专为 switch-case 语句设计，主要有 tableswitch、lookupswitch

- tableswitch：要求多个条件分支值是连续的，case 1，case 2 .... 这种 值是连续的，内部只存放起始值和终止值，以及若干个跳转偏移量，通过给定的操作数 index，可以立即定位到跳转偏移量位置，**效率高**
- lookupswitch：内部存放着各个离散的 case-offset 对，每次执行都要搜索全部的 case-offset对，找到匹配的 case 值，**效率低**

- lookupswitch：在字节码指令中，会对 case 值进行排序，提高下效率。





会先根据 case 值的 hashcode 进行排序，先进行 hashcode 的比较，然后

```
// 在 JDK7 新特性中，switch 引入 String 类型
public void switch3(String session) {
    switch (session) {
        case "spring": break;
        case "summer": break;
        case "autumn": break;
        case "winter": break;

    }
}


```





#### 四、无条件跳转指令

目前最主要的无条件跳转指令 goto，接收 2 byte 的操作数，指令执行的目的就是跳转到偏移量给定的位置处。

若偏移量 > 2 byte 的范围，可以使用 goto_w，和 goto 相同作用，接收 4 byte 的操作数，**可以表示更大的地址范围**



| **goto**   | **无条件跳转**           |
| ---------- | ------------------------ |
| **goto_w** | **无条件跳转（宽索引）** |







### 抛出异常指令



- 正常情况下，操作数栈的压入弹出都是一条一条指令完成的，唯一的例外就是**在抛异常时**，Java 虚拟机会清除操作数栈上的所有内容，而后将异常实例压入调用者操作数栈上。







##############

异常及异常的处理

- 过程一：异常对象的生成过程  --->  throw（手动 / 自动）    ---> 指令：athrow
  - 过程二：异常的处理：抓抛模型。try-catch-finally		 ---> 使用异常表	





#### 处理异常

异常表

如果一个方法定义了一个 try-catch 或 try-finally 的异常处理，就会创建一个异常表。它包含了每个异常处理或者 finally 块的信息，异常表保存了每个异常处理信息，比如：

- **起始位置**
- **结束位置**
- **程序计数器记录的代码处理的偏移地址**
- **被捕获的异常类在常量池中的索引**



当一个异常被抛出时，JVM 会在当前方法寻找一个匹配的处理，若没找到，这个方法会强制结束并弹出当前栈帧，并且异常会重新抛给上层调用的方法，如果在所有栈帧弹出前仍然没有找到合适的异常处理，这个线程将终止，如果这个异常在最后一个非守护线程抛出，将会导致 JVM 终止，比如这个线程是个 main 线程。

不管什么时候抛出异常，如果异常处理最终匹配了所有异常类型，代码就会继续执行

- 在 try { } catch{ } 中，try 代码块中生成异常实例，那么就会在当前方法的 异常表中进行匹配





```
public static String func() {
	String str = "hello";
	try{
		return str;
	}
	finally{
		str = "atguigu";
	}
}

// 最终返回结果   hello 

0 ldc #17 <hello>
2 astore_0            // 存储进局部变量表的索引 0
3 aload_0             **  3 - 5 是 try 的核心字节码指令
4 astore_1            // 索引 1 和 索引 0，都是 str = "hello"
5 ldc #18 <atguigu>   **
7 astore_0            //索引 0 str = "atguigu"，索引 1 str = "hello"                    
8 aload_1             // 加载 索引 1 的 str 
9 areturn			  // 最终返回 str = "hello"
                       // 以下是遇到 Exception 时，直接跳转到 10 ，与异常表进行匹配
10 astore_2            //在栈中生成的异常实例，存入到局部变量表中 index = 2
11 ldc #18 <atguigu>   // 执行 finally
13 astore_0
14 aload_2             // 把异常实例加载进栈，然后弹出
15 athrow
```



### 同步控制指令

方法级的同步 和 方法内部一段指令序列的同步，这两种同步都是使用 monitor 来支持的

- 方法级的同步 是隐式的，无须













## 虚拟机类加载机制



Java 中数据类型分为基本数据类型和引用数据类型。**基本数据类型** 由虚拟机预先定义，**引用数据类型** 则需要进行类的加载

#### 过程一：Loading (加载)阶段



#### 过程二：Linking 阶段

链接阶段的验证虽然拖慢了加载速度，但是它避免了在字节码运行时还需要进行各种检查。（磨刀不误砍柴工）

##### 

##### 验证：

栈映射帧 (StackMapTable)：用于检测在特定的字节码处，其局部变量表和操作数栈是否有着正确的数据类型，但是 100% 准确地判断一段字节码是否可以被安全执行是无法实现的，因此，该过程只是尽可能地检查出可以预知地明显地问题，如果在这个阶段无法通过检查，虚拟机也不会正确装载这个类，如果通过了这个阶段的检查，也不能说明这个类是完全没有问题的。

##### 准备：

- Java 并不支持 boolean 类型，对于 boolean 类型，内部实现是 int，由于 int 的默认值是 0，故对应的，boolean 的默认值就是 false

```
public static final int num = 1;        //

public static final String constStr = "const";

public static final String constStr2 = new String("const2");
```



##### 解析：

- 以方法为例：Java 虚拟机为每个类都准备了一张方法表，将其所有的方法都列在表中，当需要调用一个类的方法的时候，只要知道这个方法在方法表中的偏移量就可以直接调用该方法。**通过解析操作，符号引用就可以转变为目标方法在类中方法表中的位置，从而使得方法被成功调用**

- 所谓符号引用就是将符号引用转为直接引用，也就是得到类、字段、方法在内存中的指针或偏移量。因此，可以说，如果直接引用存在，那么可以肯定系统中存在该类、方法或字段。但只存在符号引用，不能确定系统中一定存在该结构。



#### 过程三：Initialization 阶段

作用：为类的静态变量赋予正确的初始值



说明：使用 static + final 修饰的字段的显式赋值的操作，到底是在哪个阶段进行的赋值。

- 情况1：在链接阶段的 准备  环节赋值
- 情况2：在初始化阶段  **<clinit>()** 赋值



```
// 对应非静态字段，不管是否进行了显式赋值，都不会生成 <clinit>() 方法
public int num = 1;

//静态的字段，没有显式赋值，不会生成 <clinit>() 方法
public static int num1;

//静态字段，显式赋值，生成 <clinit>() 方法
public static int num2 = 1;

//对于声明为 static final 的基本数据类型的字段，不管是否进行了显式赋值，都不会生成 <clinit>() 方法
public static final int num3 = 1;

public static final Integer integer_constant1 = Integer.ValueOf(100);      //在初始化阶段 <clinit>() 中赋值

public static Integer integer_constant2 = Integer.ValueOf(1000);           //在初始化阶段 <clinit>() 中赋值

public static String s1 = "111";                       // 在初始化阶段 <clinit>() 赋值

public static final String s2 = "helloWord01";         // 在链接阶段的 准备环节赋值
	
public static final String s3 = new String("helloWord02");         // 在初始化阶段 <clinit>() 赋值
```





**结论**

在链接阶段的 准备 环节赋值的情况

- 1.对于 基本数据类型 的字段来说，若使用 static final 修饰，则显式赋值(**直接赋值常量，而非调用方法**)通常是在 链接阶段的准备环节进行
- 2.对于 String 来说，若使用 字面量 赋值，使用 static final 修饰，则显式赋值通常是在链接阶段的准备环节进行





#### 过程四：类的使用



Java 程序对类的使用分为两种：主动使用、被动使用

主动使用 和 被动使用 影响的是 初始化，是否调用 <clinit> () 方法



**注意：此处说的初始化（调用 <clinit>() 方法），是类加载子系统的最后一步，加载、验证、准备、解析、初始化。**



##### 一、主动使用

**意味着会调用类的  <clinit>()，即执行了类的初始化阶段**

Class 只有在必须首次使用的时候才会被装载，Java 虚拟机不会无条件装载 Class 类型，Java 虚拟机规定，一个类或接口初次使用前，必须进行初始化。这里指的“使用”，是指主动使用。

- 1.当创建一个类的实例时，比如使用 new 关键字，或者通过反射、克隆、反序列化。

  - 反序列化：把 Java 对象文件数据恢复到 Java 对象中			

- 2.当调用类的静态方法时，即当使用了字节码 invokestatic 指令。

- 3.当使用类、接口的静态字段时**（final 修饰特殊考虑）**，比如使用 getstatic、putstatic 指令（访问变量、赋值变量）

- 4.当使用 java.lang.reflect 包中的方法反射类的方法时

  - 比如：Class.forName（"com.atguigu.java.Test"）

- 5.当初始化子类时，如果发现其父类还未初始化，则需要先出发父类的初始化。

  - 当 Java 虚拟机初始化一个类的时候，要求它的所有父类都已经被初始化，但是这条规则并不是用于接口
  - 在初始化一个类时，并不会初始化它所实现的接口
  - 在初始化一个接口时，并不会先初始化它的父接口

  因此，一个父接口并不会因为它的子接口 或 实现类 的初始化而初始化，只有当程序首次使用特定接口的静态字段时，才会导致该接口的初始化。

- 6.如果一个接口定义了 default 方法，那么直接实现或者间接实现该接口的类的初始化，该接口要在其之前初始化

- 7.当虚拟机启动时，用户需要指定一个要执行的主类（包含 main（）方法的那个类），虚拟机会先初始化这个主类

- 8.当初次调用 MethodHandle 实例时，初始化该 MethodHandle 指向方法所在的类 







```
// Order 是 Java 对象,验证了反序列化也会执行 初始化
ObjectInputStream ois = new ObjectInputStream(new FileInputStream("order.dat"));
Order order = (Order)ois.readObject();
ois.close();


```



访问 CompareA.Num2 时，会主动初始化

访问 CompareA.Num1、CompareA.Num2 时不会初始化 

	interface CompareA{
		public static int Num1 = 1;          // 接口默认有 final
		public static final int Num2 = 1;
		public static final int Num3 = new Random().nextInt(10);
		public static final Thread t = new Thread() {
			{
				System.out.println("CompareA 的初始化");	
			}
		};
	}



##### 二、被动使用

**并不是在代码中的出现的类，就一定会被加载或者初始化。如果不符合主动使用的条件，类就不会被初始化。**

- 1.当访问一个 static field ，只有真正声明这个字段的类才会被初始化

  ​			当通过子类引用父类的静态变量，不会导致子类初始化

- 2.通过数组定义类引用，不会出发此类的初始化

- 3.引用常量不会触发此类或接口的初始化，因为常量在链接阶段就已经被显式赋值了

- 4.调用 ClassLoader 类的 loadClass ( ) 方法加载一个类，并不是对类的主动使用，不会导致类的初始化。



说明：没有初始化的类，不意味着没有加载！



```
Class class = ClassLoader.getSystemClassLoader().loadClass("com.atguigu.java1.Person");
```





#### 过程五：类的 Unloading



##### 一、类、类的加载器、类的实例之间的引用关系

在类加载器的内部实现中，用一个 Java 集合来存放所加载类的引用。另一方面，一个 Class 对象总是会引用它的类加载器，调用 Class 对象的 getClassLoader ( ) 方法，就能获得它的类加载器。由此可见，代表某个类的 Class 实例与其类的加载器之间为双向关联关系。

- 类加载器可以获取已加载的 Class 对象，Class 对象可以获取加载自己的 类加载器。




一个类的实例总是引用代表这个类的 Class 对象，在 Object 类中定义了 getClass（）方法，这个方法返回代表对象所属类的 Class 对象。

- 所有的 Java 类都有一个静态属性 class，它引用代表这个类的 Class 对象。



##### 二、类的生命周期

当 Sample 类被加载、链接、初始化后，它的生命周期就开始了。当代表 Sample 类的 Class对象不再被引用，即不可触及时，Class对象就会结束生命周期，Sample 类在方法区内的数据也会被卸载，从而结束 Sample类的生命周期。

- 一个类何时结束生命周期，取决于代表它的 Class对象何时结束生命周期

- loader1变量 与 obj 引用变量 间接应用 Simple 类的 Class对象，而 objClass 引用变量直接引用。




![1](F:\自我总结qwq\Typora文件\宋红康 JVM 照片\1.png)





##### 三、类的卸载

- 启动类加载器加载的类型在整个运行期间是不可能被卸载的（jvm 和 jls规范）
- 被系统类加载器和扩展类加载器加载的类型在运行期间不太可能被卸载，因为系统类加载器实例或者扩展类加载器实例基本上在整个运行期间总能直接或间接访问到，其达到 unreachable 的可能性极小。
- 被开发者自定义的类加载器实例加载的类型只有在很简单的上下文环境中才能被卸载，而且一般还要借助于强制调用虚拟机的垃圾收集功能才可以做到

总结：一个已经加载的类型被卸载的概率极其小，至少被卸载的时间是不确定的，同时我们可以看出来，开发者在开发代码的时候，不应该对虚拟机的类型卸载做任何假设的前提下，来实现系统中特定的功能。





## 类加载器

CLassLoader 是 Java 的核心组件，所有的Class都是由ClassLoader进行加载的，ClassLoader负责通过各种方式将 Class 信息的二进制数据流读入 JVM 内部，转换为一个与目标类对应的 java.lang.Class 对象实例，然后交给Java 虚拟机进行链接、初始化等操作



- 每个类加载器都有自己的命名空间，命名空间由该加载器及所有的父加载器所加载的类组成
- 在同一命名空间中，不会出现类的完整名字（包括类的包名）相同的两个类
- 在不同的命名空间中，有可能会出现类的完整名字（包括类的报名）相同的两个类

在大型应用中，我们往往借助这一特性，来运行同一个类的不同版本。

### 概叙

#### 一、类加载器的分类

class 文件的显式加载与隐式加载的方式是指 JVM 加载 class 文件到内存的方式

- 显式加载：通过代码调用 ClassLoader 加载 class对象		
  - 比如：Class.forNmae(name)、this.getClass().getClassLoader().loadClass() 加载 class 对象

- 隐式加载：不直接在代码中调用 ClassLoader 的方法加载 class 对象，而是通过虚拟机自动加载到内存中
  - 比如：在加载某个 class 文件时，该类的 class 文件中引用了另外一个类的对象，此时额外引用的类将通过 JVM 自动加载到内存







- 除了顶层的启动类加载器外，其余的类加载器都应当有自己的 “父类” 加载器

- 不同类加载器看似是继承（Inheritance）关系，实际上是包含关系，在下层加载器中，包含着对上层加载器的引用（属性）



### 二、测试不同的类加载器

Launcher 类的构造器中会初始化 扩展类加载器、应用程序类加载器

- 设置当前线程下上文的 CLassLoader

| **获得当前类的 ClassLoader：class.getClassLoader()**         |
| ------------------------------------------------------------ |
| **获得当前线程上下文的 ClassLoader（其实就是应用程序类加载器）：Thread.currentThread().getContextClassLoader()** |
| **获得系统的 ClassLoader（AppClassLoader）：ClassLoader.getSystemClassLoader()** |



说明：

​		数组类的 Class 对象，不是由类加载器去创建的，而是在 Java 运行期间 JVM 根据需要自动创建的。对于数组类的类加载器来说，是通过 Class.getClassLoader() 返回的，与数组当中元素类型的类加载器是一样的；如果数组当中的元素类型是基本数据类型，数组类是没有类加载器的。

```
int[] arr2 = new int[10];
System.out.println(arr2.getClass().getClassLoader());   //null,表示不需要 ClassLoader

String[] arrstr = new String[10]; 
System.out.println(arrstr.getClass().getClassLoader());   //null,表示使用的是启动类加载器

```





### 三、ClassLoader 源码解析



![2](F:\自我总结qwq\Typora文件\宋红康 JVM 照片\2.png)



继承关系说明：

- URLClassLoader 类重写了 findClass(String)，ExtClassLoader 与 AppClassLoader 使用的就是 URLClassLoader 的findCLass(String)。





#### 1.ClassLoader 的主要方法

- **public final ClassLoader getParent（）**：返回该加载器的超类加载器

- **public Class<?> loadClass(String name) throws ClassNotFoundException**

  - 加载名称为 name 的类，返回结果为 java.lang.Class类的实例，如果找不到类，返回 ClassNotFoundException 异常，**该方法的逻辑就是双亲委派模式的实现**

- **protected Class<?> findClass(String name) throws ClassNotFoundClass**

  - 查找名称为 name 的类，返回结构为 java.lang.Class类的实例，这是一个受保护的方法，JVM 鼓励我们重写此方法，需要自定义加载器遵循双亲委托机制，该方法会在检查完父类加载器之后被 loadClass（）方法调用。

  - 从代码中可以看出，findClass（）是在 loadClass（）中被调用的，当loadClass（）中父加载器加载失败后，则会调用自己的 findClass（）来完成对类的加载，这样就可以保证自定义的类加载器也符合双亲委派模式。
  - 需要注意的是 ClassLoader 类中并没有实现 findClass（）的具体代码逻辑，直接 throw new ClassNotFoundException(name); 异常，findClass（）通常是和 defineClass（）一起使用，一般情况下，在自定义类加载器时，会直接覆盖 ClassLoader 类的 findClass（）并编写加载规则，取得要加载类的字节码后转换成流，然后调用 defineClass（）生成类的 Class 对象



- **protected final Class<?> defineClass(String name，byte[ ] b，int off，int len)**
  - 根据给定的字节数组 b 转换为 Class 的实例，off 和 len 参数表示实际 Class 信息在 byte 数组中的位置和长度，其中 b 是 ClassLoader 从外部获取，是受保护的方法，只有在自定义 ClassLoader 子类中可以使用。
  - defineClass（）用来将 byte 字节流解析成 JVM 能够识别的 Class 对象 ( ClassLoader 中已实现该方法逻辑)，通过这个方法不仅能够 class 文件实例化 class 对象，也可以通过其它方式实例化 class 对象，如通过网络接收一个类的字节码，然后转换为 byte 字节流创建对应的 class 对象。



- **protected final void resolveClass (Class<?> c)**
  - 链接指定的一个 Java 类，使用该方法可以使用类的 Class 对象创建完成的同时也被解析。
- **protected final Class<?> findLoadedClass (String name)**
  - 查找名称为 name 的已经被加载过的类，返回结果为 java.lang.Class 类的实例，这个方法是 final 方法，无法被修改





```
protected Class<?> loadClass(String name, boolean resolve)     // resolve：true-加载class的同时进行解析操作,默认 false
    throws ClassNotFoundException
{
    synchronized (getClassLoadingLock(name)) {      //同步操作，保证只能加载一次
     
        Class<?> c = findLoadedClass(name);       //首先，先在本类的类加载器的缓存中是否已经加载同名的类
        
        if (c == null) {
            long t0 = System.nanoTime();
            try {
                if (parent != null) {   //获取当前类的父类加载器(ClassLoader parent)，
                    c = parent.loadClass(name, false);   //如果存在父类加载器，则调用父类加载器进行类的加载
                } else {                                 //parent = null：父类加载器是启动类加载器
                    c = findBootstrapClassOrNull(name);  //进行加载类，加载不了的话 c = null(涉及到 native 方法);
                }
            } catch (ClassNotFoundException e) {
            }

            if (c == null) {  //条件成立：当前类的加载器的父类加载器未加载此类 or 当前类的加载器未加载此类
            
                long t1 = System.nanoTime();
                c = findClass(name);          //  com.atguigu.User 这个最终在此处被加载
				
				//这是定义类装入器；记录统计信息
                sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                sun.misc.PerfCounter.getFindClasses().increment();
            }
        }
        if (resolve) {     //是否进行解析操作,默认false,只进行加载,不进行解析、初始化
            resolveClass(c);
        }
        return c;
    }
}
```

#### 2.SecureClassLoader 与 URLClassLoader

#### 3.ExtClassLoader 与 AppClassLoader

#### 4.Class.forName() 与 ClassLoader

- Class.forName()：是一个静态方法，最常用的 Class.forName (String className)；根据传入的类的全限定名返回一个 Class 对象。
  - 该方法将 Class 文件加载到内存的同时，会执行类的初始化
- ClassLoader.loadClass()：这是一个实例方法，需要一个 ClassLoader 对象来调用该方法
  - 该方法将 Class 文件加载到内存时，并不会执行类的初始化，直到这个类第一次使用时才进行初始化。该方法因为需要得到一个 ClassLaoder 对象，所以可以根据需要指定使用哪个类加载器；



### 四、双亲委派模型

优势：

- 避免类的重复加载，确保一个类的全局唯一性。
- 保护程序安全，防止核心 API 被随意篡改。



#### 双亲委派的弊端

检查一个类是否加载的委托过程是单向的，这个方式虽然从结构上说比较清晰，使各个 ClassLoader 的职责非常明确，但是同时会带来一个问题，即顶层的 ClassLoader 无法访问底层的 ClassLoader 所加载的类。

- 启动类加载器中的类为系统核心类：包括一些重要的系统接口，应用程序类加载器中为应用类，按照这种模式，应用类访问系统类自然是没有问题，但是系统类访问应用类就会出现问题，比如：系统类提供了一个接口，该接口需要在应用类中得以实现，该接口还绑定了一个工厂方法，用于创建该接口的实例，而接口与工厂方法都在启动类加载器中，这时，就会出现该工厂方法无法创建由应用类加载器加载的应用实例的问题
  - 也就是：启动类加载器加载接口和工厂方法，工厂方法需要创建一个应用类对象，但是应用类对象无法由启动类加载器加载，只能由应用程序类加载器加载，类加载器无法 由上往下访问，就会出现错误



结论：Java 虚拟机规范并没有明确要求类加载器的加载机制一定要使用双亲委派模型，只是建议使用这种方式而已。



那么有些场景需要上层类加载器去调用下层类加载器：破坏双亲委派机制



#### 破坏双亲委派机制

热替换：

- 是指在程序的运行过程中，不停止服务，只通过替换程序文件来修改程序的行为，**热替换的关键需求在于服务不能中断，修改必须立即表现正在运行的系统中**

- 对 Java 来说，热替换并发天生支持，如果一个类已经加载到系统中，通过修改类文件，并无法让系统再来加载并重定义这个类，因此，在 Java 中实现这一功能的一个可行的方法就是灵活运用 ClassLoader




### 五、沙箱安全机制

作用：

- 保护程序安全
- 保护 Java 原生的 JDK 代码



沙箱机制就是将 Java 代码限定在虚拟机（JVM）特定的运行范围中，并且严格限制代码对本地系统资源访问。通过这样的措施来保证对代码的有限隔离，防止对本地系统造成破坏。

- 系统资源：CPU、内存、文件系统、网络。不同级别的沙箱对这些资源访问的限制也可以不一样。
- 所有 Java 程序运行都可以指定沙箱，可以定制安全策略。











### 六、用户自定义类加载器

#### 为什么要自定义类加载器？

- 隔离加载类
- 修改类的加载方式
- 扩展加载源
  - 比如从数据库、网络、甚至是电视机机顶盒进行加载。
- 防止源码泄露
  - Java 代码容易被编译和篡改，可以进行编译加密。那么类加载器也需要自定义，还原加密的字节码。



优势：

- 通过类加载器可以实现非常绝妙的插件机制，类加载器为应用程序提供了一种动态增加新功能的机制，这种机制无须重新打包发布应用程序就能实现。
- 同时，自定义加载器能实现应用隔离
- 自定义加载器通常需要继承 ClassLoader



#### 注意事项：

在一般情况下，使用不同的类加载器去加载不同的功能模块，会提高应用程序的安全性。但是，如果涉及 Java 类型转换，则加载器反而容易产生不好的事情。在做 Java 类型转换时，只有两个类型都是由同一个 ClassLoader 所加载，才能进行类型转换，否则转换时会发生异常。





#### 1.实现方式

- Java 提供了抽象类 java.lang.ClassLoader，所有用户自定义的类加载器都应该继续 ClassLoader 类
  - ClassLoader 虽然是个抽象类，但是没有抽象方法，很多方法是空的，没有实现。
- 在自定义 ClassLoader 的子类时，常见的两种做法
  - 方式一：重写 loadClass（）方法
  - 方式二：重写 findClass（）方法



ClassLoader 是一个抽象类，很多方法是空的没有实现，比如 findClass（）、findResource（）等，而URLClassLoader 这个实现类为这些方法提供了具体实现，并新增了 URLClassPath 类协助取得 Class 字节码流等功能

- 在编写自定义类的时，如果没有太过复杂的需求，可以直接继承 URLClassLoader 类，可以避免自己去编写 findCLass（）及其获取字节码流的方式，使自定义类加载器更加简洁。





```
public class MyClassLoader extends ClassLoader {

    private String byteCodePath;

    public MyClassLoader(String byteCodePath) {
        this.byteCodePath = byteCodePath;
    }

    public MyClassLoader(ClassLoader parent, String byteCodePath) {
        super(parent);
        this.byteCodePath = byteCodePath;
    }

    @Override
    protected Class<?> findClass(String name) throws ClassNotFoundException {
        //获取字节码文件的完整路径
        String fileName = byteCodePath + name + ".class";

        try(
                BufferedInputStream bis = new BufferedInputStream(new FileInputStream(fileName));  //获取输入流
                ByteArrayOutputStream baos = new ByteArrayOutputStream();    //获取一个输出流
        )
        {
            int len;
            byte[] data = new byte[1024];

            while ((len = bis.read(data)) != -1) {
                baos.write(data, 0, len);
            }
            //获取内存中的完整的字节数组的数据
            byte[] byteCodes = baos.toByteArray();
            //调用 defineClass()，将字节数组的数据转换为 Class 的实例
            Class<?> aClass = defineClass(null, byteCodes, 0, byteCodes.length);  

            return aClass;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return null;
    }

}
```

## JDK9新特性

为了保证兼容性，JDK 9 没有从根本上改变三层类加载器架构和双亲委派模型，但为了模块化系统的顺利进行，仍然发生了一些值得注意的地方

启动类加载器：BootClassLoader

平台类加载器：PlatformClassLoader

应用类加载器：AppClassLoader



**启动类加载器、平台类加载器、应用程序类加载器全都继承于 jdk.internal.loader.BuiltinClassLoader**



- **扩展机制被移除：扩展类加载器由于向后兼容性的原因被保留，被重命名为 平台类加载器（platform class loader）**
  - 可以通过 ClassLoader 的新方法 getPlatformClassLoader（）来获取
- **平台类加载器和应用程序类加载器都不在继承自  java.net.URLClassLoader**
  - 启动类加载器、平台类加载器、应用程序类加载器全都继承于 jdk.internal.loader.BuiltinClassLoader

- **启动类加载器现在是在 JVM 内部和 java 类库共同协作实现的类加载器（以前是 C++实现），但为了与之前代码兼容，在获取启动类加载器的场景中仍然会返回 null，而不会得到 BootClassLoader 实例。**
- **类加载的委派关系也发生了变化**
  - 当 PlatformClassLoader 与 AppClassLoader 收到类加载请求时，在委派给父加载器前，要先判断该类是否能够归属到某一个系统模块中，如果可以找到这样的归属关系，就要优先委派给负责那个模块的加载器完成加载。





JDK8

```
System.out.pringtln(A.class.getClassLoader());
System.out.pringtln(A.class.getClassLoader().getParent());
System.out.pringtln(A.class.getClassLoader().getParent().getParent());

sun.misc.Launcher$AppClassLoader@18b4aac2
sun.misc.Launcher$ExtClassLoader@7440e464
null
```

JDK9

```
System.out.pringtln(A.class.getClassLoader());
System.out.pringtln(A.class.getClassLoader().getParent());
System.out.pringtln(A.class.getClassLoader().getParent().getParent());

jdk.internal.loader.ClassLoaders$AppClassLoader@726f3b58
jdk.internal.loader.ClassLoaders$PlatformClassLoader@73f9ac
null
```































