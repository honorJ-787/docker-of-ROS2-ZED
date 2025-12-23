#!/bin/bash
set -e

source /opt/ros/${ROS_DISTRO}/setup.bash

cd /root/ros2_ws


if [ ! -f /root/ros2_ws/install/setup.bash ]; then
  echo "[INFO] First run: rosdep + colcon build (will take some minutes)..."
  rosdep update
  apt-get update
  rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO}


  # stubs + allow undefined (an insurance)
  export CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs:${CMAKE_LIBRARY_PATH}
  export LDFLAGS="-Wl,--allow-shlib-undefined ${LDFLAGS}"

  colcon build --symlink-install --parallel-workers 1 --event-handlers console_direct+
fi

source /root/ros2_ws/install/setup.bash
exec "$@"
