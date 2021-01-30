---
title: "Android EditText与RecycleView 嵌套导致ANR问题"
date: 2018-07-14T23:14:57+08:00
description: "Android EditText与RecycleView 嵌套 导致 ANR 的原因和解决方法"
draft: false
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

## 问题表现

滑动 RecycleView 点击 EditText 控件后，程序崩溃 ANR

## 导致问题的原因

大量注册 EditText 容易出现这个问题

只要点击EditText，RecycleView 适配器 中的onBindViewHolder 回调会一直刷新
导致整个 View 中大量 `EditText` 焦点错乱
原因是:

- editText中的addTextChangedListener是可以绑定多个监听器的
- 如果一个editText要获取输入值那它就首先必须要获取到焦点
- 用户不断滑动 RecyclerView 那么就会嵌套触发监听器
- 最终导致 ANR

### 解决 RecycleView 中放置 EditText 导致的 ANR

> `不建议使用 tag 方式来设置` 因为不会在根本上解决 ANR 问题

布局文件需要设置为

- activity

```xml
    <activity
        android:windowSoftInputMode="stateHidden|adjustPan" />
```

- view xml

```xml
        <android.support.v7.widget.RecyclerView
            android:descendantFocusability="beforeDescendants"
            android:fastScrollEnabled="false"/>
```

- 在 RecycleView Holder 中，设置 `setOnFocusChangeListener` 监听器
- 通过来判断焦点的变化来设置 `addTextChangedListener` 和 `removeTextChangedListener`

示例代码

```java
  holder.textWatcher = new TextWatcher() {
    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
    }
    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
    }
    @Override
    public void afterTextChanged(Editable s) {
        // do something
    }
  }
  holder.editText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
      @Override
      public void onFocusChange(View v, boolean hasFocus) {
          if (hasFocus) {
              if (holder.textWatcher != null) {
                holder.editText.addTextChangedListener(holder.textWatcher);
              }
          } else {
            if (holder.textWatcher != null) {
              holder.editText.removeTextChangedListener(holder.textWatcher);
            }
          }
      }
  });
```

## 扩展- EditText 使用tag方式来避免监听设置异常

- EditText中有 setTag 和 getTag 可以储存Object对象作为标签

然后把textWatcher 作为标签设置 TAG 来作为标记表明这个item的editText是否已经设置textChange监听

- 在Adapter的onBindViewHolder中每次都先判断editText的Tag是否有textWatcher对象
- 有的话就调用removeTextChangedListener来移除由于视图复用之前绑定的textWatcher
- 然后就设置editText的内容setText
- 最后再给editText设置监听器addTextChangedListener 并把这个textWatcher加入到editText的TAG标签中

总结来说就是在适配器里先移除被复用事件，再添加新事件

代码样例

```java
  // 通过设置 tag 避免复用
  EditText editText =  helper.getView(R.id.et_input);
  if (editText.getTag() instanceof TextWatcher) {
      editText.removeTextChangedListener((TextWatcher) editText.getTag());
  }
  helper.setText(R.id.et_comment, item.content);
  TextWatcher watcher = new TextWatcher() {
      @Override
      public void beforeTextChanged(CharSequence s, int start, int count, int after) {

      }

      @Override
      public void onTextChanged(CharSequence s, int start, int before, int count) {

      }

      @Override
      public void afterTextChanged(Editable s) {
        item.content = s.length() > 0 ? s.toString() : "";
        // do something
      }
  };
  editText.addTextChangedListener(watcher);
  editText.setTag(watcher);
```

### 其他控件使用tag方式来避免监听设置异常

- CheckBox

```java
  CheckBox checkBox = helper.getView(R.id.mCheckBox);
  checkBox.setOnCheckedChangeListener(null);
  if (item.anonymous) {
      checkBox.setChecked(true);
  } else {
      checkBox.setChecked(false);
  }
  checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
      @Override
      public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
          item.anonymous = isChecked;
          // do something
      }
  })
```

- StarBar

```java
  StarBar starBar = helper.getView(R.id.star_bar);
  starBar.setOnStarChangeListener(null);
  starBar.setStarMark(item.score);
  ((StarBar) helper.getView(R.id.mStarBar)).setOnStarChangeListener(new StarBar.OnStarChangeListener() {
      @Override
      public void onStarChange(float mark) {
        item.score = (int) mark;
        // do something
      }
  });
```