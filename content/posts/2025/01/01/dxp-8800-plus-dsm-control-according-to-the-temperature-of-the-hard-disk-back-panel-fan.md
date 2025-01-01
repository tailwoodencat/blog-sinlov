---
title: "DXP 8800 plus 黑群晖 根据硬盘温度控制 背板风扇"
date: 2025-01-01T09:06:59+08:00
description: "DXP 8800 plus DSM Control according to the temperature of the hard disk Back panel fan"
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

# 开启控制 3号风扇
echo 1 > pwm3_enable
# 100是调节风扇转速的参数，参数范围为0~255
echo 100 > pwm3

# 开启控制 4号风扇
echo 1 > pwm4_enable
# 100是调节风扇转速的参数，参数范围为0~255
echo 100 > pwm4

# 通过 sensors 命令查看风扇调整结果
sensors
...
fan2:         662 RPM  (min =   19 RPM)
fan3:         898 RPM  (min =   12 RPM)
fan4:         982 RPM  (min =   -1 RPM)  ALARM
```

## 风扇调整脚本

- 要求确保 `风扇调整驱动可以工作`
- DXP 8800 有 2个风扇，如果是 4800 背板单风扇，可以去掉 风扇 FAN_CONTROL_2 和 FAN_CONTROL_ENABLE_2 逻辑

- 风扇调整功能
	-  根据 HDD 硬盘最高温度 调整 背板风扇
	-  可以设置 HDD 温度范围
	-  风量 5 级，支持平滑过渡调整

- 脚本 `fan_control.sh` 内容为

```bash
#!/bin/bash

# 风扇控制设备路径，根据实际驱动安装位置修改
FAN_CONTROL_ROOT="/sys/devices/platform/it87.2608/hwmon/hwmon4"
# pwm3 为背板 风扇 1
FAN_CONTROL_1="${FAN_CONTROL_ROOT}/pwm3"
FAN_CONTROL_ENABLE_1="${FAN_CONTROL_ROOT}/pwm3_enable"
# pwm4 为背板 风扇 2
FAN_CONTROL_2="${FAN_CONTROL_ROOT}/pwm4"
FAN_CONTROL_ENABLE_2="${FAN_CONTROL_ROOT}/pwm4_enable"

# 初始化 HDD 设备状态数组 这里准备了 8 个硬盘
devices=(x x x x x x x x)
# 初始化设备映射 这里准备了 8 个硬盘
map=(disk1 disk2 disk3 disk4 disk5 disk6 disk7 disk8)
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


# 设置日志路径
LOG_FILE="/var/log/FAN_CONTROL_BY_HDD.log"

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
# echo "映射设备中..."
for devpath in /sys/block/sata*; do
    dev=$(basename $devpath)
    hctl=$(basename $(readlink $devpath/device))
    hwmap[$dev]=${hctl:0:1}
    # echo "将 $dev 映射到${hctl:0:1}"
done
}

enableFanControl() {
    local fan_control_enable=$1
    # 启用风扇控制
    if ! echo 1 > ${fan_control_enable}; then
        echo "错误: 无法设置风扇控制模式 at: ${fan_control_enable}"
        exit 1
    fi
}

# 设置风扇转速函数
# 参数1：风扇控制目标路径
# 参数2：PWM值
set_fan_speed() {
    local pwm=$1

    # 确保PWM值在有效范围内
    if [ $pwm -lt $MIN_PWM ]; then
        pwm=$MIN_PWM
    elif [ $pwm -gt $MAX_PWM ]; then
        pwm=$MAX_PWM
    fi

    # 尝试设置风扇转速
    if ! echo $pwm > "$FAN_CONTROL_1"; then
        echo "错误: 设置风扇转速失败 at: $FAN_CONTROL_1 by:pwn $pwm" >> "$LOG_FILE"
        return 1
    fi
    if ! echo $pwm > "$FAN_CONTROL_2"; then
        echo "错误: 设置风扇转速失败 at: $FAN_CONTROL_2 by:pwn $pwm" >> "$LOG_FILE"
        return 1
    fi

    return 0
}

# 读取硬盘温度 温度 范围为 i q m a 分别为 min quiet mid max
# 打印最高温度
get_hdd_temp() {
  local hdd_temp_max=0
for i in "${!hwmap[@]}"; do
    # 0 为 硬件下标偏移
    local index=$((${hwmap[$i]} + 0))
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

    # echo "当前HDD 最高温度: $max_temp， 目标转速 $target_pwm， 风扇转速: $current_pwm"

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
# 检查文件权限和路径
checkFilePathAndPermissions $FAN_CONTROL_1
checkFilePathAndPermissions $FAN_CONTROL_2
# 检查风扇控制模式设置是否成功
enableFanControl $FAN_CONTROL_ENABLE_1
enableFanControl $FAN_CONTROL_ENABLE_2
# 映射硬盘设备
mapHDD
# 创建日志文件（如果不存在）
touch "$LOG_FILE" 2>/dev/null || { echo "错误: 无法创建日志文件"; exit 1; }

# 主循环
while true; do
    # 获取CPU温度
    TEMP=$(get_hdd_temp)
    if [ $? -ne 0 ]; then
        # 温度读取失败，使用保守的风扇设置
        echo "警告: 温度读取失败，使用 保守 风扇设置 ${GUARD_PWM}" >> "$LOG_FILE"
        set_fan_speed ${FAN_CONTROL_1} ${GUARD_PWM}
        set_fan_speed ${FAN_CONTROL_2} ${GUARD_PWM}
        sleep $NORMAL_INTERVAL
        continue
    fi

    # echo "硬盘 当前最高温度: $TEMP°C"

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
        echo "错误: 风扇控制失败，等待下次尝试" >> "$LOG_FILE"
        sleep $NORMAL_INTERVAL
        continue
    fi
    # 确保PWM值在有效范围内并设置风扇转速
    if ! set_fan_speed $current_pwm; then
        echo "错误: 风扇控制失败，等待下次尝试" >> "$LOG_FILE"
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

    echo "硬盘 当前最高温度: $TEMP°C 调整 PWM: ${current_pwm}, Interval: ${sleep_interval}s"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Max HDD Temp: ${TEMP}°C, PWM: ${current_pwm}, Interval: ${sleep_interval}s" >> "$LOG_FILE"

    # 使用trap捕获信号
    trap 'echo "收到终止信号，设置风扇为默认值并退出..."; set_fan_speed 51; exit 0' SIGTERM SIGINT

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

### 设置开机自动调整风扇

在 `任务计划` 中 `新增`  `触发的任务` -> `用户定义的脚本`

- 任务名称 `Fan-control`
- 用户帐号 `root`
- 先行任务：留空
- 事件 `开机`

`任务设置` 中填写

```
cd ${改为脚本存放位置}
bash ./fan_control.sh
```

