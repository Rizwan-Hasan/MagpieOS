#!/usr/bin/env python3

import os
import sys
import json
import shlex
import subprocess


class MainWork():

    def __init__(self):
        self.lsb_release = None
        self.magpie_release = None
        self.os_release = None
        self.verInfo = None

        with open('version.json', 'r') as file:
            self.verInfo = json.loads(file.read())

        with open('build.sample', 'r') as file:
            self.scriptData = file.read()

        self.clean()
        self.distroInfoProcess()
        self.scriptBuilding()
        self.runCommand()
        self.clean()

    def distroInfoProcess(self):

        self.lsb_release = (
            """LSB_VERSION=1.4
        DISTRIB_ID=""" + self.verInfo['distro name'] + """
        DISTRIB_RELEASE=""" + self.verInfo['version'] + """
        DISTRIB_CODENAME=""" + self.verInfo['codename'] + """
        DISTRIB_DESCRIPTION=""" + "\"" + self.verInfo['distro name'] + "\""
        )

        self.magpie_release = self.verInfo['distro name'] + " " + self.verInfo['codename']

        self.os_release = (
            """NAME=""" + self.verInfo['distro name'] + """
        PRETTY_NAME=""" + self.verInfo['pretty name'] + """
        ID=""" + self.verInfo['distro name'] + """
        ID_LIKE=""" + self.verInfo['base'] + """
        VERSION_ID=""" + self.verInfo['version'] + """
        ANSI_COLOR="0;36"
        """
        )

        with open('airootfs/etc/skel/.magpie-settings/' + 'lsb-release', 'w') as file:
            file.write(self.lsb_release)

        with open('airootfs/etc/skel/.magpie-settings/' + 'os-release', 'w') as file:
            file.write(self.os_release)

        with open('airootfs/etc/skel/.magpie-settings/' + 'magpie-release', 'w') as file:
            file.write(self.magpie_release)

    def scriptBuilding(self):
        self.scriptData = self.scriptData.replace("#SHELL_LOCATION", "#!/bin/bash")
        self.scriptData = self.scriptData.replace(
            'distro_name="@"', 'distro_name=' + "\"" + self.verInfo['distro name'] + "\"")
        self.scriptData = self.scriptData.replace(
            'iso_name="@"', 'iso_name=' + "\"" + self.verInfo['iso name'] + "\"")
        self.scriptData = self.scriptData.replace(
            'iso_label="@"', 'iso_label=' + "\"" + self.verInfo['iso label'] + "\"")
        self.scriptData = self.scriptData.replace(
            'iso_publisher="@"', 'iso_publisher=' + "\"" + self.verInfo['iso publisher'] + "\"")
        self.scriptData = self.scriptData.replace(
            'iso_application="@"', 'iso_application=' + "\"" + self.verInfo['iso application'] + "\"")

        with open('build.sh', 'w') as file:
            file.write(self.scriptData)
        subprocess.call('chmod +x build.sh', shell=True)
        subprocess.call('mkdir airootfs/root', shell=True)
        subprocess.call('sudo chmod 777 airootfs/root', shell=True)
        subprocess.call('cp -f root_customizer.sh airootfs/root/customize_airootfs.sh', shell=True)
        subprocess.call('sudo chmod +x airootfs/root/customize_airootfs.sh', shell=True)
        subprocess.call('sudo chmod 777 airootfs/root/customize_airootfs.sh', shell=True)

    def runCommand(self):
        check = int(1)
        check = os.system('sudo ./build.sh -v')
        if check is 0:
            os.system('sudo chmod 777 ISO_Image ISO_Image/*')

    def clean(self):
        clean()


def clean():
	subprocess.call('sudo rm -rf airootfs/root', shell=True)
	subprocess.call('sudo rm -rf build.sh build_work', shell = True)
	subprocess.call('sudo rm -rf airootfs/etc/skel/.magpie-settings/os-release', shell = True)
	subprocess.call('sudo rm -rf airootfs/etc/skel/.magpie-settings/lsb-release', shell = True)
	subprocess.call('sudo rm -rf airootfs/etc/skel/.magpie-settings/magpie-release', shell = True)

def main(arg):
    if os.getuid() is 0:
        try:
            if(len(arg) != 0 and arg[1] == 'clean'):
                clean()
                print('Cleaned..')
                return
        except IndexError:
            pass
        try:
            MainWork()
        except KeyboardInterrupt:
            clean()
            print('error: operation has been canceled by ' + subprocess.getoutput("echo $(whoami)"))
    else:
        print('error: you cannot perform this operation unless you are root.')


if __name__ == '__main__':
    main(sys.argv)

# End
