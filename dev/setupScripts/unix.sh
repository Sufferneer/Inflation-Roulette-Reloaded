cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.2.3
haxelib install openfl 9.4.2
haxelib install flixel 6.1.2
haxelib install flixel-addons 4.0.1
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.6.4
haxelib install tjson 1.4.0
haxelib git systools https://github.com/waneck/systools/
haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp/
haxelib set hxcpp-debug-server 1.2.4
echo Finished!