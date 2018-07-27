#!/bin/sh

# Don't use '$(command ...)' when using sh(1)
# $0 would be "./..."

#if [ "$PWD" != "`dirname \"$0\"`" ]; then
#	echo "Wrong working directory"
#	exit 1
#fi

# makes things easier if script needs debugging
if [ x${FTB_VERBOSE} = xyes ]; then
    set -x
fi

# Read pack related settings from external setting file
. ./settings.sh

# Read settings defined by local server admin
if [ -f settings-local.sh ]; then
    . ./settings-local.sh
fi

# cleaner code
eula_false() {
    grep -Fq 'eula=false' eula.txt
}


# run install script if MC server or launchwrapper s missing
if [ ! -f ${JARFILE} -o ! -f libraries/${LAUNCHWRAPPER} ]; then
    echo "Missing required jars. Running install script!"
    sh ./FTBInstall.sh
fi

# check eula.txt
if [ -f eula.txt ] && eula_false ; then
    echo "Make sure to read eula.txt before playing!"
    echo "To exit press <enter>"
    read ignored
    exit
fi

# if eula.txt is missing inform user and start MC to create eula.txt
if [ ! -f eula.txt ]; then
    echo "Missing eula.txt. Startup will fail and eula.txt will be created"
    echo "Make sure to read eula.txt before playing!"
    echo "To continue press <enter>"
    read ignored
fi

echo $$ > server.pid
exec "$JAVACMD" -server -Xmx${MAX_RAM} ${JAVA_PARAMETERS} -jar ${FORGEJAR} nogui
