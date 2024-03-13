#include <memory>
#include <iostream>
#include <cstring>

#include <mmaptwo.hpp>

class MMapHelper {
    public:
    /**
    * \brief Destructor; closes the file.
    * \note The destructor will not free any acquired pages!
    */
    using Map = mmaptwo::mmaptwo_i;
    using Page = mmaptwo::page_i;

    private:
    std::shared_ptr<MMapHelper::Map> allocated_file;
    bool open = false;
    bool zero_size = false;
    std::size_t page_size;
    const char * api;

    void error(std::exception const& e);

    public:

    MMapHelper();

    MMapHelper(const char * path, char mode);

    MMapHelper(const unsigned char * path, char mode);

    MMapHelper(const wchar_t * path, char mode);

    bool operator==(const MMapHelper & other) const;
    bool operator!=(const MMapHelper & other) const;

    const char * get_api() const;
    size_t get_page_size() const;

    std::shared_ptr<MMapHelper::Page> obtain_map(size_t offset, size_t size) const;

    bool is_open() const;

    size_t length() const;

    private:

    std::shared_ptr<MMapHelper::Page> obtain_map_impl(size_t offset, size_t size, std::shared_ptr<MMapHelper::Map> allocated_file) const;
};
