bsize=$(($2))
flength=$(stat --printf=%s "$1")
echo "splitting file $1 with into chunks of $bsize bytes"
pieces=$((($flength-1) / $bsize))
for i in $(seq 0 $pieces)
	do
		dd if="$1" bs=$bsize skip=$i count=1 2>/dev/null >/dev/null
		if (($bsize*($i+1) > $flength))
			then
				echo "wrote $flength/$flength bytes ($(($i+1))/$(($pieces+1)))"
			else
				echo "wrote $(($bsize*($i+1)))/$flength bytes ($(($i+1))/$(($pieces+1)))"
		fi
done
