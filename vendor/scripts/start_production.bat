rem
rem this script is intended to be manually
rem invoked to start the mysql server and
rem then start mongrel serving the system
rem in the production mode
rem
rem if the system is installed at other than
rem the default location any directory paths
rem referenced in this script must be updated
rem
PATH C:\InstantRails2\ruby\bin;C:\InstantRails2\mysql\bin;%PATH%
start mysqld
CD C:\InstantRails2\rails_apps\OpenCampground_1.11
ruby script\server -e production
