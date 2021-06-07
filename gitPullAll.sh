#!/bin/sh

BASEDIR=${HOME}/src/github
BASEDIR2=${HOME}/go/src
# echo "\nUpdating projects in ${BASEDIR}\n"
BASEDIRS="$BASEDIR $BASEDIR2"

for f in $(find ${BASEDIRS} -type d -name '\.git')
do
    cd ${f}/..
    PWD=`pwd`
    echo "Updating $PWD..."
    REMOTES=`git remote`
    for r in $REMOTES; do
        echo "Fetching remote $r ok\n"
        # Note this is specifically for me.
        # pulling upstream master will probably mean you need to do a push.
        case $r in 
            upstream)  
                git fetch $r
                echo "+----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->"
                echo "|.-.   .-.   .-.   .-.   .-.   .  pulling                     .-.   .-"
                echo "|   '-'   '-'   '-'   '-'   '-'   $r master                '-'   '-'  "
                echo "+----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->"
                echo ""
                git pull $r main
                git pull $r master
                ;;
            *)
                git fetch $r
                
        esac
    done
    git pull
    echo "Updating submodules..."
    git submodule update --init --recursive
    git status -bs
    echo
done
echo "+----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->"
echo "                              All done."
echo "+----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+-----+--->"
exit 1

# next bit is no longer needed. Left in just in case
# yes i could have done a for loop above. meh.
echo "\nUpdating projects in ${BASEDIR2}\n"

for f in $(find ${BASEDIR2} -type d -name '\.git')
do
    cd ${f}/..
    pwd
    REMOTES=`git remote`
    for r in $REMOTES; do
        echo "Fetching remote $r ok\n"
        git fetch $r
    done
    git pull
    echo "Updating submodules..."
    git submodule update --init --recursive
    git status -bs
    echo
done
