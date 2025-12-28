# This is the origin demo, without !!! CycloneDDSDDS !!!
## ROS 2 Jazzy + ZED2 (ZED SDK 5.1) on Ubuntu 24.04 + CUDA 13.0 — Docker Setup

This repository provides a reproducible Docker environment to run **Stereolabs ZED2** with **ROS 2 Jazzy** on **Ubuntu 24.04** with **NVIDIA GPU acceleration (CUDA 13.0)**.

It uses a **ZED “devel” image** so the workspace can **build** `zed-ros2-wrapper` (the runtime image is often missing CUDA toolkit headers required for compilation).

---

## Features

- ✅ Ubuntu 24.04 (Noble) + ROS 2 Jazzy
- ✅ ZED SDK 5.1 base image (CUDA 13.0)
- ✅ GPU support via NVIDIA Container Toolkit (`--gpus all`)
- ✅ ZED2 USB pass-through (privileged + `/dev/bus/usb`)
- ✅ First run auto-build:
  - `apt-get update`
  - `rosdep install`
  - `colcon build`
- ✅ Optional RViz2 GUI via X11

---

## Repository Layout

```text
zed_ros2_docker/
  Dockerfile
  compose.yaml
  ros_entrypoint.sh
  README.md
