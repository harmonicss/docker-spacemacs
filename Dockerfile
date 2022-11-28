################################################################################
#
# Spacemacs Docker Container
# ==========================
#
# Ed Liversidge, Harmonic Software Systems Ltd harmonicss.co.uk
#
# Installs a spacemacs docker continer with development environment for C and
# Rust development.
#
#  build using : (dont forget the .)
#  ===========
#
#  docker build -t harmonicss/spacemacs --build-arg XAUTHORITY=$XAUTHORITY --build-arg USERNAME=$USER .
#
#  Run using :
#  ===========
#
#  docker run  -it --rm  -e DISPLAY --net=host -v ~/Projects:/home/$USER/Projects harmonicss/spacemacs
#
#
################################################################################


################################################################################
# Change this to use fast emacs-native-comp, needs to be
# built from docker beforehand. Not on dockerhub yet, but on
# github here : https://github.com/harmonicss/docker-emacs-native
################################################################################
FROM ubuntu:latest
#FROM emacs-native-comp


################################################################################
# Install emacs and git
################################################################################
RUN apt update && \
    apt install -y software-properties-common
RUN add-apt-repository ppa:kelleyk/emacs
RUN apt update
RUN apt install -y git
RUN apt install -y emacs28
RUN apt install -y global

# Sometimes emacs is bust!
RUN apt install -y vim

################################################################################
# Install lsp clangd-13 (C language LSP server for code completion)
# and gcc for syntax checking
################################################################################
RUN apt install -y gcc
RUN apt update
RUN apt install -y pip
RUN apt install -y clangd-13
RUN apt install -y cppcheck
RUN apt install -y curl
RUN pip install python-lsp-server


################################################################################
# To Remove emacs loading warnings
################################################################################
RUN apt install -y libcanberra-gtk-module libcanberra-gtk3-module 


################################################################################
# XAUTHORITY and USERNAME is passsed in via cmd line
# eg docker build -t spacemacs --build-arg XAUTHORITY=$XAUTHORITY \
#    --build-arg USERNAME=$USERNAME .
################################################################################
ARG XAUTHORITY
ARG USERNAME


################################################################################
# Add a new user with the USERID of XAUTHORITY thats parsed
# from the string passed in and also give it group privileges
################################################################################
RUN useradd -d /home/"$USERNAME" -u $(echo $XAUTHORITY | awk -F/ '{print $4}') -ms /bin/bash "$USERNAME" && usermod -aG "$USERNAME" "$USERNAME"


################################################################################
# Configure file system properties 
################################################################################
USER root
RUN mkdir /home/$USERNAME || echo "Skip over build error"
RUN chown -R $USERNAME /home/$USERNAME


################################################################################
# Install source code pro font
# https://askubuntu.com/questions/193072/how-to-use-the-adobe-source-code-pro-font
################################################################################
RUN apt update
RUN apt install -y wget
RUN wget --content-disposition -P /usr/share/fonts/opentype/source-code-pro https://github.com/adobe-fonts/source-code-pro/blob/29fdb884c6e9dc2a312f4a5e2bb3b2dad2350777/OTF/SourceCodePro-Regular.otf?raw=true


################################################################################
# Setup the environment
################################################################################
USER $USERNAME
WORKDIR /home/$USERNAME
ENV UNAME $USERNAME 
ENV GNAME $USERNAME


################################################################################
# Mounting the XAUTHORITY file allow the x11 graphics to work
################################################################################
VOLUME $XAUTHORITY 


################################################################################
# Configure .bashrc properties
################################################################################
RUN echo 'alias ll="ls -hal --color"' >> ~/.bashrc


################################################################################
# Set the prompt for the bash shell
################################################################################
RUN echo 'export PS1="\[\033[01;31m\]\u@docker\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/$USERNAME/.bashrc


################################################################################
# get .spacemacs
################################################################################
RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d


################################################################################
# get the last good spacemacs version we use as hss
################################################################################
#RUN cd .emacs.d && git checkout 387d16545573517524a60dbebf0c6e71be58eab6


################################################################################
# lock spacemacs at latest as of Nov 13 2022
################################################################################
RUN cd .emacs.d && git checkout 57a7a0e63c4aecf810b19ca3fd49e5ae1a838126
RUN cd ~
RUN git init
RUN git remote add origin https://github.com/harmonicss/spacemacs.git
RUN git pull origin master
RUN cp .spacemacs.linux .spacemacs
RUN mkdir ~/.emacs.d/backup
RUN mkdir ~/.emacs.d/undo

################################################################################
# Install all the .spacemacs packages, twice as there as always stragglers to update
################################################################################
RUN emacs -nw -batch -u "$USERNAME" -q -kill
RUN emacs -nw -batch -u "$USERNAME" -q -kill


################################################################################
# Configure git
################################################################################
RUN git config --global user.name $USERNAME \
    && git config --global user.email $USERNAME@harmonicss.co.uk


################################################################################
# Install rust, problem getting a yes to install silently
#
#  https://github.com/rust-lang/rustup/issues/297
#    -s Runs the stdin of sh as the script.
#    -- is used to tell the shell that further arguments are not options:
################################################################################
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y


################################################################################
# install rust-analyser
################################################################################
RUN git clone https://github.com/rust-analyzer/rust-analyzer.git
# needs to be in the same directory
# cargo not in the /bin/sh path, for some reason
RUN cd rust-analyzer && /home/$USERNAME/.cargo/bin/cargo xtask install --server



#ENTRYPOINT ["emacs"]
CMD ["emacs"]
