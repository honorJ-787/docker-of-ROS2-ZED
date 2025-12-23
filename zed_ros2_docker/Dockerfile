# devel，not runtime（lack of CUDA toolkit/headers）
FROM stereolabs/zed:5.1.0-devel-cuda13.0-ubuntu24.04

ARG DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=jazzy
SHELL ["/bin/bash", "-lc"]

# basic tool + locale
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales curl ca-certificates gnupg lsb-release software-properties-common \
    git build-essential cmake \
    python3 python3-pip \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
 && add-apt-repository universe \
 && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ros2-apt-source
RUN apt-get update && apt-get install -y --no-install-recommends curl \
 && export ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}') \
 && curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo ${UBUNTU_CODENAME:-${VERSION_CODENAME}})_all.deb" \
 && dpkg -i /tmp/ros2-apt-source.deb \
 && rm -f /tmp/ros2-apt-source.deb \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-ros-base \
    ros-dev-tools \
    python3-colcon-common-extensions \
    python3-rosdep \
    ros-jazzy-zed-msgs \
 && rm -rf /var/lib/apt/lists/*

# rosdep init
RUN rosdep init 2>/dev/null || true

# CUDA
ENV CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
ENV CUDAToolkit_ROOT=/usr/local/cuda


ENV AMENT_TRACE_SETUP_FILES=

WORKDIR /root/ros2_ws
RUN mkdir -p src \
 && git clone --recursive --depth 1 https://github.com/stereolabs/zed-ros2-wrapper.git src/zed-ros2-wrapper


RUN tee /ros_entrypoint.sh >/dev/null <<'EOS'
#!/bin/bash
set -e

export AMENT_TRACE_SETUP_FILES=${AMENT_TRACE_SETUP_FILES:-}

source /opt/ros/${ROS_DISTRO}/setup.bash
cd /root/ros2_ws

if [ ! -f /root/ros2_ws/install/setup.bash ]; then
  echo "[INFO] First run: apt-get update + rosdep + colcon build..."
  apt-get update
  rosdep update
  rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO}

  colcon build --symlink-install --parallel-workers 1 --event-handlers console_direct+ \
    --cmake-args \
      -DCMAKE_BUILD_TYPE=Release \
      -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_TOOLKIT_ROOT_DIR} \
      -DCUDAToolkit_ROOT=${CUDAToolkit_ROOT} \
      -DCMAKE_POLICY_DEFAULT_CMP0146=OLD
fi

source /root/ros2_ws/install/setup.bash
exec "$@"
EOS

RUN chmod +x /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
