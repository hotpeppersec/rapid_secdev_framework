=begin
  normalizer application
=end

 encoding_options = {
  :invalid           => :replace,  # Replace invalid byte sequences
  :undef             => :replace,  # Replace anything not defined in ASCII
  :replace           => '',        # Use a blank for those replacements
  :universal_newline => false       # Always break lines with \n
}

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

File.open(ARGV[0], "r") do |f|
  f.each_line do |line|
    puts line.encode(Encoding.find('UTF-8'), encoding_options)
  end
end

#puts "File equals: " + my_filename

