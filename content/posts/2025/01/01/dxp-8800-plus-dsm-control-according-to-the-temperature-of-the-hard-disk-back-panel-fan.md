---
title: "DXP 4800 8800 根据硬盘温度控制 背板风扇"
date: 2025-01-01T09:06:59+08:00
description: "DXP 4800 8800 DSM Control according to the temperature of the hard disk Back panel fan"
draft: false
categories: ['hardware']
tags: ['hardware']
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

## 本教程前提条件

- `插件设置` 安装插件
	- sensors 获取温度等信息

- 熟悉 ssh 操作

## 风扇调整驱动

### DSM7.2机型SA6400

- 以 root 用户身份登录

```bash
# 进入 root 用户，需要联网
sudo -i

mkdir /opt/module && cd /opt/module

# 下载驱动
wget https://cdn.jim.plus/synology/drivers/sa6400-7.2/hwmon-vid.ko && wget https://cdn.jim.plus/synology/drivers/sa6400-7.2/it87.ko

# 安装驱动
insmod hwmon-vid.ko
insmod it87.ko force_id=0x8620
```

- 测试调整风扇

```bash
# 进入 驱动目录
cd /sys/devices/platform/it87.2608/hwmon/hwmon4/

# 开启控制 fan2 号风扇
echo 1 > pw2_enable
# 100是调节风扇转速的参数，参数范围为0~255
echo 100 > pwm2

# 开启控制 3 号风扇 如果是 4800 请根据实际风扇测试
echo 1 > pwm3_enable
# 100是调节风扇转速的参数，参数范围为0~255
echo 100 > pwm3

# 通过 sensors 命令查看风扇调整结果
sensors
...
fan2:         662 RPM  (min =   19 RPM)
fan3:         898 RPM  (min =   12 RPM)
fan4:         982 RPM  (min =   -1 RPM)  ALARM
```

## 风扇调整脚本

- 要求确保 `风扇调整驱动可以工作`
- DXP 8800 有 2个风扇，如果是 4800 背板单风扇，可以去掉 风扇 FAN_CONTROL_3 和 FAN_CONTROL_ENABLE_3 逻辑

- 日志调试
	-  `LOG_DEBUG_ENABLE` 开启 debug 日志显示
	-  `LOG_COLOR_ENABLE` 开启 color 日志显示
- 风扇调整功能
	-  根据 HDD 硬盘最高温度 调整 背板风扇
	-  可以设置 HDD 温度范围
	-  风量 5 级，支持平滑过渡调整
-  CPU 可以参与风扇调整
	-  `CPU_TEMP_CONTROL_ENABLE` 开启CPU 参与
	-  `CPU_TEMP_CONTROL_START` 开始参与 CPU 温度控制阈值

- 脚本 `fan_control.sh` 内容为

```bash
##!/bin/bash

# 设置存储日志路径
LOG_FILE="/var/log/FAN_CONTROL_BY_HDD.log"

# log debug enable 1 open 0 close
LOG_DEBUG_ENABLE=1
# log color enable 1 open 0 close
LOG_COLOR_ENABLE=1

# 是否开启 CPU 温度参与风扇控制
CPU_TEMP_CONTROL_ENABLE=1
# CPU 温度开始参与风扇控制 温度
CPU_TEMP_CONTROL_START=60

# 风扇控制设备路径，根据实际驱动安装位置修改
FAN_CONTROL_ROOT="/sys/devices/platform/it87.2608/hwmon/hwmon4"
# pwm2 为背板 风扇 fan2
FAN_CONTROL_2="${FAN_CONTROL_ROOT}/pwm2"
FAN_CONTROL_ENABLE_2="${FAN_CONTROL_ROOT}/pwm3_enable"
# pwm3 为背板 风扇 fan3
FAN_CONTROL_3="${FAN_CONTROL_ROOT}/pwm3"
FAN_CONTROL_ENABLE_3="${FAN_CONTROL_ROOT}/pwm4_enable"

# 初始化 HDD 设备状态数组 这里准备了 8 个硬盘
devices=(x x x x x x x x x)
# 初始化设备映射 这里准备了 8 个硬盘
map=(cpu disk1 disk2 disk3 disk4 disk5 disk6 disk7 disk8)
# 将 sataX 映射到硬件设备
declare -A hwmap

# 硬盘温度范围
HDD_MAX_TEMP=50
HDD_MID_TEMP=45
HDD_LOW_TEMP=35

## 风扇调整范围
# 保守风量，也是默认风量
GUARD_PWM=51
# 最小风量
MIN_PWM=21
# 安静风量
QUIT_PWM=60
# 中间风量
MID_PWM=141
# 最大风量
MAX_PWM=255

# 全局平滑过渡 PWM 存储变量 默认调整 从 105 开始
current_pwm=105
# 平滑过渡增加
SMOOTH_TRANSITION_INCREASE=9
# 平滑过渡减少
SMOOTH_TRANSITION_DECREASE=3

# 默认调整间隔 秒
NORMAL_INTERVAL=15
# 温度快速调整间隔 秒
HIGH_TEMP_INTERVAL=5

# 温度调整 判断条件 摄氏度
TEMP_THRESHOLD=45

pV(){
  if [[ 0 -ne ${LOG_COLOR_ENABLE} ]]; then
    echo -e "\033[;35m\033[0m"
  else
    echo -e "$1"
  fi
}
pI(){
  if [[ 0 -ne ${LOG_COLOR_ENABLE} ]]; then
    echo -e "\033[;32mINFO: $1\033[0m"
  else
    echo -e "$1"
  fi
}
pD(){
  if [[ 0 -ne ${LOG_DEBUG_ENABLE} ]]; then
    if [[ 0 -ne ${LOG_COLOR_ENABLE} ]]; then
      echo -e "\033[;34mDEBUG: $1\033[0m"
    else
      echo -e "$1"
    fi
  fi
}
pW(){
  if [[ 0 -ne ${LOG_COLOR_ENABLE} ]]; then
    echo -e "\033[;33mWARN: $1\033[0m"
  else
    echo -e "$1"
  fi
}
pE(){
  if [[ 0 -ne ${LOG_COLOR_ENABLE} ]]; then
    echo -e "\033[;31mERROR: $1\033[0m"
  else
    echo -e "$1"
  fi
}
#pV "V"
#pI "I"
#pD "D"
#pW "W"
#pE "E"

checkFilePathAndPermissions() {
    local check_file=$1
    if [ ! -w "$check_file" ]; then
      echo "Error: Unable to write to file: $check_file"
      exit 1
    fi
}

checkFuncBack(){
  if [ ! $? -eq 0 ]; then
    echo -e "\033[;31mRun [ $1 ] error exit code 1\033[0m"
    exit 1
  # else
  #   echo -e "\033[;30mRun [ $1 ] success\033[0m"
  fi
}

hasBinary(){
    local binary_checker=`which $1`
    if [[ ! -n "${binary_checker}" ]]; then
        echo -e "\033[;31mCheck binary [ $1 ] not exist \033[0m"
    fi
}

mapHDD() {
pD "Start mapping HDD..."
for devpath in /sys/block/sata*; do
    dev=$(basename $devpath)
    hctl=$(basename $(readlink $devpath/device))
    hwmap[$dev]=${hctl:0:1}
    pD "as $dev mapping to ${hctl:0:1}"
done
pD "Finish mapping HDD"
}

enableFanControl() {
    local fan_control_enable=$1
    # 启用风扇控制
    if ! echo 1 > ${fan_control_enable}; then
        pE "Error: Unable to set the fan control mode at: ${fan_control_enable}"
        return 1
    fi
    pD "启用风扇控制成功 at: ${fan_control_enable}"
    return 0
}

# 设置风扇转速函数
# 参数1：PWM值
set_fan_speed() {
    local pwm=$1

    # 确保PWM值在有效范围内
    if [ $pwm -lt $MIN_PWM ]; then
        pwm=$MIN_PWM
    elif [ $pwm -gt $MAX_PWM ]; then
        pwm=$MAX_PWM
    fi

    # 尝试设置风扇转速
    # 检查风扇控制模式设置是否成功
    if ! enableFanControl $FAN_CONTROL_ENABLE_2 ; then
        pE "Error: Unable to enable fan control mode at: ${FAN_CONTROL_ENABLE_2}"
        echo "Error: Unable to enable fan control mode at: ${FAN_CONTROL_ENABLE_2}" >> "$LOG_FILE"
        return 1
    fi
    if ! echo $pwm > "$FAN_CONTROL_2"; then
        pE "Error: Failed to set the fan speed at: $FAN_CONTROL_2 by:pwn $pwm"
        echo "Error: Failed to set the fan speed at: $FAN_CONTROL_2 by:pwn $pwm" >> "$LOG_FILE"
        return 1
    fi

    ## 如果需要禁止 控制风扇 2 注释这段逻辑即可
    if ! enableFanControl $FAN_CONTROL_ENABLE_3 ; then
        pE "Error: Unable to enable fan control mode at: ${FAN_CONTROL_ENABLE_3}"
        echo "Error: Unable to enable fan control mode at: ${FAN_CONTROL_ENABLE_3}" >> "$LOG_FILE"
        return 1
    fi
    if ! echo $pwm > "$FAN_CONTROL_3"; then
        pE "Error: Failed to set the fan speed at: $FAN_CONTROL_3 by:pwn $pwm"
        echo "Error: Failed to set the fan speed at: $FAN_CONTROL_3 by:pwn $pwm" >> "$LOG_FILE"
        return 1
    fi

    return 0
}

# 读取cpu 温度 根据 Core 0
get_cpu_temp() {
    echo $(sensors | awk '/Core 0/ {print$3}' | cut -c2- | cut -d'.' -f1)
}

# 读取硬盘温度 温度 范围为 i q m a 分别为 min quiet mid max
# 打印最高温度
# cpu 参与温度控制设置参数为
# CPU_TEMP_CONTROL_ENABLE 1 开启
# CPU_TEMP_CONTROL_START 开始参与控制温度 比如 60
# 硬盘温度控制参数为
# HDD_MAX_TEMP 50 最高温度
# HDD_MID_TEMP 45 中间温度
# HDD_LOW_TEMP 35 最低温度
# 硬盘温度控制优先级为
# a 最高温度
# m 中间温度
# q 低温度
# i 最低温度
get_hdd_temp() {
  local hdd_temp_max=0
for i in "${!hwmap[@]}"; do
    # 0 为 硬件下标偏移
    local index=$((${hwmap[$i]} + 1))
    local hdd_temp=$(cat /run/synostorage/disks/sata$((${hwmap[$i]} + 1))/temperature)
    devices[$index]=$hdd_temp
    if [ "$hdd_temp" -ge ${HDD_MAX_TEMP} ]; then
        devices[$index]=a
    else
        if [ "$hdd_temp" -ge ${HDD_MID_TEMP} ]; then
            devices[$index]=m
        else
            if [ "$hdd_temp" -ge ${HDD_LOW_TEMP} ]; then
                devices[$index]=q
            else
                devices[$index]=i
            fi
        fi
    fi
    if [ "$hdd_temp" -gt "$hdd_temp_max" ]; then
        hdd_temp_max=$hdd_temp
    fi
done
    if [ ${CPU_TEMP_CONTROL_ENABLE} -eq 1 ]; then
        local cpu_temp=$(get_cpu_temp)
        if [ "$cpu_temp" -ge ${CPU_TEMP_CONTROL_START} ]; then
            hdd_temp_max=${cpu_temp}
        fi
    fi
    echo $hdd_temp_max
return 0
}

# 输出最终设备状态 并控制 风扇
# 参数1：当前最高硬盘温度
# 输出调整 PWM 值
control_fan_filter() {
    local max_temp=$1
    local target_pwm=${GUARD_PWM}

    # echo "硬盘温度状态:"
    # for i in "${!devices[@]}"; do
    #     echo "${map[$i]}: ${devices[$i]}"
    # done

    # 设置目标风扇转速
    if [ "$max_temp" -ge ${HDD_MAX_TEMP} ]; then
        target_pwm=${MAX_PWM}
    else
        if [ "$max_temp" -ge ${HDD_MID_TEMP} ]; then
            target_pwm=${MID_PWM}
        else
            if [ "$max_temp" -ge ${HDD_LOW_TEMP} ]; then
                target_pwm=${QUIT_PWM}
            else
                target_pwm=${MIN_PWM}
            fi
        fi
    fi

    # # 设置目标风扇转速 需要 bc
    # if (( $(echo "$max_temp < 30" | bc -l) )); then
    #     target_pwm=$MIN_PWM
    # elif (( $(echo "$max_temp >= 30 && $max_temp < 35" | bc -l) )); then
    #     target_pwm=85
    # elif (( $(echo "$max_temp >= 35 && $max_temp < 40" | bc -l) )); then
    #     target_pwm=120
    # elif (( $(echo "$max_temp >= 40 && $max_temp < 45" | bc -l) )); then
    #     target_pwm=150
    # elif (( $(echo "$max_temp >= 45 && $max_temp < 50" | bc -l) )); then
    #     target_pwm=180
    # elif (( $(echo "$max_temp >= 50 && $max_temp < 55" | bc -l) )); then
    #     target_pwm=200
    # elif (( $(echo "$max_temp >= 55 && $max_temp < 60" | bc -l) )); then
    #     target_pwm=225
    # else
    #     target_pwm=$MAX_PWM
    # fi

    pD "Current HDD highest temperature: $max_temp , Target PWM: $target_pwm, Fan PWM: $current_pwm"

    # 平滑过渡
    if [ $target_pwm -gt $current_pwm ]; then
        current_pwm=$(( current_pwm + ${SMOOTH_TRANSITION_INCREASE} ))
    elif [ $target_pwm -lt $current_pwm ]; then
        current_pwm=$(( current_pwm - ${SMOOTH_TRANSITION_DECREASE} ))
    fi
}

## 运行检查

# 检查必要的命令是否存在
hasBinary du
hasBinary awk
hasBinary sensors

pI "Drive control root path: $FAN_CONTROL_ROOT"

# 检查 控制风扇 fan2 文件权限和路径
checkFilePathAndPermissions $FAN_CONTROL_2
checkFilePathAndPermissions $FAN_CONTROL_ENABLE_2

# 检查 控制风扇 fan3 文件权限和路径，不需要控制这风扇 注释即可
checkFilePathAndPermissions $FAN_CONTROL_3
checkFilePathAndPermissions $FAN_CONTROL_ENABLE_3
# 映射硬盘设备
mapHDD
# 创建日志文件（如果不存在）
touch "$LOG_FILE" 2>/dev/null || { echo "Error: Unable to create log file"; exit 1; }

# 主循环
while true; do
    # 获取CPU温度
    TEMP=$(get_hdd_temp)
    if [ $? -ne 0 ]; then
        # 温度读取失败，使用保守的风扇设置
        echo "Warning: Temperature reading failed, use conservative fan settings: ${GUARD_PWM}" >> "$LOG_FILE"
        set_fan_speed ${FAN_CONTROL_2} ${GUARD_PWM}
        set_fan_speed ${FAN_CONTROL_3} ${GUARD_PWM}
        sleep $NORMAL_INTERVAL
        continue
    fi

    # 根据温度设置检测间隔
    # if (( $(echo "$TEMP >= $TEMP_THRESHOLD" | bc -l) )); then
    #     sleep_interval=$HIGH_TEMP_INTERVAL
    # else
    #     sleep_interval=$NORMAL_INTERVAL
    # fi

    if [ $TEMP -ge $TEMP_THRESHOLD ]; then
        sleep_interval=$HIGH_TEMP_INTERVAL
    else
        sleep_interval=$NORMAL_INTERVAL
    fi

    control_fan_filter $TEMP
    if [ $? -ne 0 ]; then
        pE "Error: control filter failed, waiting for the next attempt" >> "$LOG_FILE"
        sleep $NORMAL_INTERVAL
        continue
    fi
    # 确保PWM值在有效范围内并设置风扇转速
    if ! set_fan_speed $current_pwm; then
        pE "Error: Fan control failed, waiting for the next attempt" >> "$LOG_FILE"
        sleep $NORMAL_INTERVAL
        continue
    fi

    # 记录日志，同时检查日志文件大小
    log_size=$(du -b "$LOG_FILE" | awk '{print $1}' 2>/dev/null || echo 0)
    # echo "log_size ${log_size}"
    if [ $log_size -gt 10485760 ]; then  # 10MB
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
    fi

    pD "current HDD highest temperature: $TEMP°C , current PWM: ${current_pwm}, Interval: ${sleep_interval}s"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Max HDD Temp: ${TEMP}°C, PWM: ${current_pwm}, Interval: ${sleep_interval}s" >> "$LOG_FILE"

    # 使用trap捕获信号
    trap 'echo "Receive the termination signal, set the fan to the default value and exit..."; set_fan_speed 51; exit 0' SIGTERM SIGINT

    sleep $sleep_interval
done
```

### 调试 脚本

```bash
# 管理员下
$ sudo -i

# 直接执行
$ bash ./fan_control.sh
```

- 确认执行没问题 关闭调试日志

```bash
# log debug enable 1 open 0 close
LOG_DEBUG_ENABLE=0
# log color enable 1 open 0 close
LOG_COLOR_ENABLE=0
```

### 设置开机自动调整风扇

在 `任务计划` 中 `新增`  `触发的任务` -> `用户定义的脚本`

- 任务名称 `Fan-control-by-HDD`
- 用户帐号 `root`
- 先行任务：留空
- 事件 `开机`

`任务设置` 中填写

```
cd ${改为脚本存放位置}
bash ./fan_control.sh
```
