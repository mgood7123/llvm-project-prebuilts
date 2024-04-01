cd $1

cmake -B build_release -S . -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=rootfs
cmake --build build_release
cmake --install build_release

rootfs/bin/xz.exe --version

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

lzma_path=rootfs/lib/liblzma.a
lzma_found=1

# 4. Check for the specific byte pattern in lzma
if [ "$lzma_found" -eq 0 ]; then
    byte_pattern=$(hexdump -ve '1/1 "%.2x"' "$lzma_path" | grep -q 'f30f1efa554889f54c89ce5389fb81e7000000804883ec28488954241848894c2410'; echo $?)
    if [ "$byte_pattern" -eq 0 ]; then
        byte_pattern_found=0
    else
        byte_pattern_found=1
    fi
else
    byte_pattern_found=1
fi

# Output results
echo -ne "LZMA vulnerable version: " 
if [ "$byte_pattern_found" -eq 0 ]; then
    echo -e "${RED}YES${NC} (byte pattern found)"
else
    echo -e "${GREEN}NO${NC}"
fi

# Output conclusion
echo
if [ "$byte_pattern_found" -eq 0 ]; then
	echo -e "${RED}- Malicious XZ/LZMA found: YES ${NC}" 
    affected=0
else
	echo -e "${GREEN}- Malicious XZ/LZMA found: NO ${NC}"
	affected=1
fi

if [ "$affected" -eq 0 ]; then
    echo -e "Conclusion: ${RED}LIKELY TO BE VULNERABLE TO CVE-2024-3094 ${NC}"
else
    echo -e "Conclusion: ${GREEN}NOT VULNERABLE TO CVE-2024-3094 ${NC}"
fi
echo
