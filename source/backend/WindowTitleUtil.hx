package backend;

class WindowTitleUtil {
	inline public static function setTitle(...params:String) {
		#if !html
		var text:Array<String> = [Language.getPhrase('metadata.title')];
		for (i in params) {
			text.push(i);
		}
		lime.app.Application.current.window.title = text.join(' · ');
		#end
	}
}
