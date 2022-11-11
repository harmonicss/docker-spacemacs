#
# Spacemacs Docker Container
#
# 
#  build using :
#
#  docket build -t harmonicss/spacemacs --build-arg XAUTHORITY=$XAUTHORITY --build-arg
#  USERNAME=$USERNAME .
#
#  Run using :
#
#  docker run  -it --rm  -e DISPLAY="unix$DISPLAY" --net=host harmonicss/spacemacs emacs
#
#

FROM ubuntu:latest

# Install emacs and git
RUN apt update && \
    apt install -y software-properties-common
RUN add-apt-repository ppa:kelleyk/emacs
RUN apt update    
RUN apt install -y git
RUN apt install -y emacs28
RUN apt install -y global

# Install lsp clangd-13 (C language LSP server for code completion)
# and gcc for syntax checking
RUN apt install -y gcc
RUN apt install -y pip
RUN apt install -y clangd-13
RUN apt install -y cppcheck
RUN pip install -y python-lsp-server

# To Remove emacs loading warnings
RUN apt install -y libcanberra-gtk-module libcanberra-gtk3-module 

# XAUTHORITY and USERNAME is passsed in via cmd line
# eg docker build -t spacemacs --build-arg XAUTHORITY=$XAUTHORITY \
#    --build-arg USERNAME=$USERNAME .
ARG XAUTHORITY
ARG USERNAME

#RUN useradd -ms /bin/bash eliversi && usermod -aG eliversi eliversi
# Add a new user with the USERID of XAUTHORITY thats parsed
# from the string passed in and also give it group privillages
RUN useradd -d /home/"$USERNAME" -u $(echo $XAUTHORITY | sed 's/[^0-9]*//g') -ms /bin/bash "$USERNAME" && usermod -aG "$USERNAME" "$USERNAME"

# Configure file system properties 
USER root
RUN mkdir /home/$USERNAME || echo "Skip over build error"
RUN chown -R $USERNAME /home/$USERNAME

# Setup the enviornment
USER $USERNAME
WORKDIR /home/$USERNAME
ENV UNAME $USERNAME 
ENV GNAME $USERNAME 
ENV XAUTHORTY $XAUTHORITY
VOLUME $XAUTHORITY /home/$USERNAME/.Xauthority
VOLUME ~/Projects /home/$USERNAME/Projects

# Configure .bashrc properties
RUN echo 'alias ll="ls -hal --color"' >> ~/.bashrc

# Set the prompt for the bash shell
RUN echo 'export PS1="\[\033[01;31m\]\u@docker\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$"' >> /home/$USERNAME/.bashrc

# get .spacemacs
RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

# get the last good spacemacs version we use as hss
RUN cd .emacs.d && git checkout 387d16545573517524a60dbebf0c6e71be58eab6 
RUN cd ~
RUN git init
RUN git remote add origin https://github.com/harmonicss/spacemacs.git
RUN git pull origin master
RUN cp .spacemacs.linux .spacemacs
RUN mkdir ~/.emacs.d/backup
RUN mkdir ~/.emacs.d/undo

# install all the .spacemacs packages, twice as there are always stragglers to update
RUN emacs -nw -batch -u "$USERNAME" -q -kill
RUN emacs -nw -batch -u "$USERNAME" -q -kill

# Configure git
RUN git config --global user.name $USERNAME \
    && git config --global user.email $USERNAME@harmonicss.co.uk

CMD ["bash"]