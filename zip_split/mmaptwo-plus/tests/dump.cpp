
#include "../mmaptwo.hpp"
#include <cstdlib>
#include <iostream>
#include <limits>
#include <cctype>
#include <iomanip>
#include <system_error>

int main(int argc, char **argv) {
  mmaptwo::mmaptwo_i* mi;
  mmaptwo::page_i* pager;
  char const* fname;
  if (argc < 5) {
    std::cerr <<
        "usage: dump (file) (mode) (length) (offset) [...]\n"
        "optional arguments [...]:\n"
        "  [sublen] [suboff]\n"
        "        Length and offset for page. Defaults\n"
        "        to full extent of mappable."
        << std::endl;
    return EXIT_FAILURE;
  }
  fname = argv[1];
  try {
    mi = mmaptwo::open(fname, argv[2],
      (size_t)std::strtoul(argv[3],nullptr,0),
      (size_t)std::strtoul(argv[4],nullptr,0));
  } catch (std::exception const& e) {
    std::cerr << "failed to open file '" << fname << "':" << std::endl;
    std::cerr << "\t" << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  try {
    size_t sub_len = (argc>5)
      ? (size_t)std::strtoul(argv[5],nullptr,0)
      : mi->length();
    size_t sub_off = (argc>6)
      ? (size_t)std::strtoul(argv[6],nullptr,0)
      : 0u;
    pager = mi->acquire(sub_len, sub_off);
    if (!pager)
      throw std::system_error(mmaptwo::get_errno(), std::generic_category());
  } catch (std::exception const& e) {
    delete mi;
    std::cerr << "failed to map file '" << fname << "':" << std::endl;
    std::cerr << "\t" << e.what() << std::endl;
    return EXIT_FAILURE;
  }
  /* output the data */{
    size_t len = pager->length();
    size_t const off = pager->offset();
    unsigned char* bytes = (unsigned char*)pager->get();
    if (bytes != NULL) {
      size_t i;
      if (len >= std::numeric_limits<size_t>::max()-32)
        len = std::numeric_limits<size_t>::max()-32;
      for (i = 0; i < len; i+=16) {
        size_t j = 0;
        if (i)
          std::cout << std::endl;
        std::cout << std::setw(4) << std::setbase(16) << std::setfill('0')
          << static_cast<long unsigned int>(i + off) << ':';
        for (j = 0; j < 16; ++j) {
          if (j%4 == 0) {
            std::cout << " ";
          }
          if (j < len-i)
            std::cout << std::setw(2) << std::setbase(16) << std::setfill('0')
              << (unsigned int)(bytes[i+j]);
          else std::cout << "  ";
        }
        std::cout << " | ";
        for (j = 0; j < 16; ++j) {
          if (j < len-i) {
            char ch = static_cast<char>(bytes[i+j]);
            std::cout << (isprint(ch) ? ch : '.');
          } else std::cout << ' ';
        }
      }
      std::cout << std::endl;
    } else {
      std::cerr << "mapped file '" << fname <<
        "' gives no bytes?" << std::endl;
    }
  }
  delete pager;
  delete mi;
  return EXIT_SUCCESS;
}

