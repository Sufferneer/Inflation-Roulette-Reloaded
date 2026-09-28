echo Compiling for HTML...
rmdir /S /Q "%~dp0export\release\html5\bin\assets\"
lime update html5
lime build html5 -D_OFFICIAL_BUILD