# docker-spacemacs from Harmonic Software Systems

 Ed Liversidge, Harmonic Software Systems Ltd harmonicss.co.uk

 Installs a spacemacs docker continer with the following features:

 - fixed spacemacs version as of Nov 12 2022
 - .spacemacs config file used at HSS
 - git
 - gnu global for tagging
 - clangd, gcc and cppcheck for C/C++ live syntax checking using lsp-mode 
 - source code pro font
 - vim (incase emacs is bust)
 - curl
 - rust and rust-analyzer for rust lsp


 Build using (dont forget the .)
 ===========

    docker build -t harmonicss/spacemacs --build-arg XAUTHORITY=$XAUTHORITY --build-arg USERNAME=$USER .


 Run using
 =========

    docker run  -it --rm  -e DISPLAY --net=host -v ~/Projects:/home/$USER/Projects --name spacemacs harmonicss/spacemacs
 
 
 Start spacemacs
 ===============
  
    docker start spacemacs
