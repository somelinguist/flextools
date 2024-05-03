#!/bin/bash
# Be sure to set execute permission for the script.

# Configure how to call python here:
CALLPYTHON=python

# Configure the prefix to the path where FieldWorks is installed.
# /usr is the default for installing via the apt package manager on Ubuntu:
if [ -d /usr/lib/fieldworks ]; then
    prefix=/usr
    is_flatpak=false
    pythonnet_version=$($CALLPYTHON -c "from importlib.metadata import version; print(version('pythonnet').split('.')[0])")
    sys_mono_version=$(mono --version=number)
else # default flatpak
    is_flatpak=true
    prefix=/var/lib/flatpak/app/org.sil.FieldWorks/current/active/files
fi

# In order to function correctly on Linux,
# we need to source a shell script (environ), which
# erases the path and several other environment variables.
# This function is called after the variables needed by FLEx
# are sourced in order to reset any variables needed by
# the caller which were erased.
resetenviron() {
    echo "Resetting environment"

}


# The following is adapted from the run-app shell script
# used to run an installed version of FLEx on Linux.
scriptdir=$(/bin/pwd)
lib=$prefix/lib/fieldworks
share=$prefix/share/fieldworks
sharedWsRoot=/var/lib/fieldworks
sharedWs=$sharedWsRoot/SIL/WritingSystemStore

# "$share/setup-user"

cd "$lib"; RUNMODE="INSTALLED" . environ;
cd $scriptdir

# reset environment as defined above
resetenviron

if [ $is_flatpak == false ] && [ $pythonnet_version == 3 ] ; then
    export MONO_GAC_PREFIX="/lib/mono/gac"
    export MONO_RUNTIME=$sys_mono_version
    export PYTHONNET_MONO_LIBMONO=/lib/libmono-2.0.so.1
fi

exec $CALLPYTHON scripts/RunFlexTools.py DEBUG
