#! /bin/bash
#===================================================================
#
#
#   ██╗  ██╗██╗██╗  ██╗██╗███████╗██████╗  █████╗ 
#   ╚██╗██╔╝╚═╝███╗ ██║╚═╝╚═██╔══╝██╔══██╗██╔══██╗
#    ╚███╔╝ ██╗███████║██╗  ██║   ██████╔╝██║  ╚═╝
#    ██╔██╗ ██║██╔═███║██║  ██║   ██╔══██╗██║  ██╗
#   ██╔╝╚██╗██║██║ ╚██║██║  ██║   ██║  ██║╚█████╔╝
#   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝  ╚═╝ ╚════╝ 
#
#
# 	.xinitrc configuration by adipopbv (adi.pop.bv@gmail.com).
# 	~/.xinitrc - X11's xinit sourced file (WM, graphical stuff etc).
# 	Go to https://wiki.archlinux.org/index.php/Xinit for more info.
#
#
#===================================================================

# Start optimus prime offloading
# /usr/bin/prime-offload

# disable mouse acceleration
xset m 0 0 &

# numlock on after boot
numlockx &

# keyboard layout for pl
setxkbmap $(cat .Xkbmap) &

# Start i3 session (needs to be last)
exec i3
