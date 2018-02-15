# Rakefile for that stuff

task :dev do
	# TODO Use proper bonsai from ruby
	%x[bonsai --cultivate]
end

task :export do
	# Hack: protect submodule from oblivion
	%x[mv output/.git tmp_git_submodule]
	# TODO Use proper bonsai from ruby
	%x[bonsai --repot]
	# Hack, part II: bring back submodule
	%x[mv tmp_git_submodule output/.git]
end

task :push do
	# Welcome to some awkward git helper
	# Do not try this at home

	# Get last log message
	message = %x[git log -1 --pretty=%B]

	# Also some vars
	output='output'
	remote='origin'
	branch='master'

	# Push submodules
	%x[git submodule update]
	%x[git submodule foreach "git checkout master && git add -A && git commit -m '#{message}' && git push #{remote} #{branch}"]

	# Push root
	%x[git push #{remote} #{branch}]
end

task :devprint do
  require 'watch'
	Watch.new("{content,templates,public}/**/*") {
		Rake::Task["cvpdf"].invoke
		Rake::Task["cvpdf"].reenable
	}
end

task :cvpdf => [:export] do
	require 'pdfkit'
	require 'bonsai'
	require 'rack'
	require 'sinatra'

	Bonsai.root_dir = Dir.pwd

	puts 'Start server'
	server = fork {
		app = Rack::Builder.app {
			use Bonsai::StaticPassThrough, :root => Bonsai.root_dir + "/output", :urls => ["/"]
			run Bonsai::DevelopmentServer
		}
		Rack::Handler.default.run(app, :Port => 5000, Logger: WEBrick::Log.new(File.open(File::NULL, 'w')), AccessLog: []) do
			inner_server = Process.pid
			fork {
				PDFKit.configure do |config|
				  config.default_options = {
				    :page_size => 'A4',
				    :print_media_type => true
				  }
				end
				puts 'Print CV (English)'
				PDFKit.new('http://localhost:5000/cv').to_file('public/pdf/cv.pdf')
				puts 'Print CV (French)'
				PDFKit.new('http://localhost:5000/cv-fr').to_file('public/pdf/cv-fr.pdf')
				puts 'Stop server'
	      Process.kill("QUIT", inner_server)
				puts 'Done!'
			}
		end
	}
	Process.wait(server)
end

task default: :dev
