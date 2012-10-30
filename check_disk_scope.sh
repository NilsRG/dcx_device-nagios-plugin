#!/usr/bin/env bash
#
# Copyright (c) 2012 Teknograd AS.
# Written by: Nils R Grotnes (nils.grotnes@gmail.com)
#
# Some bits taken from send_nrdp.sh:
# Copyright (c) 2010-2012 Nagios Enterprises, LLC.
# Written by: Scott Wilkerson (nagios@nagios.org)
###########################

PROGNAME=$(basename $0)
RELEASE="Revision 0.1"

print_release() {
    echo "$RELEASE"
}
print_usage() {
    echo ""
    echo "$PROGNAME $RELEASE - Check disk usage by DC-X per scope"
    echo ""
    echo "Usage: $PROGNAME -a APP -s SCOPE -w WARN_LEVEL -c CRITICAL_LEVEL"
    echo ""
    echo "Usage: $PROGNAME -h display help"
    echo ""
}
print_help() {
    print_usage
        echo ""
        echo "This script is used to check disk usage per scope used by DC-X"
        echo ""
        echo "Required:"
        echo "    -a","    Which customer app to check. Currently only 'nhst'"
        echo "    -s","    Scope. Logical devices. Currently 'archive', 'lowres', 'statistics', 'upload' or 'workflow'"
        echo "    -w","    Warning when space left is less than this. Percentages not supported (yet)."
        echo "    -c","    Critical when space left is less than this. Percentages not supported (yet)."
        echo ""
        echo "Optional:"
        echo "    -u","    Print usage"
        echo "    -r","    Print release version"
        echo "    -h","    What you just did..."
        exit 0
}

# Parse parameters

while getopts "a:s:w:c:uhv" option
do
  case $option in
    a) app=$OPTARG ;;
    s) scope=$OPTARG ;;
    w) warning=$OPTARG ;;
    c) critical=$OPTARG ;;
    u) print_usage ;;
    h) print_help 0 ;;
    v) print_release
        exit 0 ;;
  esac
done

if [ ! $app ]; then
        echo "UNKNOWN: Missing app in commandline parameters!"
 exit 3
fi
if [ ! $scope ]; then
        echo "UNKNOWN: Missing scope in commandline parameters!"
 exit 3
fi
if [ ! $warning ]; then
        echo "UNKOWN: Missing wanning level in commandline parameters!"
 exit 3
fi
if [ ! $critical ]; then
        echo "UNKNOWN: Missing critical level in commandline parameters!"
 exit 3
fi

RESULT=$(export DC_CONFIGDIR=/etc/opt/dcx;/usr/local/bin/php /opt/dcx/bin/dcx_device.php -s --app $app 2>&1)
if [ $? != "0" ]; then
        echo "UNKNOWN: $RESULT"
        exit 3
fi

RESULT=$(echo "$RESULT" | tail -n 8 | grep "$scope" | cut -b31- | cut -d ' ' -f1 | cut -d '.' -f1)
if [ $RESULT -gt $warning ]; then
        echo "OK - free space: $RESULT GB | freespace=$RESULT"
        exit 0
fi
if [ $RESULT -lt $critical ]; then
        echo "CRITICAL - free space: $RESULT GB | freespace=$RESULT"
        exit 2
fi
if [ $RESULT -gt $critical ]; then
        echo "WARNING - free space: $RESULT GB | freespace=$RESULT"
        exit 1
fi
