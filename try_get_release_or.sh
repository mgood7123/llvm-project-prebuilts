# ./try_get_release_or.sh   user   repo   tag1   file1   or_tag2   or_file2
#
# response=$? # 0=match, -1=corrupt, -2=missing
#
# in non-0 it is an error and we cannot continue
#
# note we may have a backup cache somewhere   latest or prev1 or prev2 or ...
#

set -v
set -x

TAG=$3
FILE=$4
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
                echo 'build directory corrupted, using previous cache'
                TAG=$5
                FILE=$6
                URL=https://github.com/$1/$2/releases/download/$TAG/$FILE
                R=$(curl --silent -I $URL | grep -E "^HTTP" | awk -F " " '{print $2}')
                RSHA=$(curl --silent -I $URL.sha512 | grep -E "^HTTP" | awk -F " " '{print $2}')
                if [[ ("$R" = "200" || "$R" = "302") && ("$RSHA" == "200" || "$RSHA" == "302") ]]
                    then
                        echo "previous cache file '$FILE' exists in releases"
                        curl -L $URL.sha512 -o $FILE.sha512
                        curl -L $URL -o $FILE
                        cat $FILE.sha512
                        if sha512sum -c $FILE.sha512
                            then
                                echo 'extracting previous cache build directory...'
                                tar -xf $FILE
                                echo 'extracted previous cache build directory'
                                rm $FILE
                                rm $FILE.sha512
                                exit 0
                            else
                                echo 'previous cache build directory cache corrupted, cannot continue'
                                rm $FILE
                                rm $FILE.sha512
                                exit -1
                        fi
                    else
                        echo 'previous cache build directory does not exist in cache, cannot continue'
                        exit -2
                fi
        fi
    else
        echo 'build directory does not exist in cache, using previous cache'
        TAG=$5
        FILE=$6
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
                        echo 'extracting previous cache build directory...'
                        tar -xf $FILE
                        echo 'extracted previous cache build directory'
                        rm $FILE
                        rm $FILE.sha512
                        exit 0
                    else
                        echo 'previous cache build directory cache corrupted, cannot continue'
                        rm $FILE
                        rm $FILE.sha512
                        exit -1
                fi
            else
                echo 'previous cache build directory does not exist in cache, cannot continue'
                exit -2
        fi
fi
