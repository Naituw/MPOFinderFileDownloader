
Pod::Spec.new do |s|

	s.name 			= "MPOFinderFileDownloader"
	s.version		= "0.0.1"
	s.authors		= ["Naituw"]
	s.summary		= "A simple file downloader adds progress indicator to finder when downloading"
	s.homepage		= "https://github.com/Naituw/MPOFinderFileDownloader"
	s.license		= "Apache 2.0"
	s.source		= { :git => "https://github.com/Naituw/MPOFinderFileDownloader.git", :tag => "v0.0.1" }
	s.requires_arc  = true
	s.frameworks 	= 'Foundation'
	s.platforms		= { :osx => "10.9" }
	s.source_files  = 'MPOFinderFileDownloader/*.{h,m}'

end