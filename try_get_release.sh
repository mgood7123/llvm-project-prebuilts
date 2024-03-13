# ./try_get_release.sh   user   repo   file   tag
#
# response=$? # 0=match, -1=corrupt, -2=missing
#

set -v
set -x

FILE=$4
TAG=$3
URL=https://github.com/$1/$2/releases/download/$TAG/$FILE
R=$(curl --silent -I $URL | grep -E "^HTTP" | awk -F " " '{print $2}')
RSHA=$(curl --silent -I $URL.sha512 | grep -E "^HTTP" | awk -F " " '{print $2}')
if [[ ("$R" = "200" || "$R" = "302") && ("$RSHA" == "200" || "$RSHA" == "302") ]]
    then
        echo "file '$FILE' exists in releases"
        curl -L $URL.sha512 -o $FILE.sha512
        curl -L $URL -o $FILE
        cat $FILE.sha512
        if sha512sum -c $FILE.sha512
            then
                echo 'extracting build directory...'
                tar -xf $FILE
                echo 'extracted build directory'
                rm $FILE
                rm $FILE.sha512
                exit 0
            else
                echo 'build directory cache corrupted, rebuilding'
                mkdir BUILD_DEBUG
                rm $FILE
                rm $FILE.sha512
                exit -1
        fi
    else
        echo 'build directory does not exist in cache'
        mkdir BUILD_DEBUG
        exit -2
fi
