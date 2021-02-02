---
title: "Android WebView 常见问题解决"
date: 2017-03-05T09:18:33+08:00
description: "desc Android WebView 常见问题解决"
draft: false
categories: ['Android']
tags: ['Android', 'WebView']
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

## loadData() 方法

通过使用

```java
WebView.loadData(String data, String mimeType, String encoding)
```

方法来加载一整个 HTML 页面的一小段内容，参数为

- data 就是需要 WebView 展示的内容

- mimeType 是告诉 WebView 我们展示内容的类型

- encoding 是编码，但是使用的时候，这里会有一些坑，我们来看一个简单的例子

```java
String html = new String("<h3>我是loadData() 的标题</h3><p>&nbsp&nbsp我是他的内容</p>");
webView.loadData(html, "text/html", "UTF-8");
```

会显示成乱码了，可是明明已经指定了编码格式为 UTF-8 啊
需要将代码进行修改，也就是需要在 html 中定义 `charset=`

```java
String html = new String("<h3>我是loadData() 的标题</h3><p>&nbsp&nbsp我是他的内容</p>");
webView.loadData(html, "text/html;charset=UTF-8", "null");
```

> Google 还指出，在我们这种加载的方法下，我们的 Data 数据里不能出现 `’#’, ‘%’, ‘\’ , ‘?’` 这四个字符，如果出现了我们要用 `%23, %25, %27, %3f` 对应来替代

未将特定字符转义过程中遇到的异常现象

```
1)   %  会报找不到页面错误，页面全是乱码。
2)   #  会让你的 goBack 失效，但 canGoBAck 是可以使用的，于是就会产生返回按钮生效，但不能返回的情况。
3)   \ 和 ?  在转换时，会报错，因为它会把 \ 当作转义符来使用，如果用两级转义，也不生效。
```

> 在使用 loadData() 时，就意味着需要把所有的非法字符全部转换掉，这样就会给运行速度带来很大的影响，因为在使用时，很多情况下页面 stytle 中会使用很多 ‘%’ 号，页面的数据越多，运行的速度就会越慢

## 页面空白

当 WebView 嵌套在 ScrollView 里面的时候，如果 WebView 先加载了一个高度很高的网页，然后加载了一个高度很低的网页，就会造成 WebView 的高度无法自适应，底部出现大量空白的情况出现

> Google 建议不要在 ScrollView 中使用 WebView

非得使用，通过 js 注入，获取页面内容高度，重新设置 WebView 高度

```java
webView.setWebViewClient(new WebViewClient() {
    @Override
    public void onPageFinished(WebView view, String url) {
        // 如果前端没有主动调用，需要自己在 webview 容器中调用
        webView.loadUrl("javascript:AppBase.resize(document.body.getBoundingClientRect().height)");
        super.onPageFinished(view, url);
    }
});
webView.addJavascriptInterface(this, "AppBase");

@JavascriptInterface
public void resize(final float height) {
    getActivity().runOnUiThread(new Runnable() {
        @Override
        public void run() {
          // 根据父控件类型进行区分
          // webView.setLayoutParams();
          // 简单示例
          RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.WRAP_CONTENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
          params.width = getResources().getDisplayMetrics().widthPixels;
          params.height = (int) (height * getResources().getDisplayMetrics().density);
          webView.setLayoutParams(params);
        }
    });
}
```
- js 前端主动调用重新绘制高度

```js
(function(){
  try {
    window.AppBase.resize(document.body.getBoundingClientRect().height);
  } catch (error) {
    // do catch
  }
})(window);
```

## setBuiltInZoomControls 引起的 Crash

当使用

```java
webView.getSettings().setBuiltInZoomControls(true);
```

启用该设置后，用户一旦触摸屏幕，就会出现缩放控制图标，这个图标过上几秒会自动消失

但在 3.0 之上 4.4 系统之下很多手机会出现这种情况：

如果图标自动消失前退出当前 Activity 的话，就会发生 ZoomButton 找不到依附的 Window 而造成程序崩溃

解决办法很简单就是在 Activity 的 `onDestory` 方法中调用

```java
webView.setVisibility(View.GONE);
```

手动将 webView 隐藏，就不会崩溃

## 后台无法释放 JS 导致耗电

js 一直在执行比如动画之类的东西，如果此刻 WebView 挂在了后台，这些资源是不会被释放，用户也无法感知，导致一直占有 CPU 增加耗电量

那么在 Activity 生命周期 `onResume` 和 `onStop` 中设置

```java
  @Override
  public void onResume {
    webView.setJavaScriptEnabled(true);
  }

  @Override
  public void onStop {
    webView.setJavaScriptEnabled(false);
  }
```