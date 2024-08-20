FROM vicamo/pyenv:3.5-focal


ENV GCC_VERSION=9
ENV SDK_PATH=/home/koheron/koheron-sdk
RUN apt update
RUN apt-get install -y libssl-dev bc device-tree-compiler qemu-user-static zerofree
RUN apt-get install -y lib32stdc++6 lib32z1 u-boot-tools
RUN apt-get install -y libstdc++6 libgtk2.0-0 dpkg-dev
RUN ln -s /usr/bin/make /usr/bin/gmake
RUN apt-get install -y libtinfo5 libncurses5
RUN apt-get install -y build-essential python3-dev
RUN apt-get install -y wget curl lsb-release liberror-perl git

RUN apt-get install --no-install-recommends -y locales
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
 
RUN apt-get install -y nodejs
RUN apt-get install -y node-typescript
RUN apt-get install -y g++-$GCC_VERSION-arm-linux-gnueabihf
RUN rm -f /usr/bin/arm-linux-gnueabihf-gcc /usr/bin/arm-linux-gnueabihf-g++
RUN ln -s /usr/bin/arm-linux-gnueabihf-gcc-$GCC_VERSION /usr/bin/arm-linux-gnueabihf-gcc
RUN ln -s /usr/bin/arm-linux-gnueabihf-g++-$GCC_VERSION /usr/bin/arm-linux-gnueabihf-g++
# RUN rm -f /usr/bin/gmake && ln -s make /usr/bin/gmake
RUN	apt-get install -y npm # npm installed with nodejs
RUN npm install typescript && \
    npm install @types/jquery@2.0.46 @types/jquery-mousewheel@3.1.5 websocket @types/node

RUN pyenv global 3.5.10
RUN mkdir -p $SDK_PATH
COPY . $SDK_PATH
RUN pip install -r $SDK_PATH/requirements.txt
RUN pip install -r $SDK_PATH/python/requirements.txt
RUN pip install $SDK_PATH/python

RUN	apt-get install -y zip libffi-dev
RUN ln -s /usr/lib/x86_64-linux-gnu/libffi.so.7 /usr/lib/x86_64-linux-gnu/libffi.so.6
# Create a new user and group
RUN groupadd -g 1000 tucanae47 && useradd -u 1000 -g 1000 tucanae47

# Rest of your Dockerfile


