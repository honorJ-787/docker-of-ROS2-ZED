# syntax=docker/dockerfile:1
FROM stereolabs/zed:5.1.0-devel-cuda13.0-ubuntu24.04

SHELL ["/bin/bash", "-lc"]
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=jazzy
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 0) 基础工具（注意：这里不要装 python3-rosdep/colcon/vcstool，避免你现在的 “Unable to locate package”）
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    ca-certificates curl gnupg lsb-release software-properties-common \
    git build-essential \
    python3-pip \
 && locale-gen en_US en_US.UTF-8 \
 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
 && rm -rf /var/lib/apt/lists/*

# 1) ROS2 官方：启用 Universe + 安装 ros2-apt-source（用于配置 ROS2 apt 仓库）
#    （这是 Jazzy 官方推荐流程）
RUN add-apt-repository universe \
 && apt-get update && apt-get install -y --no-install-recommends curl \
 && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
 && curl -L -o /tmp/ros2-apt-source.deb \
      "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
 && dpkg -i /tmp/ros2-apt-source.deb \
 && rm -f /tmp/ros2-apt-source.deb

# 2) 安装 ROS2 Jazzy + 开发工具（ros-dev-tools 里包含 rosdep/colcon 等）
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-dev-tools \
 && rm -rf /var/lib/apt/lists/*

# 3) rosdep 初始化（容器里用 root 跑没问题）
RUN rosdep init 2>/dev/null || true && rosdep update

# 4) 拉源码：zed-ros2-wrapper
WORKDIR /root/ros2_ws
RUN mkdir -p src
WORKDIR /root/ros2_ws/src
RUN git clone --recursive --depth 1 https://github.com/stereolabs/zed-ros2-wrapper.git

# 说明：Stereolabs README 提到 zed_msgs 在 Humble 可用 apt；
# 其它发行版可以从 zed-ros2-interfaces 源码安装（Jazzy 不稳定时建议加上）
# :contentReference[oaicite:2]{index=2}
RUN git clone --depth 1 https://github.com/stereolabs/zed-ros2-interfaces.git

# 5) 依赖安装 + 编译（关键：rosdep 前先 apt-get update，避免 apt lists 被清后找不到包）
WORKDIR /root/ros2_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
 && apt-get update \
 && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} \
 && colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release \
 && rm -rf /var/lib/apt/lists/*

# 6) 自动 source（进容器就能直接 ros2）
RUN printf '%s\n' \
  "source /opt/ros/${ROS_DISTRO}/setup.bash" \
  "[ -f /root/ros2_ws/install/setup.bash ] && source /root/ros2_ws/install/setup.bash" \
  >> /etc/bash.bashrc

# 7) entrypoint（不用 heredoc，避免你之前的 unterminated heredoc）
RUN printf '%s\n' \
  '#!/bin/bash' \
  'set -e' \
  "source /opt/ros/${ROS_DISTRO}/setup.bash" \
  'if [ -f /root/ros2_ws/install/setup.bash ]; then source /root/ros2_ws/install/setup.bash; fi' \
  'exec "$@"' \
  > /ros_entrypoint.sh \
 && chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
