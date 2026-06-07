package utilities.typedefs;
import haxe.DynamicAccess;

typedef SpriteProjectSpriteJSON = {
    defaultFramerate:Int,
    defaultDimensions:Array<Int>,
    maxPressure:Int,
    maxConfidence:Int,
    skills:Array<String>,
    originPosition:Array<Float>,
    particleOffsets:DynamicAccess<Array<Array<Float>>>
}
