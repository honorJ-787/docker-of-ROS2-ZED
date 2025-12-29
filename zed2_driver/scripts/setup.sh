xhost +SI:localuser:root

docker exec -it ros2zed bash

source /opt/ros/jazzy/setup.bash
source ~/ros2_ws/install/local_setup.bash
export ROS_DOMAIN_ID=42

apt-get update
apt-get install -y ros-$ROS_DISTRO-rmw-cyclonedds-cpp

ros2 launch zed_wrapper zed_camera.launch.py camera_model:=zed2