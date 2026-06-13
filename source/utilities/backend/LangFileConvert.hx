package utilities.backend;

class LangFileConvert {
    public static function langToJson(rawLang:String, path:String = '') {
        var rawJson = '{';
        var rawLangLines = rawLang.split('\n');
        for (i in 0...rawLangLines.length) {
            rawLangLines[i] = rawLangLines[i].trim();
            if (!rawLangLines[i].contains(' = '))
                continue;
            var keyValuePair:Array<String> = rawLangLines[i].split(' = ');
            rawJson += '\n\t"' + keyValuePair[0] + '": ' + '"' + keyValuePair[1] + '",';
        }
        rawJson = rawJson.substr(0, rawJson.length - 1);
        rawJson += '\n}';
        if (FileSystem.exists('./exports/lang/'))
            FileSystem.createDirectory('./exports/lang/');
        File.saveContent('./exports/lang/$path.json', rawJson);
    }
}
