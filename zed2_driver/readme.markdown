docker:
1.
xhost +SI:localuser:root
docker compose up -d

docker exec -it ros2zed bash


2.
source /opt/ros/jazzy/setup.bash
apt-get update
apt-get install -y ros-$ROS_DISTRO-rmw-cyclonedds-cpp

source /opt/ros/jazzy/setup.bash
source /root/ros2_ws/install/setup.bash
export ROS_DOMAIN_ID=42
ros2 launch zed_wrapper zed_camera.launch.py camera_model:=zed2
3.
export XAUTHORITY=/root/.Xauthority
export QT_X11_NO_MITSHM=1
export LIBGL_DRI3_DISABLE=1
rviz2


4. 
docker stop ros2zed
