---
title: "Android declare styleable 中 format详解"
date: 2016-02-25T10:20:01+08:00
description: "desc Android declare styleable 中 format详解"
draft: false
categories: ['Android']
tags: ['Android']
toc:
  enable: true
  auto: false
math:
  enable: true
mapbox:
  accessToken: ""
share:
  enable: true
comment:
  enable: true
---

## 说明

我们在做项目的时候，由于

- android View style 自带的属性不能满足需求
- 或者，封装自定义 Widget 可以直接在 xml 直接配置属性使用

android 提供了自定义属性的方法，其中的 format 是定义 xml数据类型的

下面列出一些常用的类型定义方法，及其使用方法

## reference 某一资源ID

### 属性定义

```xml
<declare-styleable name = "名称">
    <attr name = "background" format = "reference" />
</declare-styleable>
```

### 属性使用

```xml
<ImageView
    android:layout_width = "42dip"
    android:layout_height = "42dip"
    android:background = "@drawable/图片ID"
/>
```

## color 颜色值

### 属性定义

```xml
<declare-styleable name = "名称">
    <attr name = "textColor" format = "color" />
</declare-styleable>
```

### 属性使用

```xml
<ImageView
    android:layout_width = "42dip"
    android:layout_height = "42dip"
    android:textColor = "#00FF00"
/>
```

## boolean 布尔值

### 属性定义

```xml
<declare-styleable name = "名称">
      <attr name = "focusable" format = "boolean" />
</declare-styleable>
```

### 属性使用

```xml
<ImageView
    android:layout_width = "42dip"
    android:layout_height = "42dip"
    android:focusable = "true"
/>
```

## dimension 尺寸值

```xml
<declare-styleable name = "名称">
      <attr name = "layout_width" format = "dimension" />
</declare-styleable>
```

### 属性使用

```xml
<ImageView
    android:layout_width = "42dip"
    android:layout_height = "42dip"
/>
```

## float 浮点值

```xml
<declare-styleable name = "AlphaAnimation">
    <attr name = "fromAlpha" format = "float" />
    <attr name = "toAlpha" format = "float" />
</declare-styleable>
```

### 属性使用

```xml
<alpha
    android:fromAlpha = "1.0"
    android:toAlpha = "0.7"
/>
```

## integer 整型值

### 属性定义

```xml
<declare-styleable name = "AnimatedRotateDrawable">
    <attr name = "visible" />
    <attr name = "frameDuration" format="integer" />
    <attr name = "framesCount" format="integer" />
    <attr name = "pivotX" />
    <attr name = "pivotY" />
    <attr name = "drawable" />
</declare-styleable>
```

### 属性使用

```xml
<animated-rotate
    xmlns:android = "http://schemas.android.com/apk/res/android"
    android:drawable = "@drawable/图片ID"
    android:pivotX = "50%"
    android:pivotY = "50%"
    android:framesCount = "12"
    android:frameDuration = "100"
/>
```

## string 字符串

### 属性定义

```xml
<declare-styleable name = "MapView">
    <attr name = "apiKey" format = "string" />
</declare-styleable>
```

### 属性使用

```xml
<com.google.android.maps.MapView
    android:layout_width = "fill_parent"
    android:layout_height = "fill_parent"
    android:apiKey = "0jOkQ80oD1JL9C6HAja99uGXCRiS2CGjKO_bc_g"
/>
```

## fraction 百分数

### 属性定义

```xml
<declare-styleable name="RotateDrawable">
    <attr name = "visible" />
    <attr name = "fromDegrees" format = "float" />
    <attr name = "toDegrees" format = "float" />
    <attr name = "pivotX" format = "fraction" />
    <attr name = "pivotY" format = "fraction" />
    <attr name = "drawable" />
</declare-styleable>
```

### 属性使用

```xml
<rotate
    xmlns:android = "http://schemas.android.com/apk/res/android"
    android:interpolator = "@anim/动画ID"
    android:fromDegrees = "0"
    android:toDegrees = "360"
    android:pivotX = "200%"
    android:pivotY = "300%"
    android:duration = "5000"
    android:repeatMode = "restart"
    android:repeatCount = "infinite"
/>
```

## enum 枚举值

### 属性定义

```xml
<declare-styleable name="名称">
    <attr name="orientation">
    <enum name="horizontal" value="0" />
    <enum name="vertical" value="1" />
    </attr>
</declare-styleable>
```

### 属性使用

```xml
 <LinearLayout
    xmlns:android = "http://schemas.android.com/apk/res/android"
    android:orientation = "vertical"
    android:layout_width = "fill_parent"
    android:layout_height = "fill_parent"
    >
</LinearLayout>
```

## flag 位或运算

### 属性定义

```xml
<declare-styleable name="名称">
	<attr name="windowSoftInputMode">
		<flag name = "stateUnspecified" value = "0" />
		<flag name = "stateUnchanged" value = "1" />
		<flag name = "stateHidden" value = "2" />
		<flag name = "stateAlwaysHidden" value = "3" />
		<flag name = "stateVisible" value = "4" />
		<flag name = "stateAlwaysVisible" value = "5" />
		<flag name = "adjustUnspecified" value = "0x00" />
		<flag name = "adjustResize" value = "0x10" />
		<flag name = "adjustPan" value = "0x20" />
		<flag name = "adjustNothing" value = "0x30" />
	</attr>
</declare-styleable>
```

### 属性使用

```xml
<activity
	android:name = ".StyleAndThemeActivity"
	android:label = "@string/app_name"
	android:windowSoftInputMode = "stateUnspecified | stateUnchanged　|　stateHidden">
	<intent-filter>
		<action android:name = "android.intent.action.MAIN" />
		<category android:name = "android.intent.category.LAUNCHER" />
	</intent-filter>
</activity>
```

## 特别注意-指定多种类型值`|`

**属性定义时可以指定多种类型值**，通过 `|` 来分隔多种类型

### 属性定义

```xml
<declare-styleable name = "名称">
    <attr name = "background" format = "reference|color" />
</declare-styleable>
```

### 属性使用

```xml
<ImageView
    android:layout_width = "42dip"
    android:layout_height = "42dip"
    android:background = "@drawable/图片ID|#00FF00"
/>
```
