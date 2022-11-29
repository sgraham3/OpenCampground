rem
rem this script starts mongrel serving
rem the system in production mode
rem it is intended to be used at system boot
rem in conjunction with start_mysql.bat
rem
rem if the system is installed at other than
rem the default location any directory paths
rem referenced in this script must be updated
rem
CD C:\InstantRails2\rails_apps\OpenCampground_1.11
PATH C:\InstantRails2\ruby\bin;C:\InstantRails2\mysql\bin;%PATH%
ruby script\server -e production
