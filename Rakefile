require 'rake'
require 'yaml'
require 'date'
require 'pathname'

SOURCE = Pathname.getwd()
CONFIG = {
  'posts' => File.join(SOURCE, "content", "posts"),
  'post_ext' => "md",
  'static' => "static",
  'static_image' => File.join("static", "img"),
}

def ask(message, valid_options)
  if valid_options
    answer = get_stdin("#{message} #{valid_options.to_s.gsub(/"/, '').gsub(/, /,'/')} ") while !valid_options.include?(answer)
  else
    answer = get_stdin(message)
  end
  answer
end

def get_stdin(message)
  print message
  STDIN.gets.chomp
end

desc "Begin a new posts as: rake posts title='A Title' cg='categories' t='2021-01-01 12:34:59'"
task :posts do
  if not Dir.exists?(CONFIG['posts'])
    abort("can not make #{CONFIG['posts']}, just make it") unless FileUtils.mkdir_p(CONFIG['posts'])
  end
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])

  title = ENV["title"] || "new-post"
  categories = ENV["cg"] || ""
  begin
    time_parse = DateTime.parse(ENV['t']) || DateTime.now
  rescue => err
    puts "error: by t=#{ENV['t']}"
    time_parse = DateTime.now
  # ensure
  #   puts "mark time: #{time_parse.to_s}"
  end
  if time_parse.hour.to_s == '0'
    time_parse = DateTime.parse("#{time_parse.strftime("%Y-%m-%d")} #{DateTime.now.strftime("%H:%M:%S")} +8")
  end
  puts "new time: #{time_parse.to_s}"

  # slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  slug = title.downcase.strip.gsub(' ', '-')
  foldername = File.join(CONFIG['posts'], "#{time_parse.strftime('%Y')}", "#{time_parse.strftime('%m')}", "#{time_parse.strftime('%d')}")
  # foldername = File.join(CONFIG['posts'])
  if not Dir.exists?(foldername)
    abort("can not found #{foldername}, just make it") unless FileUtils.mkdir_p(foldername)
  end
  filename = File.join(foldername, "#{slug}.#{CONFIG['post_ext']}")
  if File.exist?(filename)
    abort("rake aborted! #{filename} not overwrite") if ask("path: #{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end

  puts "Creating new post: #{filename}"
  # system "hugo new #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: \"#{title.gsub(/-/,' ')}\""
    post.puts "date: #{time_parse.to_s}"
    post.puts "description: \"desc #{title.gsub(/-/,' ')}\""
    post.puts "draft: false"
    post.puts "categories: ['#{categories}']"
    post.puts "tags: []"
    post.puts "toc:"
    post.puts "  enable: true"
    post.puts "  auto: true"
    post.puts "code:"
    post.puts "  copy: true"
    post.puts "math:"
    post.puts "  enable: true"
    post.puts "mapbox:"
    post.puts '  accessToken: ""'
    post.puts "share:"
    post.puts "  enable: true"
    post.puts "comment:"
    post.puts "  enable: true"
    post.puts "---"
    post.puts ''
    post.puts 'TODO'
  end
end # task :post

desc "check or init static image path below #{CONFIG['static_image']}"
task :imgNewStatic do
  foldername = File.join(CONFIG['static_image'], "#{time_parse.strftime('%Y')}", "#{time_parse.strftime('%m')}", "#{time_parse.strftime('%d')}")
  if not Dir.exists?(foldername)
    abort("can not found #{foldername}, just make it") unless FileUtils.mkdir_p(foldername)
  end
  puts "now assets image at: {{baseurl}}/#{foldername}/"
end