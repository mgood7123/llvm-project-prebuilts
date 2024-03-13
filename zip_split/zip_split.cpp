#include <cppfs/fs.h>
#include <cppfs/FileHandle.h>
#include <cppfs/FileIterator.h>

#include <sstream>
#include <fstream>

#include <memory>
#include <cstring>

#include <mmap.h>

#include <iostream>
#include <istream>
#include <ostream>
#include <fstream>
#include <sstream>

#ifdef _WIN32
#include <windows.h>
#include <fileapi.h>
#include <synchapi.h>
#define usleep(ms) Sleep(ms)
#define sleep(s) usleep(s*1000)
#else
#include <unistd.h>
#include <sys/types.h>
#endif

/*
if [[ $# == 0 ]]
    then
        find -type f -exec ./split.sh "{}" 25000 \;
        exit 0
fi

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
*/

static MMapHelper * map;
static std::shared_ptr<MMapHelper::Page> current_page;
static std::size_t page_size;
static const char* api;

uint64_t total_size = 0;
uint64_t next_commit_size = 0;
int split_number = 0;
uint64_t split_size = 0;

bool work(const char* path) {
    MMapHelper _map(path, 'r');
    map = &_map;

    auto map_len = map->length();

    if (!map->is_open()) {
        std::cout << "failed to open file: " << path << std::endl;
        return false;
    }

    if (map->length() <= page_size) {
        auto t = map->obtain_map(0, map->length());
        if (t.get() == nullptr) {
            throw std::runtime_error("FAILED TO OBTAIN MAPPING");
        }
        current_page = t;
    } else {
        auto t = map->obtain_map(0, page_size);
        if (t.get() == nullptr) {
            throw std::runtime_error("FAILED TO OBTAIN MAPPING");
        }
        current_page = t;
    }

    size_t current_index = 0;
    while (true) {
        if (total_size >= next_commit_size) {
            next_commit_size += split_size;
            std::cout << "committing...  [split." << std::to_string(split_number) << "] (total size: " << std::to_string(total_size) << " bytes, split size: " << std::to_string(split_size) << " bytes, next_commit_size: " << std::to_string(next_commit_size) << " bytes)" << std::endl;
            usleep(1);
            split_number++;
        }
        if (map->length() < (current_index + page_size)) {
            auto t = map->obtain_map(current_index, map->length() - current_index);
            if (t.get() == nullptr) {
                throw std::runtime_error("FAILED TO OBTAIN MAPPING");
            }
            current_page = t;
            std::cout << "compressing... [split." << std::to_string(split_number) << "] (" << std::to_string(map_len) << "/" << std::to_string(map_len) << " bytes, file: '" << path << "')" << std::endl;
            //usleep(1);
            total_size += map_len - current_index;
            map = nullptr;
        }
        else {
            auto t = map->obtain_map(current_index, page_size);
            if (t.get() == nullptr) {
                throw std::runtime_error("FAILED TO OBTAIN MAPPING");
            }
            current_page = t;
            current_index += page_size;
            std::cout << "compressing... [split." << std::to_string(split_number) << "] (" << std::to_string(current_index+page_size) << "/" << std::to_string(map_len) << " bytes, file: '" << path << "')" << std::endl;
            //usleep(1);
            total_size += page_size;
        }
        if (map == nullptr) {
            return true;
        }
    }
}

void invoke_dir(const std::string& path)
{
    cppfs::FileHandle handle = cppfs::fs::open(path);

    if (!handle.exists()) {
        std::cout << "item does not exist:  " << path << std::endl;
        return;
    }

    if (handle.isDirectory())
    {
        // std::cout << "entering directory:  " << path << std::endl;
        for (cppfs::FileIterator it = handle.begin(); it != handle.end(); ++it)
        {
            invoke_dir(path + "/" + *it);
        }
        // std::cout << "leaving directory:  " << path << std::endl;
    }
    else if (handle.isFile()) {
        if (handle.size() == 0) {
            std::cout << "skipping zero length file: " << path << std::endl;
        }
        else {
            if (!work(path.c_str())) exit(-1);
        }
    } else {
        std::cout << "unknown type:  " << path << std::endl;
    }
}

int main(int argc, char** argv) {
	if (argc > 1) {
        api = mmaptwo::get_os() == mmaptwo::os_unix ? "mmap(2)" : mmaptwo::get_os() == mmaptwo::os_win32 ? "MapViewOfFile" : "(unknown api)";
        page_size = mmaptwo::get_page_size()*10; // 400 kb to 800 kb page size
        split_size = page_size * 1000; // 400 mb to 800 mb split size
        next_commit_size = split_size;
        std::cout << "using mmap (" << api << ") api with a page size of " << std::to_string(page_size) << std::endl;

        invoke_dir(argv[1]);
        
        std::cout << "committing...  [split." << std::to_string(split_number) << "] (total size: " << std::to_string(total_size) << " bytes, split size: " << std::to_string(split_size) << " bytes, next_commit_size: " << std::to_string(next_commit_size) << " bytes)" << std::endl;
        usleep(1);

        std::cout << "finalizing...  [split." << std::to_string(split_number) << "]" << std::endl;
        usleep(150);
        std::cout << "finalized" << std::endl;
    }
	return 0;
}