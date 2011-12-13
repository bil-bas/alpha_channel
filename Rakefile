Config = RbConfig if defined? RbConfig # 1.9.3 hack

require 'rake/clean'
require 'redcloth'

APP = "alpha_channel"
APP_READABLE = "Alpha Channel"
require_relative "lib/#{APP}/version"

RELEASE_VERSION = AlphaChannel::VERSION
SOURCE_FOLDERS = %w[bin lib media build]

EXECUTABLE = "#{APP}.exe"
INSTALLER_NAME = "#{APP}_v#{AlphaChannel::VERSION.tr(".", "-")}_setup"
INSTALLER = "#{INSTALLER_NAME}.exe"

SOURCE_FOLDER_FILES = FileList[SOURCE_FOLDERS.map {|f| "#{f}/**/*"}]
EXTRA_SOURCE_FILES = %w[.gitignore Rakefile README.textile Gemfile Gemfile.lock]

RELEASE_FOLDER = 'pkg'
RELEASE_FOLDER_BASE = File.join(RELEASE_FOLDER, "#{APP}_v#{RELEASE_VERSION.gsub(/\./, '_')}")
RELEASE_FOLDER_WIN32_EXE = "#{RELEASE_FOLDER_BASE}_WIN32_EXE"
RELEASE_FOLDER_WIN32_INSTALLER = "#{RELEASE_FOLDER_BASE}_WIN32_INSTALLER"
RELEASE_FOLDER_SOURCE = "#{RELEASE_FOLDER_BASE}_SOURCE"

OCRA_COMMAND = "ocra bin/#{APP}.rbw --windows --icon media/icon.ico --no-enc lib/**/*.* media/**/*.* bin/**/*.*"

README_TEXTILE = "README.textile"
README_HTML = "README.html"

CHANGELOG = "CHANGELOG.txt"

CLEAN.include("*.log")
CLOBBER.include("doc/**/*", EXECUTABLE, RELEASE_FOLDER, README_HTML)

require_relative 'build/rake_osx_package'

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

# Making a release.
file EXECUTABLE => :ocra
desc "Ocra => #{EXECUTABLE} v#{RELEASE_VERSION}"
task ocra: SOURCE_FOLDER_FILES do
  system OCRA_COMMAND
end

file INSTALLER => :installer
desc "Ocra/Innosetup => #{INSTALLER}"
task installer: SOURCE_FOLDER_FILES do
  File.open(File.expand_path("../#{APP}.iss", __FILE__), "w") do |file|
    file.write <<END
[Setup]
AppName=#{APP_READABLE}
AppVersion=#{AlphaChannel::VERSION}
DefaultDirName={pf}#{APP_READABLE}
DefaultGroupName=Spooner Games\\#{APP_READABLE}
OutputDir=.
OutputBaseFilename=#{INSTALLER_NAME}

[Files]
Source: "CHANGELOG.txt"; DestDir: "{app}"
Source: "COPYING.txt"; DestDir: "{app}"
Source: "README.html"; DestDir: "{app}"; Flags: isreadme

[Run]
Filename: "{app}\\#{APP}.exe"; Description: "Launch game"; Flags: postinstall nowait skipifsilent unchecked

[Icons]
Name: "{group}\\#{APP_READABLE}"; Filename: "{app}\\#{APP}.exe"
Name: "{group}\\Uninstall #{APP_READABLE}"; Filename: "{uninstallexe}"
END

#LicenseFile=COPYING.txt
  end

  system OCRA_COMMAND + " --chdir-first --no-lzma --innosetup alpha_channel.iss"
end

# Making a release.

def compress(package, folder, option = '')
  puts "Compressing #{package}"
  rm package if File.exist? package
  cd 'pkg'
  puts File.basename(package)
  puts %x[7z a #{option} "#{File.basename(package)}" "#{File.basename(folder)}"]
  cd '..'
end

desc "Create release packages v#{RELEASE_VERSION} (Not OSX)"
task release: [:release_source, :release_win32_exe, :release_win32_installer]

desc "Create source releases v#{RELEASE_VERSION}"
task release_source: [:source_zip]

desc "Create win32 exe releases v#{RELEASE_VERSION}"
task release_win32_exe: [:win32_exe_zip] # No point making a 7z, since it is same size.

desc "Create win32 installer releases v#{RELEASE_VERSION}"
task release_win32_installer: [:win32_installer_zip] # No point making a 7z, since it is same size.


# Create folders for release.
file RELEASE_FOLDER_WIN32_EXE => [EXECUTABLE, README_HTML] do
  mkdir_p RELEASE_FOLDER_WIN32_EXE
  cp EXECUTABLE, RELEASE_FOLDER_WIN32_EXE
  cp CHANGELOG, RELEASE_FOLDER_WIN32_EXE
  cp README_HTML, RELEASE_FOLDER_WIN32_EXE
end

file RELEASE_FOLDER_WIN32_INSTALLER => [INSTALLER, README_HTML] do
  mkdir_p RELEASE_FOLDER_WIN32_INSTALLER
  cp INSTALLER, RELEASE_FOLDER_WIN32_INSTALLER
  cp CHANGELOG, RELEASE_FOLDER_WIN32_INSTALLER
  cp README_HTML, RELEASE_FOLDER_WIN32_INSTALLER
end

file RELEASE_FOLDER_SOURCE => README_HTML do
  mkdir_p RELEASE_FOLDER_SOURCE
  SOURCE_FOLDERS.each {|f| cp_r f, RELEASE_FOLDER_SOURCE }
  cp EXTRA_SOURCE_FILES, RELEASE_FOLDER_SOURCE
  cp CHANGELOG, RELEASE_FOLDER_SOURCE
  cp README_HTML, RELEASE_FOLDER_SOURCE
end

{ "7z" => '', :zip => '-tzip' }.each_pair do |compression, option|
  { source: RELEASE_FOLDER_SOURCE,
    win32_exe: RELEASE_FOLDER_WIN32_EXE,
    win32_installer: RELEASE_FOLDER_WIN32_INSTALLER,
  }.each_pair do |name, folder|
    package = "#{folder}.#{compression}"
    desc "Create #{package}"
    task :"#{name}_#{compression}" => package
    file package => folder do
      compress(package, folder, option)
    end
  end
end

# Generate a friendly readme
file README_HTML => :readme
desc "Convert readme to HTML"
task :readme => README_TEXTILE do
  puts "Converting readme to HTML"
  File.open(README_HTML, "w") do |file|
    file.write RedCloth.new(File.read(README_TEXTILE)).to_html
  end
end


