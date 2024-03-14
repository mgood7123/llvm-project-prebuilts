#include <cppfs/fs.h>
#include <cppfs/FileHandle.h>
#include <cppfs/FileIterator.h>

#include <sstream>
#include <fstream>

#include <memory>
#include <cstring>

#include "mmap.h"

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

static MMapHelper * map;
static std::shared_ptr<MMapHelper::Page> current_page;
static std::size_t page_size;
uint64_t next_commit_size;
static const char* api;

struct SplitFile {
    cppfs::FileHandle handle;
    std::unique_ptr<std::ostream> file_out_stream;
    std::string split_file;
    uint64_t total_size = 0;
    int split_number = 0;
    bool open = false;
    bool first_open = true;
    const char* current_path = nullptr;
    std::size_t current_size = 0;

    void close_bin() {
        if (open) {
            std::cout << "flushing stream" << std::endl;
            file_out_stream->flush();
            file_out_stream.reset();
            std::cout << "closed stream" << std::endl;
            open = false;
        }
    }

    void open_bin(const std::string& f) {
        close_bin();
        handle = cppfs::fs::open(f.c_str());
        handle.remove();
        file_out_stream = handle.createOutputStream(std::ios::binary);
        if (!file_out_stream) throw new std::runtime_error("could not create output stream");
        open = true;
        std::cout << "opened stream" << std::endl;
    }

    void write_bin(const char* ptr, std::streamsize size) {
        if (!open) {
            if (first_open) {
                first_open = false;
            }
            else {
                split_number++;
            }
            split_file = "split." + std::to_string(split_number);
            open_bin(split_file);
            std::cout << "processing... [" << split_file.c_str() << "] (" << std::to_string(size) << "/" << std::to_string(current_size) << " bytes, file: '" << current_path << "')" << std::endl;
        }
        std::cout << "file_out_stream->write(ptr, " << std::to_string(size) << ")" << std::endl;
        file_out_stream->write(ptr, size);
        total_size += size;
    }

    template<typename T>
    void write_bin(const T& value) {
        write_bin(reinterpret_cast<const char*>(&value), static_cast<std::streamsize>(sizeof(char) * sizeof(T)));
    }

    template<typename T>
    void write_bin(const T* ptr, std::size_t elements) {
        write_bin(reinterpret_cast<const char*>(ptr), static_cast<std::streamsize>(sizeof(char) * (sizeof(T) * elements)));
    }

    void write_bin(const void* ptr, std::size_t elements) {
        write_bin(reinterpret_cast<const char*>(ptr), static_cast<std::streamsize>(sizeof(char) * elements));
    }

    void commit() {
        if (open) {
            next_commit_size += page_size;
            std::cout << "committing...  [" << split_file.c_str() << "] (total size: " << std::to_string(total_size) << " bytes, split size: " << std::to_string(page_size) << " bytes, next_commit_size: " << std::to_string(next_commit_size) << " bytes)" << std::endl;
            close_bin();
        }
    }

    void finalize() {
        commit();
        std::cout << "finalizing...  [" << split_file.c_str() << "]" << std::endl;
        std::cout << "finalized" << std::endl;
    }

    void write(const char* file_path, std::size_t size, void* ptr, std::size_t bytes) {
        std::cout << "request to write '"<< std::to_string(bytes) << "' bytes" << std::endl;
        if (current_path != file_path) {
            current_path = file_path;
            current_size = size;
            write_bin(file_path, strlen(file_path)+1);
            write_bin(size);
        }
        if (total_size >= next_commit_size) {
            std::cout << "total_size >= next_commit_size (total size: " << std::to_string(total_size) << " bytes, split size: " << std::to_string(page_size) << " bytes, next_commit_size: " << std::to_string(next_commit_size) << " bytes)" << std::endl;
            commit();
        }
        if (size != 0 && ptr != nullptr && bytes != 0) {
            write_bin(ptr, bytes);
        }
    }
};

SplitFile split;

bool work(const char* path, std::size_t size) {
    if (size == 0) {
        split.write(path, size, nullptr, 0);
        return true;
    }
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
        if (map->length() < (current_index + page_size)) {
            auto t = map->obtain_map(current_index, map->length() - current_index);
            if (t.get() == nullptr) {
                throw std::runtime_error("FAILED TO OBTAIN MAPPING");
            }
            current_page = t;
            split.write(path, size, t.get(), map_len - current_index);
            map = nullptr;
        }
        else {
            auto t = map->obtain_map(current_index, page_size);
            if (t.get() == nullptr) {
                throw std::runtime_error("FAILED TO OBTAIN MAPPING");
            }
            current_page = t;
            current_index += page_size;
            split.write(path, size, t.get(), page_size);
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
        if (!work(path.c_str(), handle.size())) exit(-1);
    } else {
        std::cout << "unknown type:  " << path << std::endl;
    }
}

int main(int argc, char** argv) {
	if (argc > 1) {
        api = mmaptwo::get_os() == mmaptwo::os_unix ? "mmap(2)" : mmaptwo::get_os() == mmaptwo::os_win32 ? "MapViewOfFile" : "(unknown api)";
        page_size = mmaptwo::get_page_size();
        next_commit_size = page_size;
        std::cout << "using mmap (" << api << ") api with a page size of " << std::to_string(page_size) << std::endl;
        std::cout << "using split size of " << std::to_string(page_size) << " bytes" << std::endl;

        invoke_dir(argv[1]);

        split.finalize();
    }
	return 0;
}