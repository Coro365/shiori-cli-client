# Shiori-CLI-Client
Send urls from CLI to shiori via API

## Support OS
* Linux
* macOS

## Instllation
1. Clone
	* `git clone https://github.com/Coro365/add-shiori.git`
1. Rename config file
	* `mv config_sample.rb config.rb`
1. Edit config
	* `vi config.rb`
1. Install Xclip and Xsel (if use linux)
	* `apt install xclip xsel`
	* Add these lines inside your .bashrc file and start a new terminal.
		```
		# Linux version of macOS pbcopy and pbpaste.
		alias pbcopy=’xsel — clipboard — input’
		alias pbpaste=’xsel — clipboard — output’
		```
	* [How to use pbcopy and pbpaste. If you’re here reading this, then… | by Jorge Yau | Medium](https://medium.com/@codenameyau/how-to-copy-and-paste-in-terminal-c88098b5840d)	

## Usage
1. Send URLs in ARGV
	* `ruby add_shiori.rb [URL] [URL]...`
1. Send URLs in clipboard
	* `ruby add_shiori.rb`
	
## License
MIT
