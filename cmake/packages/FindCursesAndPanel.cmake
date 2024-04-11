find_package(Curses)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CursesAndPanel
                                  FOUND_VAR
                                    CURSESANDPANEL_FOUND
                                  REQUIRED_VARS
                                    CURSES_FOUND
                                    CURSES_INCLUDE_DIRS
                                    CURSES_LIBRARIES
                                    PANEL_LIBRARIES)
mark_as_advanced(CURSES_INCLUDE_DIRS CURSES_LIBRARIES PANEL_LIBRARIES)
