#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (you can run your windows manager from here)

if [systemd-detect-virt = "oracle"];
	/usr/bin/VBoxClient-all
fi
