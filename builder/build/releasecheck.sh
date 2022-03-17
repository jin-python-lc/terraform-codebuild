#!/bin/sh
echo -n 'リリースする場合は"y"を入力してください。 [Y/n]: '
read -t 10 CHECK

case $CHECK in
  [Yy]* )
    BOOLEAN=1
    export BOOLEAN
    echo "Approved"
    ;;
  * )
    BOOLEAN=0
    export BOOLEAN
    echo "Aborted"
    ;;
esac