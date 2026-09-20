package utilities.typedefs;

typedef SpriteProjectAnimData = {
    framerate:Int,
    numFrames:Int,
    keyframes:Array<Int>,
	?bouncy:Bool,
	?loop:Bool,
	?autoPitch:Bool,
	?soundPaths:Array<String>
}
