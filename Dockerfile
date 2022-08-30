FROM httpd

ARG AW_TITLE="Autoware"
ARG AW_GIT=https://github.com/autowarefoundation/autoware.git
ARG AW_DIR=autoware

ARG RCL_TITLE="rcl - Galactic"
ARG RCL_GIT=https://github.com/ros2/rcl.git -b galactic
ARG RCL_DIR=rcl

ARG RCLC_TITLE="rclc - Galactic"
ARG RCLC_GIT=https://github.com/ros2/rclc.git -b galactic
ARG RCLC_DIR=rclc

ARG RCLCPP_TITLE="rclcpp - Galactic"
ARG RCLCPP_GIT=https://github.com/ros2/rclcpp.git -b galactic
ARG RCLCPP_DIR=rclcpp

ARG CYCLONE_TITLE="CycloneDDS - Galactic"
ARG CYCLONE_GIT=https://github.com/ros2/rmw_cyclonedds.git -b galactic
ARG CYCLONE_DIR=cyclonedds

ARG FASTDDS_TITLE="FastDDS - Humble"
ARG FASTDDS_GIT=https://github.com/ros2/rmw_cyclonedds.git -b humble
ARG FASTDDS_DIR=fastdds

RUN sed -i 's/deb\.debian\.org\/debian /ftp\.jaist\.ac\.jp\/pub\/Linux\/debian /g' /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y tzdata

# timezone setting
ENV TZ=Asia/Tokyo

RUN apt-get -y install git global python3-pip
RUN pip install -U vcstool

RUN sed -i 's/#LoadModule cgid_module modules/LoadModule cgid_module modules/g; \
            s/#AddHandler cgi-script/AddHandler cgi-script/g' \
           /usr/local/apache2/conf/httpd.conf

RUN echo \
'<Directory ~ "/usr/local/apache2/htdocs/.*/HTML/cgi-bin">\n\
    Options +ExecCGI\n\
    AddHandler cgi-script .cgi\n\
</Directory>' >> /usr/local/apache2/conf/httpd.conf

RUN cd /usr/local/apache2 && rm -rf htdocs && mkdir htdocs

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $RCLCPP_GIT $RCLCPP_DIR && \
    cd $RCLCPP_DIR && \
    gtags && \
    htags --suggest2 -t "$RCLCPP_TITLE"

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $RCLC_GIT $RCLC_DIR && \
    cd $RCLC_DIR && \
    gtags && \
    htags --suggest2 -t "$RCLC_TITLE"

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $RCL_GIT $RCL_DIR && \
    cd $RCL_DIR && \
    gtags && \
    htags --suggest2 -t "$RCL_TITLE"

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $CYCLONE_GIT $CYCLONE_DIR && \
    cd $CYCLONE_DIR && \
    gtags && \
    htags --suggest2 -t "$CYCLONE_TITLE"

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $AW_GIT $AW_DIR && \
    cd $AW_DIR && \
    mkdir src && \
    vcs import src < autoware.repos && \
    gtags && \
    htags --suggest2 -t "$AW_TITLE"

RUN cd /usr/local/apache2/htdocs && \
    git clone --depth=1 $FASTDDS_GIT $FASTDDS_DIR && \
    cd $FASTDDS_DIR && \
    gtags && \
    htags --suggest2 -t "$FASTDDS_TITLE"

RUN echo "<HTML><BODY>\
<ul>\
<li><a href=$AW_DIR/HTML>$AW_TITLE</a></li>\
<li><a href=$RCL_DIR/HTML>$RCL_TITLE</a></li>\
<li><a href=$RCLC_DIR/HTML>$RCLC_TITLE</a></li>\
<li><a href=$RCLCPP_DIR/HTML>$RCLCPP_TITLE</a></li>\
<li><a href=$CYCLONE_DIR/HTML>$CYCLONE_TITLE</a></li>\
<li><a href=$FASTDDS_DIR/HTML>$FASTDDS_TITLE</a></li>\
</ul>\
</BODY></HTML>" > /usr/local/apache2/htdocs/index.html

