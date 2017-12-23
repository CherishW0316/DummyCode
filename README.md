# DummyCode 垃圾代码生成器

> 本项目综合了github上另外两个垃圾代码生成器代码，感谢[klaus01/KLGenerateSpamCode](https://github.com/klaus01/KLGenerateSpamCode)，[leeeGreat/LWRubbishTool](https://github.com/leeeGreat/LWRubbishTool)。

# 使用步骤

1. 打开项目后，找到 ViewController中`- (IBAction)run:(id)sender` 方法，这里有你需要的全部配置。

2. 
- basePath 项目的根目录
- gSourceCodeDir 同 basePath
- 前5个BOOL型参数，决定是否开启该项功能
- oldProjectName，newProjectName 新旧工程名称
- projectFilePath xcodeproj文件路径
- oldClassNamePrefix，newClassNamePrefix 新旧类名前缀
- outDirString 垃圾代码生成路径（最好提前创建好改路径，建议不要放在自己的项目路径里，可以放在桌面，否则如果重复运行此程序，生成的垃圾代码也会被认为是源码，从而垃圾代码数量成倍增加）
- gOutParameterName 第一次生成垃圾文件，生成的垃圾代码文件名称会加上该后缀（源自[klaus01/KLGenerateSpamCode](https://github.com/klaus01/KLGenerateSpamCode)）
- classSecondNameArray 第二次生成垃圾文件，生成的垃圾代码文件名称会与该数组两两组合，生成新的垃圾文件（源自[leeeGreat/LWRubbishTool](https://github.com/leeeGreat/LWRubbishTool)）
- ignoreDirNames 忽略的文件夹列表

3. 项目中Template文件夹中的几个txt文件是第二次生成垃圾文件的模板，可以按照自己的喜好修改。
