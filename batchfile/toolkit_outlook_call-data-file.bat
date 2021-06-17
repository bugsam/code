::Author: @bugsam
::Action: List data files from outlook
::Version: 1.0
::Date: 14 May, 2013
net use s: \\servername\SharedFolder
mkdir %appdata%\OFDList
S:
copy *.* "%appdata%\OFDList\" /y
cd "%appdata%\OFDList\"
call "%appdata%\OFDList\OFDList.bat"
net use s: /delete
