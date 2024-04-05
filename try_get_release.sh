# ./try_get_release.sh   user   repo   file   tag
#
# response=$? # 0=match, -1=corrupt, -2=missing
#

FILE=$4
TAG=$3
URL=https://github.com/$1/$2/releases/download/$TAG/$FILE

./split/build/split.exe --join https://github.com/mgood7123/$2/releases/download/$TAG/$FILE --out BUILD_DEBUG || mkdir BUILD_DEBUG

exit 0
