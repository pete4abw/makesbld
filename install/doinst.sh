# check makesbld etc files

# trick for renaming new and old files borrowed from Slackware
# installation scripts by P. Volkerding
config() {
    NEW="$1"
    OLD="`dirname $NEW`/`basename $NEW .new`"
    # If there's no config file by that name, mv it over:
    if [ ! -r $OLD ]; then
        mv $NEW $OLD
    elif [ "`cat $OLD | md5sum`" = "`cat $NEW | md5sum`" ]; then # toss the redundant copy
        rm $NEW
    fi
    # Otherwise, we leave the .new copy for the admin to consider...
}

config /etc/makesbld/makesbld.conf.new
config /etc/makesbld/mirrors.conf.new
