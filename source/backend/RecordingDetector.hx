package backend;

class RecordingDetector {
	public static var isRecording:Bool = false;

	public static function checkIfRecording() {
		#if !_ALLOW_RECORDING
		var process:Process;
		var command:String;
		var args:Array<String>;

		// Detect OS and set the correct command
		var sysName = Sys.systemName();
		if (sysName == "Windows") {
			command = "tasklist";
			args = ["/FI", "IMAGENAME eq obs64.exe"];
		} else if (sysName == "Mac") {
			command = "pgrep";
			args = ["-x", "OBS"];
		} else {
			// Assume Linux
			command = "pgrep";
			args = ["-x", "obs"];
		}

		try {
			process = new Process(command, args);
			var output = process.stdout.readAll().toString();
			var code = process.exitCode();
			process.close();

			// tasklist outputs "No tasks are running" when empty
			if (sysName == "Windows") {
				isRecording = (!output.contains("No tasks are running"));
			} else {
				// pgrep returns exit code 0 if process is found
				isRecording = (code == 0);
			}
		} catch (e:Dynamic) {
			trace("Error checking for OBS Studio: " + e);
			isRecording = false;
		}
		if (isRecording)
			trace('CLIENT IS RECORDING');
		#else
		isRecording = false;
		#end
	}
}
