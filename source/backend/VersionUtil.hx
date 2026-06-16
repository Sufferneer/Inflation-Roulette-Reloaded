package backend;

class VersionUtil {
	public static final platformFormattedNames:Map<String, String> = [
		'windows' => 'Windows',
		'linux' => 'Linux',
		'macos' => 'macOS',
		'android' => 'Android',
		'ios' => 'iOS',
		'html5' => 'HTML5',
		'unknown' => 'UNKNOWN'
	];

	public static function getBuildID() {
		#if windows
		return 'WINDOWS';
		#elseif linux
		return 'LINUX';
		#elseif mac
		return 'MACOS';
		#elseif android
		return 'ANDROID';
		#elseif ios
		return 'IOS';
		#elseif html5
		return 'HTML5';
		#else
		return 'UNKNOWN';
		#end
	}

	public static function getBuildName() {
		return platformFormattedNames.get(getBuildID().toLowerCase());
	}
	public static function getVersionName(curVersion:String) {
		var arr = curVersion.split('.');
		var state:Array<String> = haxe.macro.Compiler.getDefine('versionState').split('.');
		var text = Language.getPhrase('metadata.version.name.major.' + arr[0]);
		appendices = [];
		if (arr[1] != null && Std.parseInt(arr[1]) > 0) {
			addAppendix(Language.getPhrase('metadata.version.name.minor.format', [arr[1]]));
		}
		if (arr[2] != null) {
			if (Std.parseInt(arr[2]) > 0) {
				addAppendix(Language.getPhrase('metadata.version.name.hotfix.format', [arr[2]]));
			}
		}
		if (state != null && state[0] != '') {
			addAppendix(Language.getPhrase('metadata.version.name.state.' + state[0], [state[1]]));
		}
		if (appendices.length > 0) {
			appendices.push(')');
			appendices.unshift(' (');
		}
		return text + appendices.join('');
	}

	static var appendices:Array<String> = [];

	static function addAppendix(str:String) {
		if (appendices.length > 0)
			appendices.push(' ');
		appendices.push(str);
	}

	public function new() {}
}
