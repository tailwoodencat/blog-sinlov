---
title: "AOP in Android"
date: 2021-02-23T11:24:21+08:00
description: "desc AOP in Android"
draft: true
categories: ['Android']
tags: ['Android']
toc:
  enable: true
  auto: false
math:
  enable: false
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## AOP 是什么

AOP [wiki Aspect-oriented programming](https://en.wikipedia.org/wiki/Aspect-oriented_programming), 意为：面向切面编程，通过预编译方式和运行期动态代理实现程序功能的统一维护的一种技术。

是[函数式编程](https://en.wikipedia.org/wiki/Functional_programming)的一种衍生范型。利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高了开发的效率。

简单的来讲，AOP是一种：可以在不改变原来代码的基础上，通过 `动态注入` 代码，来改变原来执行结果的技术

### AOP 能做什么

- 持久化
- 日志
- 性能监控
- 数据校验
- 缓存
- 埋点统计

> tips: 更多运用见 [https://en.wikipedia.org/wiki/Cross-cutting_concern](https://en.wikipedia.org/wiki/Cross-cutting_concern)

## AspectJ

AspectJ 是 Android 平台上一种比较高效和简单的实现 AOP 技术的方案

相类似的方案有以下几种:

- [AspectJ](https://eclipse.org/aspectj/): 一个 JavaTM 语言的面向切面编程的无缝扩展（适用Android）。
- [Javassist](https://github.com/crimsonwoods/javassist-android): for Android ：用于字节码操作的知名 java 类库 Javassist 的 Android 平台移植版。
- [DexMaker](https://code.google.com/p/dexmaker/): Dalvik 虚拟机上，在编译期或者运行时生成代码的 Java API。
- [ASMDEX](http://asm.ow2.org/asmdex-index.html): 一个类似 ASM 的字节码操作库，运行在Android平台，操作Dex字节码。

### AspectJ 术语

- `JPoint`：代码可注入的点，比如一个方法的调用处或者方法内部、`读、写`变量等
- `Pointcut`：用来描述 JPoint 注入点的一段表达式，比如：调用 Animal 类 fly 方法的地方
- `Advice`：常见的有 `Before、After、Around` 等，表示代码执行前、执行后、替换目标代码，也就是在 Pointcut 何处注入代码
- `Aspect`：Pointcut 和 Advice 合在一起称作 Aspect

### AspectJ 引入配置

在 `build.grade` 加入以下配置项

```gradle
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'org.aspectj:aspectjtools:1.8.1'
    }
}
```

在 module 的 build.gradle 中配置

```gradle
import org.aspectj.bridge.IMessage
import org.aspectj.bridge.MessageHandler
import org.aspectj.tools.ajc.Main

dependencies {
    implementation 'org.aspectj:aspectjrt:1.8.1'
}

final def log = project.logger
final def variants = project.android.applicationVariants

variants.all { variant ->
    if (!variant.buildType.isDebuggable()) {
        log.debug("Skipping non-debuggable build type '${variant.buildType.name}'.")
        return;
    }

    JavaCompile javaCompile = variant.javaCompile
    javaCompile.doLast {
        String[] args = ["-showWeaveInfo",
                     "-1.5",
                     "-inpath", javaCompile.destinationDir.toString(),
                     "-aspectpath", javaCompile.classpath.asPath,
                     "-d", javaCompile.destinationDir.toString(),
                     "-classpath", javaCompile.classpath.asPath,
                     "-bootclasspath", project.android.bootClasspath.join(File.pathSeparator)]
        log.debug "ajc args: " + Arrays.toString(args)

        MessageHandler handler = new MessageHandler(true);
        new Main().run(args, handler);
        for (IMessage message : handler.getMessages(null, true)) {
           switch (message.getKind()) {
                case IMessage.ABORT:
                case IMessage.ERROR:
                case IMessage.FAIL:
                    log.error message.message, message.thrown
                    break;
                case IMessage.WARNING:
                    log.warn message.message, message.thrown
                    break;
                case IMessage.INFO:
                    log.info message.message, message.thrown
                    break;
                case IMessage.DEBUG:
                    log.debug message.message, message.thrown
                    break;
            }
        }
    }
}
```

### AspectJ 例子

#### Method -> call

定义一个 Animal 类，包含一个 fly 方法

```java
public class Animal {
    private static final String TAG = "Animal";
    public void fly() {
        Log.e(TAG, this.toString() + "#fly");
    }
}
```

在调用 fly 的地方，之前插入一段代码

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "ConstructorAspect";

    @Pointcut("call(* android.aspectjdemo.animal.Animal.fly(..))")
    public void callMethod() {}

    @Before("callMethod()")
    public void beforeMethodCall(JoinPoint joinPoint) {
        Log.e(TAG, "before->" + joinPoint.getTarget().toString() + "#" + joinPoint.getSignature().getName());
    }
}
```

使用 `@Pointcut` 来注解方法，定义具体的 `Pointcut` ，`call(MethodSignature)` 关键字表示方法被调用

调用 fly 之前插入一段代码，所以 Advice 需要使用 @Before，@Before 的参数就是 使用 `@Pointcut` 注解的方法名称

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "MethodAspect";

    @Before("call(* android.aspectjdemo.animal.Animal.fly(..))")
    public void beforeMethodCall(JoinPoint joinPoint) {
        Log.e(TAG, "before->" + joinPoint.getTarget().toString() + "#" + joinPoint.getSignature().getName());
    }
}
```

最后，就是在 MethodAspect 加上 `@Aspect` 注解，这样 AspectJ 在编译时会查找被 @Aspect 注解的 class，然后 AOP 的过程会自动完成

编译运行之后，可以在 `app/build/intermediates/classes/debug` 目录查看编译后的 class 文件

```
Animal animal = new Animal();
JoinPoint var5 = Factory.makeJP(ajc$tjp_0, this, animal);
MethodAspect.aspectOf().beforeMethodCall(var5);
animal.fly();
```

animal.fly() 之前插入了一段代码，调用就是 MethodAspect#beforeMethodCall 方法

如果使用 `@After` 类型的 Advice，则会在animal.fly() 之后插入

```java
...
Animal animal = new Animal();
Animal var6 = animal;
JoinPoint var5 = Factory.makeJP(ajc$tjp_0, this, animal);

try {
    var6.fly();
} catch (Throwable var9) {
    MethodAspect.aspectOf().afterMethodCall(var5);
    throw var9;
}

MethodAspect.aspectOf().afterMethodCall(var5);
...
```

`@Around` 会替换原先执行的代码，但如果你仍然希望执行原先的代码，可以使用 `joinPoint.proceed()`


#### Method -> execution

与 call 类似，只不过执行点(JPoint)在方法内部

比如：我们希望在 fly 方法的 `Log.e(TAG, this.toString() + "#fly")` 这段代码执行前，插入一段代码

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "MethodAspect";

    @Before("execution(* android.aspectjdemo.animal.Animal.fly(..))")
    public void beforeMethodExecution(JoinPoint joinPoint) {
        Log.e(TAG, "before->" + joinPoint.getTarget().toString() + "#" + joinPoint.getSignature().getName());
   }
}
```

execution 关键字表示方法执行内部，编译后 class 文件如下

```java
public void fly() {
    JoinPoint var1 = Factory.makeJP(ajc$tjp_1, this, this);
    MethodAspect.aspectOf().beforeMethodExecution(var1);
    Log.e("Animal", this.toString() + "#fly");
}
```

#### Constructor -> call & execution

Constructor 和 Method 几乎一模一样，最大的区别就在 Signature

`Constructor 没有返回值类型，且函数名只能是 new`

```java
@Aspect
public class ConstructorAspect {
    private static final String TAG = "ConstructorAspect";

    @Before("execution(android.aspectjdemo.animal.Animal.new(..))")
    public void beforeConstructorExecution(JoinPoint joinPoint) {
        Log.e(TAG, "before->" + joinPoint.getThis().toString() + "#" + joinPoint.getSignature().getName());
    }
}
```

#### Field -> get

Animal 包含年龄age属性、返回age的getAge方法

```
public class Animal {
    private static final String TAG = "Animal";
    private int age;

    public Animal() {
        this.age = 10;
    }

    public int getAge() {
        Log.e(TAG, "getAge: ");
        return this.age;
    }
}
```

比如，我们希望不管怎么修改 age 的值，最后获取的 age 都为100，那么就需要替换访问 age

```java
@Aspect
public class FieldAspect {
    private static final String TAG = "FieldAspect";

    @Around("get(int android.aspectjdemo.animal.Animal.age)")
    public int aroundFieldGet(ProceedingJoinPoint joinPoint) throws Throwable {
       // 执行原代码
       Object obj = joinPoint.proceed();
       int age = Integer.parseInt(obj.toString());
       Log.e(TAG, "age: " + age);
       return 100;
   }
}
```
编译后的class

```java
public int getAge() {
    Log.e(TAG, "getAge: ");
    JoinPoint var2 = Factory.makeJP(ajc$tjp_2, this, this);
    FieldAspect var10000 = FieldAspect.aspectOf();
    Object[] var3 = new Object[]{this, this, var2};
    return var10000.aroundFieldGet((new Animal$AjcClosure3(var3)).linkClosureAndJoinPoint(4112));
}
```

原先的 this.age 已经被替换成调用 FieldAspect#aroundFieldGet 方法

#### Field -> set & withincode

与 get 对应的是 set：表示修改某个属性，比如setAge方法中的 `this.age = age`

```java
public class Animal {
    private static final String TAG = "Animal";
    private int age;

    public Animal() {
        this.age = 10;
    }

    public void setAge(int age) {
        Log.e(TAG, "setAge: ");
        this.age = age;
    }
}
```

假如我们希望替换这段代码，让调用方无法改变 age

```java
@Aspect
public class FieldAspect {
    private static final String TAG = "FieldAspect";

    @Around("set(int android.aspectjdemo.animal.Animal.age)")
    public void aroundFieldSet(ProceedingJoinPoint joinPoint) throws Throwable {
        Log.e(TAG, "around->" + joinPoint.getTarget().toString() + "#" + joinPoint.getSignature().getName());
    }
}
```

编译后的 class

```java
public class Animal {
    private static final String TAG = "Animal";
    private int age;

    public Animal() {
        Log.e("Animal", "Animal构造函数");
        byte var1 = 10;
        JoinPoint var3 = Factory.makeJP(ajc$tjp_0, this, this, Conversions.intObject(var1));
        FieldAspect var10000 = FieldAspect.aspectOf();
        Object[] var4 = new Object[]{this, this, Conversions.intObject(var1), var3};
        var10000.aroundFieldSet((new Animal$AjcClosure1(var4)).linkClosureAndJoinPoint(4112));
    }

    public void setAge(int age) {
        Log.e("Animal", "setAge: ");
        JoinPoint var4 = Factory.makeJP(ajc$tjp_3, this, this, Conversions.intObject(age));
        FieldAspect var10000 = FieldAspect.aspectOf();
        Object[] var5 = new Object[]{this, this, Conversions.intObject(age), var4};
        var10000.aroundFieldSet((new Animal$AjcClosure5(var5)).linkClosureAndJoinPoint(4112));
    }
}
```

setAge方法中的 `this.age = age` 的确被替换了，但是原先构造函数初始化age的代码：`this.age = 10` 也被替换

#### withincode

我们要排除 Animal 的构造函数修改age的 JPoint，可以这样写

```java
@Aspect
public class FieldAspect {
    private static final String TAG = "FieldAspect";

    @Around("set(int android.aspectjdemo.animal.Animal.age) && !withincode(android.aspectjdemo.animal..*.new(..))")
    public void aroundFieldSet(ProceedingJoinPoint joinPoint) throws Throwable {
        Log.e(TAG, "around->" + joinPoint.getTarget().toString() + "#" + joinPoint.getSignature().getName());
    }
}
```

Pointcut 多个条件使用 `&&、||` 运算符连接，`!`表示否的意思

编译后的class，构造函数中的 JPoint 已经被排除

```java
public class Animal {
    private static final String TAG = "Animal";
    private int age;

    public Animal() {
        Log.e("Animal", "Animal构造函数");
        this.age = 10;
    }

    public void setAge(int age) {
        Log.e("Animal", "setAge: ");
        JoinPoint var4 = Factory.makeJP(ajc$tjp_3, this, this, Conversions.intObject(age));
        FieldAspect var10000 = FieldAspect.aspectOf();
        Object[] var5 = new Object[]{this, this, Conversions.intObject(age), var4};
        var10000.aroundFieldSet((new Animal$AjcClosure5(var5)).linkClosureAndJoinPoint(4112));
    }
}
```

#### staticinitialization

JPoint 为static块初始化内

```java
public class Animal {
    private static final String TAG = "Animal";

    static {
        Log.e(TAG, "static block");
    }
}
```

如果要在 static 块初始化之前，插入代码

```java
@Aspect
public class StaticInitializationAspect {
    private static final String TAG = "StaticAspect";

    @Before("staticinitialization(android.aspectjdemo.animal.Animal)")
    public void beforeStaticBlock(JoinPoint joinPoint) {
        Log.d(TAG, "beforeStaticBlock: ");
    }
}
```

编译后的 class

```java
public class Animal {
    private static final String TAG = "Animal";

    static {
        ajc$preClinit();
        JoinPoint var0 = Factory.makeJP(ajc$tjp_3, (Object)null, (Object)null);
        StaticInitializationAspect.aspectOf().beforeStaticBlock(var0);
        Log.e("Animal", "static block");
    }
}
```

#### handler

用来匹配 catch 的异常，比如 Animal 的 hurt 方法

```java
public class Animal {
    public void hurt(){
        try {
            int i = 4 / 0;
        } catch (ArithmeticException e) {
            e.printStackTrace();
        }
    }
}
```

如果我们需要统计所有出现 ArithmeticException 的点，则可以使用 handler

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "MethodAspect";
    /**
     * handler
     * 不支持@After、@Around
     */
    @Before("handler(java.lang.ArithmeticException)")
    public void handler() {
        Log.e(TAG, "handler");
    }
}
```

注意: `handler 不支持 @After 与 @Around，且异常只支持编译时匹配`，也就是

> handler(java.lang.Exception) 无法匹配 java.lang.ArithmeticException，虽然 ArithmeticException 继承自 Exception

#### Advice 异常收集 @AfterThrowing

@AfterThrowing 属于 @After 的变种，方法的结束包括两种状态：**正常结束和异常退出**

我们经常需要收集抛出异常的方法信息，这时候可以使用 @AfterThrowing

比如 Animal 的hurtThrows会抛出 java.lang.ArithmeticException 异常

```java
public class Animal {
    public void hurtThrows(){
        int i = 4 / 0;
    }
}
```

可以这样收集异常

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "MethodAspect";

    @AfterThrowing(pointcut = "call(* *..*(..))", throwing = "throwable")
    public void anyFuncThrows(Throwable throwable) {
        Log.e(TAG, "hurtThrows: ", throwable);
    }
}
```

`call(* *..*(..))` 表示任意类的任意方法，被调用的 JPoint

`throwing = "throwable"` 描述了异常参数的名称，也就是 `anyFuncThrows` 方法中的参数 throwable

需要强调几点

1. @AfterThrowing 不支持 Field -> get & set，一般用在 Method 和 Constructor
2. 捕获的是抛出异常的方法，即使这个方法的调用方已经处理了此异常，比如

```java
try {
    animal.hurtThrows();
} catch (Exception e) {}
```

即使这样，MethodAspect#anyFuncThrows 也会被触发

#### Advice 正常结束 @AfterReturning & args

**正常结束**，指的是有返回值的方法

假如 Animal 有两个getHeight方法

```java
public class Animal {
    public int getHeight() {
        return 0;
    }

    public int getHeight(int sex) {
        switch (sex) {
            case 0:
                return 163;
            case 1:
                return 173;
        }
        return 173;
    }
}
```

想要拿到 getHeight 的返回值，做一些其他事情（比如，数据统计、缓存等），可以这样做

```java
@Aspect
public class MethodAspect {
    private static final String TAG = "MethodAspect";

    @AfterReturning(pointcut = "execution(* android.aspectjdemo.animal.Animal.getHeight(..))", returning = "height")
    public void getHeight(int height) {
        Log.d(TAG, "getHeight: " + height);
    }
}
```

- 如果你调用 animal.getHeight() ，此方法会得到0
- 如果你调用 animal.getHeight(0) ，此方法会得到163

如果你只对getHeight(int sex)感兴趣，有两种做法

1. Pointcut 中表示任意参数的 .. 改为 int

```java
@AfterReturning(pointcut = "execution(* android.aspectjdemo.animal.Animal.getHeight(int))", returning = "height")
```

2. && args(int)

```java
@AfterReturning(pointcut = "execution(* android.aspectjdemo.animal.Animal.getHeight(..)) && args(int)", returning = "height")
```

#### Android 实战例子-权限注入

在实际项目中，经常碰到的一个问题：Android M 6.0+ 之后危险权限需要动态申请

如果有一些老的项目需要适配，一般做法是去修改原有的代码，比如我们有一个启动相机拍照的方法

```java
public void camera() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(getExternalCacheDir() + "photo.jpg")));
    startActivity(intent);
}
```

可能需要这么改

```java
Utils.requestPermisson(this, Manifest.permission.CAMERA).callback(new Callback(){
    public void onGranted(){
        camera();
    }
    public void onDenied() {}
});
```

如果你封装了请求权限工具类，这样改看起来也没什么问题，无非就是把所有类似的地方都加上这个段申请权限的代码

如果没有封装，只能是更痛苦。如果使用 AspectJ，可以通过一行注解，解决所有需要需要申请权限的方法

1. 定义注解

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface MPermisson {
    String value();
}
```

value 表示要申请的权限名称，比如Manifest.permission.CAMERA

编写 Aspect

```java
@Aspect
public class PermissonAspect {
    @Around("execution(@android.aspectjdemo.MPermisson * *(..)) && @annotation(permisson)")
    public void checkPermisson(final ProceedingJoinPoint joinPoint, MPermisson permisson) throws Throwable {
        // 权限
        String permissonStr = permisson.value();
        // 正常需要使用维护的栈顶Activity作为上下文，这里为了演示需要
        MainActivity mainActivity = (MainActivity) joinPoint.getThis();          // 权限申请

        Utils.requestPermisson(mainActivity, Manifest.permission.CAMERA).callback(new Callback(){
            public void onGranted(){
                try {
                    // 继续执行原方法
                    joinPoint.proceed();
                } catch (Throwable throwable) {
                    throwable.printStackTrace();
                }
            }
            public void onDenied() {}
      });
   }
}
```

`@annotation(permisson)` 用来表示 permisson 参数是注解类型

3. 使用 @MPermisson

在需要申请权限的方法上加上@MPermisson注解，其它代码不用做修改

```java
@MPermisson(value = Manifest.permission.CAMERA)
public void camera() {
    Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(getExternalCacheDir() + "photo.jpg")));
    startActivity(intent);
}
```

如果你项目中有其他地方，也需要申请权限，只需要在涉及到权限的方法上加上

```java
@MPermisson(value = "你的权限")
```

#### 写在最后

剩余的几个用法，比如

```
adviceexecution()、within(TypePattern)、cflow(pointcuts)、cflowbelow(pointcuts)、this(Type)、target(Type)
```

请自行学习了

