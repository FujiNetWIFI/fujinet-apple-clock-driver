#!/bin/bash

function show_help {
  echo "Usage: $(basename "$0") [-a] DISK.po FILE_TO_ADD [NAME]"
  echo "  Copies FILE_TO_ADD to DISK.po giving it name NAME if autostart flag is not present"
  echo
  echo "  -a : autostart enabled. marks file as STARTUP, booting it directly rather than bitsy bye."
  echo "       For makefile convenience, NAME is allowed if -a specified, but it will be ignored."
  echo
  echo "  -l : autostart via LOADER.SYSTEM"
  exit 1
}

# don't default to autostart, this script's job is normally to add files to a disk. You have to mark it as autostart rather than it always do that.
AUTOSTART=0
LOADER=0
IS_SYSTEM=0
while getopts "alsh" flag
do
  case "$flag" in
    a) AUTOSTART=1 ;;
    l) LOADER=1 ;;
    s) IS_SYSTEM=1 ;;
    h) show_help ;;
    *) show_help ;;
  esac
done
shift $((OPTIND - 1))

#if [[ ($AUTOSTART -eq 0 && $# -ne 3) || ($AUTOSTART -eq 1 && $# -lt 2) ]]; then
#  echo "ERROR: Bad argument count."
#  show_help
#fi

if [ -z "$(which java)" ]; then
  echo "Unable to find java on command line. You must have a working java at least version 11 to use this script."
  exit 1
fi

DISKFILE="$1"
if [ ! -f "$DISKFILE" ]; then
  echo "Unable to find target DISK."
  exit 1
fi

INFILE="$2"
if [ ! -f "$INFILE" ]; then
  echo "Unable to find file to put on disk."
  exit 1
fi

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$SCRIPT_DIR/get-binaries.sh"

NAME="$3"

if [ $AUTOSTART -eq 1 ]; then 
  ${AC} -d "$DISKFILE" QUIT.SYSTEM
  NAME="startup"
fi

if [ $LOADER -eq 1 ]; then 
  ${AC} -d "$DISKFILE" QUIT.SYSTEM
  ${AC} -p "$DISKFILE" "$NAME".SYSTEM sys < "`cl65 --print-target-path`/apple2/util/loader.system"
fi

if [ $IS_SYSTEM -eq 1 ]; then
  export ACX_DISK_NAME="$DISKFILE"
  SRC_PRODOS="$SCRIPT_DIR/ProDOS_2_4_2.dsk"
  # NAME=${NAME}.SYSTEM
  # ${ACX} unlock QUIT.SYSTEM
  # ${ACX} unlock BITSY.BOOT
  # ${ACX} unlock BASIC.SYSTEM
  ${ACX} rm -f QUIT.SYSTEM
  ${ACX} rm -f BITSY.BOOT
  ${ACX} rm -f BASIC.SYSTEM
fi

${AC} -as "$DISKFILE" "$NAME" < "$INFILE"

if [ $IS_SYSTEM -eq 1 ]; then
  # add files back in
  echo "locking >$NAME<"
  ${ACX} lock "$NAME"
  ${ACX} cp --from "$SRC_PRODOS" BITSY.BOOT QUIT.SYSTEM BASIC.SYSTEM
fi
