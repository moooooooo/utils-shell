#/bin/sh

# wake up PCs
echo "------------------------------"
echo " Waking up $1 ok"
echo "------------------------------"
case $1 in
    pm-ufw)
        wakeonlan 00:25:22:b1:54:ff
        # wakeonlan -i 192.168.0.179
        ;;
    pm-ufw2)
        wakeonlan 50:e5:49:42:90:39
        # wakeonlan -i 192.168.0.155
esac

exit 0
