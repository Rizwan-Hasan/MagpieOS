#!/bin/bash

# ##############################################
set -e -u
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /bin/bash root
cp -aT /etc/skel/ /root/
chmod 700 /root
# ##############################################

# ################################################## Creating liveuser #####################################################
useradd -m -p "" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash liveuser
cp -avT /etc/skel/ /home/liveuser/
chown -R liveuser:users /home/liveuser
chmod 700 /home/liveuser/
# ##########################################################################################################################

# ### Giving root permission for live user /etc/sudoers ####
rm -v /etc/sudoers
mv -v /etc/skel/.magpie-settings/sudoers-backup /etc/sudoers
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers
# ##########################################################

# ############### Importing pacman keys ############
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys
# ##################################################

# ##################### OS Information ########################
rm -v /etc/lsb-release
mv -v /etc/skel/.magpie-settings/lsb-release /etc/lsb-release
rm -v /usr/lib/os-release
mv -v /etc/skel/.magpie-settings/os-release /usr/lib/os-release
# #############################################################

# ###################### GDM Wayland Disabling ##################
rm -v /etc/gdm/custom.conf
mv -v /etc/skel/.magpie-settings/custom.conf /etc/gdm/custom.conf
# ###############################################################

# ########## Adding grub-theme to /etc/default/grub file ##########
rm -v /etc/default/grub
mv -v /etc/skel/.magpie-settings/etc-default-grub /etc/default/grub
# #################################################################

# #############################################################################
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
# #############################################################################

# ############################# Removing packages ############################################################
pacman -R --noconfirm swell-foop tali gnome-mines gnome-tetravex gnome-recipes accerciser gnome-boxes
pacman -R --noconfirm gnome-nibbles gnome-sudoku hitori quadrapassel gnome-builder devhelp lftp gnome-software
pacman -R --noconfirm gnome-robots five-or-more four-in-a-row gnome-mahjongg ipython gnome-backgrounds
pacman -R --noconfirm gnome-klotski gnome-taquin iagno lightsoff polari gnome-multi-writer epiphany 
# ############################################################################################################

# ############ Installing custom packages to rootfs ###############
cd /etc/skel/.magpie-packages && pacman -U --noconfirm *.pkg.tar.xz
# #################################################################

# ### Changing pacman.conf for magpie-mirrrorlist support ##
rm -drv /etc/pacman.conf
cp -v /etc/skel/.magpie-settings/pacman.conf /etc/
# ##########################################################

# ############################ MagpieOS Install Desktop File #####################################
cp -v /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
chown liveuser:wheel /home/liveuser/.config/autostart/calamares.desktop
chmod +x /home/liveuser/.config/autostart/calamares.desktop
# ################################################################################################

# ########## Adding custom /etc/nanorc for Nano ########
mv -vf /etc/skel/.magpie-settings/etc-nanorc /etc/nanorc
# ######################################################

# ######## Copying release info of MagpieOS to livecd ########
rm /etc/arch-release
cp /etc/skel/.magpie-settings/magpie-release /etc/
cp /etc/skel/.magpie-settings/magpie-release /etc/arch-release
# ############################################################

# ######### Adding custom mkinitcpio config ##########
mv -vf /etc/skel/.magpie-settings/mkinitcpio.conf /etc/
# ####################################################

# ######## Adding custom ntp config ########
rm /etc/ntp.conf
cp /etc/skel/.magpie-settings/ntp.conf /etc/
# ##########################################

# ######## Adding red lined bash theme for root ##########
mv -f /etc/skel/.magpie-settings/bashrc_root /root/.bashrc
# ########################################################

# ###################### Adding MagpieOS Logo in gdm login screen #############################
sudo -u gdm dbus-launch gsettings set org.gnome.login-screen logo '/etc/skel/.mapieos-logo.png'
dconf update
# #############################################################################################

# ###################### Adding cursor theme in  gdm login screen ########################
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface cursor-theme 'Neon-Blue'
dconf update
# ########################################################################################

# ####################### Tap to click support for gnome settings ############################
rm -rf /usr/share/X11/xorg.conf.d/70-synaptics.conf
sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
dconf update
# ############################################################################################

# ########### Adding Gnome File Manager(Nautilus) drive mount without password #############
cp -f /etc/skel/.magpie-settings/org.freedesktop.UDisks2.policy /usr/share/polkit-1/actions/
# ##########################################################################################

# ###############################
rm -dr /etc/skel/.magpie-settings
rm -dr /etc/skel/.magpie-packages
# ###############################

# ## Unmuting speakers ##
amixer sset Master unmute
# #######################

# ### Fixing Permisssion ##
chmod 755 /
# #########################

# ###########################################################################
systemctl enable pacman-init.service choose-mirror.service NetworkManager gdm
systemctl enable ntpd bluetooth org.cups.cupsd
systemctl set-default graphical.target
# ###########################################################################
