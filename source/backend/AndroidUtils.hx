package backend;

#if android
import android.Permissions;
import android.os.Environment;
import lime.system.System;
#if android
import lime.system.JNI;
import android.Tools;
import android.Settings;
#end
#end

class AndroidUtils {
	public static var androidDirectory:String = '';

	public static function getPath():String {
		#if android
		if (androidDirectory != null && androidDirectory.length > 0)
			return androidDirectory + '/';
		else {
			androidDirectory = Environment.getExternalStorageDirectory() + '/.' + FlxG.stage.application.meta.get('file');
			trace('Android directory: $androidDirectory');
			return androidDirectory + '/';
		}
		#else
		return '';
		#end
	}

	inline public static function checkAllFilesPermission():Bool {
		return Environment.isExternalStorageManager();
	}

	inline public static function requestAllFilesPermission() {
		Settings.requestSetting('android.settings.MANAGE_APP_ALL_FILES_ACCESS_PERMISSION');
	}
}
