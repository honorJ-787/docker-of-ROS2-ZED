apt-get update
apt-get install -y ros-$ROS_DISTRO-rmw-cyclonedds-cpp

ros2 launch zed_wrapper zed_camera.launch.py camera_model:=zed2