#
# docker build -t "harmonicss/spacemacs" .
#
FROM ubuntu:latest

RUN apt update && \
    apt install -y software-properties-common
RUN add-apt-repository ppa:kelleyk/emacs
RUN apt update    
RUN apt install -y git

RUN apt install -y emacs28
RUN apt install -y global

# Install lsp clangd-13 (C language LSP server for code completion)
# and gcc for syntax checking
RUN apt install -y clangd-13
RUN apt install -y gcc
RUN apt install -y cppcheck

# pip for python lsp server
RUN apt update
RUN apt install -y pip

RUN useradd -ms /bin/bash eliversi && usermod -aG eliversi eliversi

USER root

USER eliversi
ENV UID="1000"
ENV HOME /home/eliversi
WORKDIR /home/eliversi

RUN echo 'alias ll="ls -hal --color"' >> ~/.bashrc

RUN pip install python-lsp-server

# set the prompt for the bash shell
#RUN echo 'export PS1="[\u@docker] \W $ "' >> /home/eliversi/.bashrc
RUN echo 'export PS1="\[\033[01;31m\]\u@docker\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/eliversi/.bashrc

# get .spacemacs
RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

# get the last good spacemacs version we use as hss
RUN cd .emacs.d && git checkout 387d16545573517524a60dbebf0c6e71be58eab6 
RUN cd ~
RUN git init
RUN git remote add origin https://github.com/harmonicss/spacemacs.git
RUN git pull origin master
#RUN cp .spacemacs .spacemacs.orig
RUN cp .spacemacs.linux .spacemacs
RUN mkdir ~/.emacs.d/backup
RUN mkdir ~/.emacs.d/undo

# install all the .spacemacs packages, twice as there are always stragglers to update
RUN emacs -nw -batch -u "eliversi" -q -kill
RUN emacs -nw -batch -u "eliversi" -q -kill

# Configure git
RUN git config --global user.name eliversi \
    && git config --global user.email ed@harmonicss.co.uk

RUN clangd-13 &

CMD ["bash"]