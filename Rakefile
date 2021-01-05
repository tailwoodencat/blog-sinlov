require 'rake'
require 'yaml'
require 'date'

SOURCE = "."
CONFIG = {
  'posts' => File.join(SOURCE, "content", "posts"),
  'post_ext' => "md",
  'assets' => "assets/data/cdn/",
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

# Usage: rake post title="A Title"
desc "Begin a new post in #{CONFIG['posts']}"
task :post do
  if not Dir.exists?(CONFIG['posts'])
    abort("can not make #{CONFIG['posts']}, just make it") unless FileUtils.mkdir_p(CONFIG['posts'])
  end
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])
  title = ENV["title"] || "new-post"
  # slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  slug = title.downcase.strip.gsub(' ', '-')
  foldername = File.join(CONFIG['posts'], "#{Time.now.strftime('%Y')}", "#{Time.now.strftime('%m')}", "#{Time.now.strftime('%d')}")
  # foldername = File.join(CONFIG['posts'])
  if not Dir.exists?(foldername)
    abort("can not found #{foldername}, just make it") unless FileUtils.mkdir_p(foldername)
  end
  filename = File.join(foldername, "#{slug}.#{CONFIG['post_ext']}")
  if File.exist?(filename)
    abort("rake aborted! #{filename} not overwrite") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end

  puts "Creating new post: #{filename}"
  # system "hugo new #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: \"#{title.gsub(/-/,' ')}\""
    # post.puts "date: #{Time.now.strftime('%Y-%m-%dT%H:%m:%S')}"
    post.puts "date: #{DateTime.now.to_s}"
    post.puts "description: \"desc #{title.gsub(/-/,' ')}\""
    post.puts "draft: false"
    post.puts 'categories: []'
    post.puts "tags: []"
    post.puts "toc:"
    post.puts "  enable: true"
    post.puts "  auto: false"
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

task :imgNewAssets do
  foldername = File.join(CONFIG['assets'], 'img', "#{Time.now.strftime('%Y')}", "#{Time.now.strftime('%m')}", "#{Time.now.strftime('%d')}")
  if not Dir.exists?(foldername)
    abort("can not found #{foldername}, just make it") unless FileUtils.mkdir_p(foldername)
  end
  puts "now assets image at: {{site.baseurl}}/#{foldername}/"
end