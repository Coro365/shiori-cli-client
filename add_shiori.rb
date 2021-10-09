require 'net/http'
require 'json'
require File.join(__dir__, 'config')

# https://github.com/go-shiori/shiori/wiki/API

def shiori_new(uri)
  @shiori = Net::HTTP.new(uri.host, uri.port)
  @shiori.use_ssl = uri.scheme == 'https'
end

def shiori_post(endpoint, paylod)
  uri = URI.parse(File.join(@url, endpoint))
  shiori_new(uri)
  @shiori.post(uri.path, paylod.to_json, { 'X-Session-Id': @session_id })
end

def shiori_get(endpoint)
  uri = URI.parse(File.join(@url, endpoint))
  shiori_new(uri)
  @shiori.get(uri.path, { 'X-Session-Id': @session_id })
end

def init
  @url = SERVER_URL
  @session_id = read_cache_session_id

  if session_active?
    puts("Active session: #{@session_id}")
  else
    reload_session
    write_cache_session_id(@session_id)
    puts("Created new session: #{@session_id}")
  end
end

def reload_session
  paylod = {
    'username': USER_NAME,
    'password': PASSWORD,
    'remember': 1,
    'owner': true
  }

  response = shiori_post('/api/login', paylod)
  @session_id = JSON.parse(response.body)['session']
end

def url?(url)
  url.match(URI::DEFAULT_PARSER.make_regexp)
end

def add_bookmark(url:, tags: nil, title: nil, excerpt: nil)
  puts(url)
  unless url?(url)
    puts('ERROR: not url')
    return false
  end

  paylod = {
    'url': url,
    'createArchive': true,
    'public': 0,
    'tags': tags,
    'title': title,
    'excerpt': excerpt
  }
  response = shiori_post('/api/bookmarks', paylod.compact)
  puts(response.code)
end

def add_bookmarks(urls)
  urls.each do |url|
    add_bookmark(url: url)
  end
end

def fetch_bookmarks
  shiori_get('/api/bookmarks')
end

def session_active?
  if @session_id.nil?
    false
  else
    response = fetch_bookmarks
    response.code == '200'
  end
end

def write_cache_session_id(session_id)
  File.write(File.join(__dir__, 'session_id'), session_id)
end

def read_cache_session_id
  File.read(File.join(__dir__, 'session_id')) rescue nil
end

def markdown_urls_from_clipboard
  clip = `pbpaste`
  puts(clip)

  regexp = URI::DEFAULT_PARSER.make_regexp(['http', 'https'])
  urls = clip.to_enum(:scan, regexp).map { Regexp.last_match }.map do |url|
    # Delete markdown link end string and url anchor
    url[0].gsub(/\)$/, '').gsub(/#.*$/, '')
  end
  urls.empty? ? raise('ERROR not md urls') : urls
end

init

if ARGV.empty?
  add_bookmarks(markdown_urls_from_clipboard)
else
  add_bookmarks(ARGV)
end
