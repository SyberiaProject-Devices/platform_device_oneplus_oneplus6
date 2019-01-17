#!/system/bin/sh 

sleep 10;

# Applying RenderZenith Settings

# Set the default IRQ affinity to the silver cluster.
    echo "f" > /proc/irq/default_smp_affinity

# Disable boot time fs tuning 
    echo 128 > /sys/block/sda/queue/read_ahead_kb
    echo 128 > /sys/block/sda/queue/nr_requests
    echo 128 > /sys/block/sdf/queue/read_ahead_kb
    echo 128 > /sys/block/sdf/queue/nr_requests
    echo 128 > /sys/block/dm-0/queue/read_ahead_kb

# Disable thermal core control until CPU is configured 
    echo 0 > /sys/module/msm_thermal/core_control/enabled

# Setup Schedutil Governor
    echo "schedutil" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/down_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/pl
    echo 0 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpufreq/policy0/schedutil/iowait_boost_enable

    echo "schedutil" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
    echo 500 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/up_rate_limit_us
    echo 20000 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/down_rate_limit_us
    echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/pl
    echo 0 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/hispeed_freq
    echo 1 > /sys/devices/system/cpu/cpufreq/policy4/schedutil/iowait_boost_enable

# Set CPU Freq to lowest possible
    echo 3000000 > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
    echo 825000 > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq

# Input boost and stune configuration
    echo "0:1056000 1:0 2:0 3:0 4:0 5:0 6:0 7:0" > /sys/module/cpu_boost/parameters/input_boost_freq
    echo 600 > /sys/module/cpu_boost/parameters/input_boost_ms
    echo 15 > /sys/module/cpu_boost/parameters/dynamic_stune_boost

# Enable PEWQ
    echo Y > /sys/module/workqueue/parameters/power_efficient Y

    # Disable Touchboost
    echo 0 > /sys/module/msm_performance/parameters/touchboost

# Disable CAF task placement for Big Cores 
    echo 0 > /proc/sys/kernel/sched_walt_rotate_big_tasks

# Disable Autogrouping
    echo 0 > /proc/sys/kernel/sched_autogroup_enabled

 # Setup EAS cpusets values for better load balancing
    echo 0-7 > /dev/cpuset/top-app/cpus

# Since we are not using core rotator, lets load balance
    echo 0-3,6-7 > /dev/cpuset/foreground/cpus
    echo 0-1 > /dev/cpuset/background/cpus
    echo 0-3 > /dev/cpuset/system-background/cpus

# For better screen off idle
    echo 0-3 > /dev/cpuset/restricted/cpus