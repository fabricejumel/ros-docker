FROM ubuntu:14.04
MAINTAINER Jesse Clark <docker@jessejohnclark.com>

# Register ROS repository
RUN apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xB01FA116 && \
echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list && \
echo "deb-src http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" >> /etc/apt/sources.list.d/ros-latest.list

ENV ROS_DISTRO indigo

# Install ROS base and rosinstall
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    nano \
    python-pip \
    python-rosinstall \
    ros-${ROS_DISTRO}-ros-base && \
rm -rf /var/lib/apt/lists/*
RUN rosdep init

# Install goodies
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ros-${ROS_DISTRO}-common-tutorials \
    ros-${ROS_DISTRO}-rospy-tutorials \
    ros-${ROS_DISTRO}-rosbridge-server && \
rm -rf /var/lib/apt/lists/*

# Setup ROS environment variables globally
RUN echo 'source /opt/ros/${ROS_DISTRO}/setup.bash' >> /etc/bash.bashrc

# Create nonprivileged user to run rosdep
RUN useradd --create-home --shell=/bin/bash rosuser
USER rosuser
RUN rosdep update

ENV TERM xterm-color
ENV EDITOR nano -wi

# Publish roscore port
EXPOSE 11311
EXPOSE 9090
