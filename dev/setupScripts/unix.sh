cd ..
echo Makking the main haxelib and setuping folder in same time..
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed.
haxelib install lime 8.3.1
haxelib install openfl 9.5.0
haxelib install flixel 6.1.2
haxelib install flixel-addons 4.0.1
haxelib install flixel-tools 1.5.1
haxelib install flixel-ui 2.6.4
haxelib install tjson 1.4.0
haxelib install hxcpp 4.3.2
haxelib install hxcpp-debug-server 1.2.4
haxelib install hre 0.2.1
haxelib install hxjson5 1.1.0
haxelib install extension-androidtools 2.1.1
haxelib set lime 8.3.1
haxelib set openfl 9.5.0
echo Finished!