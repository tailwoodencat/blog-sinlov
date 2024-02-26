require 'rake'
require 'yaml'
require 'date'
require 'pathname'

CATEGORIES_CHECK = [
  'basics',
  'tips',
  'database',
  'AI',
  'container',
  'docker',
  'unity',
  'unreal',
  'python',
  'golang',
  'gradle',
  'Android',
  'rust',
  'c',
  'ruby'
]

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

# ==fetch_env_time_parse
#  env {arg_time} for time mark
#  use as: {cmd} {arg_time}='2021-01-01 12:34:59'
#  code:
#    time_parse = fetch_env_time_parse('t')
def fetch_env_time_parse(arg_time)
  # env t for time mark
  begin
    t_env = ENV[arg_time] || ""
    if t_env == ""
      time_parse = DateTime.now
    else
      time_parse = DateTime.parse(t_env)
    end
  rescue => err
    puts "error: env by #{arg_time}=#{ENV[arg_time]}"
    time_parse = DateTime.now
  # ensure
  #   puts "mark time: #{time_parse.to_s}"
  end
  if time_parse.hour.to_s == '0'
    time_parse = DateTime.parse("#{time_parse.strftime("%Y-%m-%d")} #{DateTime.now.strftime("%H:%M:%S")} +8")
  end
  # puts "new time: #{time_parse.to_s}"
  time_parse
end

desc "Begin a new posts as: rake posts cg='categories' title='A Title' t='2021-01-01 12:34:59'"
task :posts do
  if not Dir.exist?(CONFIG['posts'])
    abort("can not make #{CONFIG['posts']}, just make it") unless FileUtils.mkdir_p(CONFIG['posts'])
  end
  abort("rake aborted: '#{CONFIG['posts']}' directory not found.") unless FileTest.directory?(CONFIG['posts'])

  title = ENV["title"] || "new-post"

  # env t for time mark
  time_parse = fetch_env_time_parse('t')

  # check categories
  categories = ENV["cg"] || ""
  if not CATEGORIES_CHECK.any?(categories)
    abort("error: can not set categories as: #{categories}, please check or add CATEGORIES_CHECK setting")
  end

  # slug = title.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  slug = title.downcase.strip.gsub(' ', '-')
  slug = slug.strip.gsub(':', ' ')
  slug = slug.strip.gsub('*', ' ')
  slug = slug.strip.gsub('?', ' ')
  slug = slug.strip.gsub('"', ' ')
  slug = slug.strip.gsub('<', ' ')
  slug = slug.strip.gsub('>', ' ')
  # fix windows path

  foldername = File.join(CONFIG['posts'], "#{time_parse.strftime('%Y')}", "#{time_parse.strftime('%m')}", "#{time_parse.strftime('%d')}")
  # foldername = File.join(CONFIG['posts'])
  # if not Dir.exists?(foldername) # ruby 2.0
  if not Dir.exist?(foldername) # ruby 3.0
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
    post.puts "draft: true" # 草稿创建属性 true 不会渲染
    post.puts "categories: ['#{categories}']"
    post.puts "tags: ['#{categories}']"
    post.puts "toc:"
    post.puts "  enable: true"
    post.puts "  auto: false"
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

desc "check or init static image path below #{CONFIG['static_image']} as: t='2021-01-01 12:34:59'"
task :imgNewStatic do

  # env t for time mark
  time_parse = fetch_env_time_parse('t')

  foldername = File.join(CONFIG['static_image'], "#{time_parse.strftime('%Y')}", "#{time_parse.strftime('%m')}", "#{time_parse.strftime('%d')}")
  # if not Dir.exists?(foldername) # ruby 2.0
  if not Dir.exist?(foldername) # ruby 3.0
    abort("can not found #{foldername}, just make it") unless FileUtils.mkdir_p(foldername)
  end
  puts "now assets image at: {{baseurl}}/#{foldername}/"
end