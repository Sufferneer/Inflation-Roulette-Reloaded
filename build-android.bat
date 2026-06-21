rmdir /S /Q "%~dp0export\release\android\bin\app\src\main\assets\"
rmdir /S /Q "%~dp0export\release\android\bin\app\src\main\res\"
robocopy "%~dp0templates\android\template\app\src\main" "%~dp0export\release\android\bin\app\src\main" /E /Z /R:3 /W:5
lime update android
lime test android -D_OFFICIAL_BUILD -64