rem
rem this script starts mysql.  It is intended
rem to be used at system boot in conjunction
rem with start_server.bat
rem
rem if the system is installed at other than
rem the default location any directory paths
rem referenced in this script must be updated
rem
PATH C:\InstantRails2\mysql\bin;%PATH%
mysqld
