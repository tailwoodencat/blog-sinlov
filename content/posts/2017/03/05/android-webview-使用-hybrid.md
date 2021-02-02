---
title: "Android WebView 使用 Hybrid"
date: 2017-03-05T09:54:35+08:00
description: "desc Android WebView 使用 Hybrid"
draft: false
categories: ['Android']
tags: ['Android', 'WebView', 'Hybrid']
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

一般来说 Hybrid 是用在一些快速迭代试错的地方，另外一些非主要产品的页面，也可以使用 Hybrid 去做

但是如果是一些很重要的流程，使用频率很高，特别核心的功能，还是应该使用 Native 开发，让用户得到一个极致的产品体验

## WebView 常见设置

```java
WebSettings webSettings = webView.getSettings();

//设置了这个属性后我们才能在 WebView 里与我们的 Js 代码进行交互，对于 WebApp 是非常重要的，默认是 false，
//因此我们需要设置为 true，这个本身会有内存泄露风险，不要无脑使用
webSettings.setJavaScriptEnabled(true);

//设置 JS 是否可以打开 WebView 新窗口
webSettings.setJavaScriptCanOpenWindowsAutomatically(true);

// WebView 是否支持多窗口，如果设置为 true，需要重写
// WebChromeClient#onCreateWindow(WebView, boolean, boolean, Message) 函数，默认为 false
webSettings.setSupportMultipleWindows(true);

// 这个属性用来设置 WebView 是否能够加载图片资源，需要注意的是，这个方法会控制所有图片，包括那些使用 data URI 协议嵌入的图片。
// 使用 setBlockNetworkImage(boolean) 方法来控制仅仅加载使用网络 URI 协议的图片。
// 需要提到的一点是如果这个设置从 false 变为 true 之后，所有被内容引用的正在显示的 WebView 图片资源都会自动加载，该标识默认值为 true。
webSettings.setLoadsImagesAutomatically(false);
//标识是否加载网络上的图片（使用 http 或者 https 域名的资源），需要注意的是如果 getLoadsImagesAutomatically()
//不返回 true，这个标识将没有作用。这个标识和上面的标识会互相影响。
webSettings.setBlockNetworkImage(true);

//显示WebView提供的缩放控件
webSettings.setDisplayZoomControls(true);
webSettings.setBuiltInZoomControls(true);

//设置是否启动 WebView API，默认值为 false
webSettings.setDatabaseEnabled(true);

//打开 WebView 的 storage 功能，这样 JS 的 localStorage,sessionStorage 对象才可以使用
webSettings.setDomStorageEnabled(true);

//打开 WebView 的 LBS 功能，这样 JS 的 geolocation 对象才可以使用
webSettings.setGeolocationEnabled(true);
webSettings.setGeolocationDatabasePath("");

//设置是否打开 WebView 表单数据的保存功能
webSettings.setSaveFormData(true);
//设置 WebView 的默认 userAgent 字符串
webSettings.setUserAgentString("");
// 设置是否 WebView 支持 “viewport” 的 HTML meta tag，这个标识是用来屏幕自适应的，当这个标识设置为 false 时，
// 页面布局的宽度被一直设置为 CSS 中控制的 WebView 的宽度；如果设置为 true 并且页面含有 viewport meta tag，
// 那么被这个 tag 声明的宽度将会被使用，如果页面没有这个 tag 或者没有提供一个宽度，那么一个宽型 viewport 将会被使用。
webSettings.setUseWideViewPort(false);
// 设置 WebView 的字体，可以通过这个函数，改变 WebView 的字体，默认字体为 "sans-serif"
webSettings.setStandardFontFamily("");
// 设置 WebView 字体的大小，默认大小为 16
webSettings.setDefaultFontSize(20);
// 设置 WebView 支持的最小字体大小，默认为 8
webSettings.setMinimumFontSize(12);
// 设置页面是否支持缩放
webSettings.setSupportZoom(true);
// 设置文本的缩放倍数，默认为 100
webSettings.setTextZoom(2);
```

## WebViewClient 使用

最常用的 `WebViewClient` 和 `WebChromeClient`

> WebViewClient主要辅助WebView执行处理各种响应请求事件的

- onLoadResource
- onPageStart
- onPageFinish
- onReceiveError
- onReceivedHttpAuthRequest
- shouldOverrideUrlLoading

WebChromeClient 主要辅助 WebView 处理J avaScript 的对话框、网站 Logo、网站 title、load 进度等处理

- onCloseWindow(关闭WebView)
- onCreateWindow
- onJsAlert
- onJsPrompt
- onJsConfirm
- onProgressChanged
- onReceivedIcon
- onReceivedTitle
- onShowCustomView

WebView 只是用来处理一些 html 的页面内容，只用 WebViewClient 就行了，如果需要更丰富的处理效果，比如 JS、进度条等，就要用到 WebChromeClient

## WebView 加载页面

WebView 有四个用来加载页面的方法：

- loadUrl (String url)
- loadUrl (String url, Map<String, String> additionalHttpHeaders) 带头参数
- loadData(String data, String mimeType, String encoding)
- loadDataWithBaseURL(String baseUrl, String data, String mimeType, String encoding, String historyUrl)

loadData 方法会有一些坑，比如注意编码问题

WebView 是一个显示网页的控件，并且可以简单的显示一些在线的内容，并且基于 WebKit 内核

在 Android4.4(API Level 19) 引入了一个基于 Chromium 的新版本 WebView ，这让我们的 WebView 能支持 HTML5 和 CSS3 以及 Javascript

> 有一点需要注意的是由于 WebView 的升级，对于我们的程序也带来了一些影响，
>> 如果我们的 `targetSdkVersion 设置的是 18 或者更低`， `single and narrow column` 和 `default zoom levels` 不再支持。
> Android4.4 之后有一个特别方便的地方是可以通过 `setWebContentDebuggingEnabled()` 方法让我们的程序可以进行远程桌面调试。

## WebView 的几种缓存模式

- LOAD_CACHE_ONLY

不使用网络，只读取本地缓存数据

- LOAD_DEFAULT

根据 cache-control 决定是否从网络上取数据

- LOAD_CACHE_NORMAL

API level 17 中已经废弃, 从 API level 11 开始作用同 LOAD_DEFAULT 模式

- LOAD_NO_CACHE

不使用缓存，只从网络获取数据

- LOAD_CACHE_ELSE_NETWORK

只要本地有，无论是否过期，或者 no-cache，都使用缓存中的数据

## WebView 与 native 的交互

### js 调用 native

web 页面调用 native 的代码有三种方式

#### 通过 addJavascriptInterface 方法进行添加对象映射

```java
mWebView.getSettings().setJavaScriptEnabled(true);
```

> 这个函数会有一个警告，因为在特定的版本之下会有非常危险的漏洞，后面会介绍怎么处理这个问题

设置完这个属性之后，Native 需要定义一个类

```java
public class JSObject {
    private Context mContext;
    public JSObject(Context context) {
        mContext = context;
    }

    @JavascriptInterface
    public String showToast(String text) {
        Toast.show(mContext, text, Toast.LENGTH_SHORT).show();
        return "success";
    }
}
...
// 注意：特定版本下会存在漏洞
mWebView.addJavascriptInterface(new JSObject(this), "myObj");
```

> 需要注意的是在 API17 版本之后，需要在被调用的地方加上 @addJavascriptInterface 约束注解，因为不加上注解的方法是没有办法被调用的

JS 代码调用代码

```js
function showToast(){
    var result = myObj.showToast("我是来自web的Toast");
}
```

这种方式的好处在于使用简单明了，本地和 JS 的约定也很简单，就是对象名称和方法名称约定好即可，缺点就是下面要提到的漏洞问题

#### 利用 WebViewClient 接口回调方法拦截 url

WebViewClient ，其中有个回调接口 `shouldOverrideUrlLoading (WebView view, String url)`

[https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20java.lang.String)](https://developer.android.com/reference/android/webkit/WebViewClient#shouldInterceptRequest(android.webkit.WebView,%20java.lang.String))

我们就是利用这个拦截 url，然后解析这个 url 的协议，如果发现是我们预先约定好的协议就开始解析参数，执行相应的逻辑

注意这个方法在 API24 版本已经废弃了，需要使用 `shouldOverrideUrlLoading (WebView view, WebResourceRequest request)`

[https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20android.webkit.WebResourceRequest)](https://developer.android.com/reference/android/webkit/WebViewClient#shouldOverrideUrlLoading(android.webkit.WebView,%20android.webkit.WebResourceRequest))

替代，使用方法很类似，我们这里就使用 shouldOverrideUrlLoading (WebView view, String url) 方法

```java
public boolean shouldOverrideUrlLoading(WebView view, String url) {
    //假定传入进来的 url = "js://openActivity?arg1=111&arg2=222"，代表需要打开本地页面，并且带入相应的参数
    Uri uri = Uri.parse(url);
    String scheme = uri.getScheme();
    //如果 scheme 为 js，代表为预先约定的 js 协议
    if (scheme.equals("js")) {
          //如果 authority 为 openActivity，代表 web 需要打开一个本地的页面
        if (uri.getAuthority().equals("openActivity")) {
              //解析 web 页面带过来的相关参数
            HashMap<String, String> params = new HashMap<>();
            Set<String> collection = uri.getQueryParameterNames();
            for (String name : collection) {
                params.put(name, uri.getQueryParameter(name));
            }
            Intent intent = new Intent(getContext(), MainActivity.class);
            intent.putExtra("params", params);
            getContext().startActivity(intent);
        }
        //代表应用内部处理完成
        return true;
    }
    return super.shouldOverrideUrlLoading(view, url);
}
```

方法可以拦截 WebView 中加载 url 的过程，得到对应的 url，我们就可以通过这个方法，与网页约定好一个协议，如果匹配，执行相应操作

```js
function openActivity(){
    document.location = "js://openActivity?arg1=111&arg2=222";
}
```

就会触发本地的 `shouldOverrideUrlLoading` 方法，然后进行参数解析，调用指定方法

> 这个方式不会存在第一种提到的漏洞问题，但是它也有一个很繁琐的地方是`如果 web 端想要得到方法的返回值，只能通过 WebView 的 loadUrl 方法去执行 JS 方法把返回值传递回去`

相关的代码

```java
mWebView.loadUrl("javascript:returnResult(" + result + ")");
```

前端脚本

```js
function returnResult(result){
    alert("result is" + result);
}
```

第二种方式在返回值方面还是很繁琐的，但是在不需要返回值的情况下，比如打开 Native 页面，还是很合适的，制定好相应的协议，就能够让 web 端具有打开所有本地页面的能力

#### 利用 WebChromeClient 回调接口的三个方法拦截消息

方法的原理和第二种方式原理一样，都是拦截相关接口，只是拦截的接口不一样

```java
@Override
public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
    return super.onJsAlert(view, url, message, result);
}

@Override
public boolean onJsConfirm(WebView view, String url, String message, JsResult result) {
    return super.onJsConfirm(view, url, message, result);
}

@Override
public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, JsPromptResult result) {
    //假定传入进来的 message = "js://openActivity?arg1=111&arg2=222"，代表需要打开本地页面，并且带入相应的参数
    Uri uri = Uri.parse(message);
    String scheme = uri.getScheme();
    if (scheme.equals("js")) {
        if (uri.getAuthority().equals("openActivity")) {
            HashMap<String, String> params = new HashMap<>();
            Set<String> collection = uri.getQueryParameterNames();
            for (String name : collection) {
                params.put(name, uri.getQueryParameter(name));
            }
            Intent intent = new Intent(getContext(), MainActivity.class);
            intent.putExtra("params", params);
            getContext().startActivity(intent);
            //代表应用内部处理完成
            result.confirm("success");
        }
        return true;
    }
    return super.onJsPrompt(view, url, message, defaultValue, result);
}
```

WebViewClient 一样，这次添加的是 WebChromeClient 接口，可以拦截 JS 中的几个提示方法，也就是几种样式的对话框，在 JS 中有三个常用的对话框方法

- onJsAlert 方法是弹出警告框，一般情况下在 Android 中为 Toast，在文本里面加入\n就可以换行
- onJsConfirm 弹出确认框，会返回布尔值，通过这个值可以判断点击时确认还是取消，true表示点击了确认，false表示点击了取消
- onJsPrompt 弹出输入框，点击确认返回输入框中的值，点击取消返回 null

这三种对话框都是可以本地拦截到的，所以可以从这里去做一些更改，拦截这些方法，得到他们的内容，进行解析，比如如果是 JS 的协议，则说明为内部协议，进行下一步解析然后进行相关的操作即可，prompt 方法调用如下所示

```js
function clickprompt(){
    var result=prompt("js://openActivity?arg1=111&arg2=222");
    alert("open activity " + result);
}
```

> 这里需要注意的是 prompt 里面的内容是通过 message 传递过来的，并不是第二个参数的 url，返回值是通过 JsPromptResult 对象传递。为什么要拦截 onJsPrompt 方法，而不是拦截其他的两个方法，这个从某种意义上来说都是可行的，但是如果需要返回值给 web 端的话就不行了，因为 onJsAlert 是不能返回值的，而 onJsConfirm 只能够返回确定或者取消两个值，只有 onJsPrompt 方法是可以返回字符串类型的值，操作最全面方便。

### 以上三种方案的总结和对比

以上三种方案都是可行

- 第一种方式

是现在目前最普遍的用法，方便简洁，但是唯一的不足是在 4.2 系统以下存在漏洞问题；

- 第二种方式

通过拦截 url 并解析，如果是已经约定好的协议则进行相应规定好的操作，缺点就是协议的约束需要记录一个规范的文档，而且从 Native 层往 Web 层传递值比较繁琐，优点就是不会存在漏洞，iOS7 之下的版本就是使用的这种方式。

- 第三种方式

和第二种方式的思想其实是类似的，只是拦截的方法变了
这里拦截了 JS 中的三种对话框方法，而这三种对话框方法的区别就在于返回值问题

- alert 对话框没有返回值
- confirm 的对话框方法只有两种状态的返回值
- prompt 对话框方法可以返回任意类型的返回值，缺点就是协议的制定比较麻烦，需要记录详细的文档，但是不会存在第二种方法的漏洞问题

## Native 调用 js

### 第一种方式

```java
//java
mWebView.loadUrl("javascript:show(" + result + ")");
```

```js
<script type="text/javascript">
function show(result){
    alert("result"=result);
    return "success";
}
</script>
```

注意的是名字一定要对应上，要不然是调用不成功的，而且还有一点是 `JS 的调用一定要在 onPageFinished 函数回调之后才能调用，要不然也是会失败的`

### 第二种方式

得到一个 Native 调用 Web 的回调怎么办，Google 在 Android4.4 为我们新增加了一个新方法，这个方法比 loadUrl 方法更加方便简洁，而且比 loadUrl 效率更高，因为 loadUrl 的执行会造成页面刷新一次，这个方法不会，因为这个方法是在 4.4 版本才引入的，所以我们使用的时候需要添加版本的判断

```java
final int version = Build.VERSION.SDK_INT;
if (version < 18) {
    mWebView.loadUrl(jsStr);
} else {
    mWebView.evaluateJavascript(jsStr, new ValueCallback<String>() {
        @Override
        public void onReceiveValue(String value) {
            //此处为 js 返回的结果
        }
    });
}
```

### 两种方式的对比

- 一般最常使用的就是第一种方法，但是第一种方法获取返回的值比较麻烦
- 而第二种方法由于是在 4.4 版本引入的，所以局限性比较大

## Web 资源预加载

每当 WebView 发起资源请求的时候，我们会拦截这些资源的请求，去本地检查一下我们这些静态资源本地离线包有没有。针对本地的缓存文件我们有些策略能够及时的去更新它，为了安全考虑，也需要同时做一些预下载和安全包的加密工作

- 拦截了 WebView 里面发出的所有的请求，但是并没有替换里面的前端应用的任何代码，前端这套页面代码可以在 APP 内，或者其他的 APP 里面都可以直接访问，他不需要为我们 APP 做定制化的东西；
- 这些 URL 请求，他会直接带上先前用户操作所留下的 Cookie ，因为我们没有更改资源原始 URL 地址；
- 整个前端在用离线包和缓存文件的时候是完全无感知的，前端只用管写一个自己的页面，客户端会帮他处理好这样一些静态资源预加载的问题，有这个离线包的话，加载速度会变快很多，特别是在弱网情况下，没有这些离线包加载速度会慢一些。而且如果本地离线包的版本不能跟 H5 匹配的话，H5 页面也不会发生什么问题。

实际资源预下载也确实能够有效的增加页面的加载速度，具体的对比可以去看美团的文章 [【腾讯Bugly干货分享】美团大众点评 Hybrid 化建设](https://zhuanlan.zhihu.com/p/24202408)
