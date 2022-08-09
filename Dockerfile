FROM httpd

ARG RCLCPP_TITLE="rclcpp - Galactic"
ARG RCLCPP_GIT=https://github.com/ros2/rclcpp.git -b galactic
ARG RCLCPP_DIR=rclcpp

ARG CYCLONE_TITLE="CycloneDDS - Galactic"
ARG CYCLONE_GIT=https://github.com/ros2/rmw_cyclonedds.git -b galactic
ARG CYCLONE_DIR=cyclonedds

RUN sed -i 's/deb\.debian\.org\/debian /ftp\.jaist\.ac\.jp\/pub\/Linux\/debian /g' /etc/apt/sources.list

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y tzdata

# timezone setting
ENV TZ=Asia/Tokyo

RUN apt-get -y install git global

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
    git clone --depth=1 $CYCLONE_GIT $CYCLONE_DIR && \
    cd $CYCLONE_DIR && \
    gtags && \
    htags --suggest2 -t "$CYCLONE_TITLE"

RUN echo "<HTML><BODY><ul><li><a href=$RCLCPP_DIR/HTML>$RCLCPP_TITLE</a></li><li><a href=$CYCLONE_DIR/HTML>$CYCLONE_TITLE</a></li></ul></BODY></HTML>" > /usr/local/apache2/htdocs/index.html
