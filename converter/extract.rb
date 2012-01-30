#! /usr/bin/ruby

require 'rubygems'
require 'pdf-reader'
require 'zlib'
require 'plist'

receiver = PDF::Reader::RegisterReceiver.new
filename = ARGV[0]

reader = PDF::Reader.new(filename)
for object in reader.objects.values
  next unless object.class == Hash
  if object[:Type] == :Filespec
    data = reader.objects[object[:EF][:F]].data
    data = Zlib::Inflate.new.inflate(data)
    puts data
  end
end

interactives = Array.new

PDF::Reader.open(filename) do |reader|
  reader.pages.each do |page|
    puts page.number
    next if  page.attributes[:Annots].nil?
    for annotation in page.attributes[:Annots]
      puts annotation
      annotation = page.objects[annotation]
      interactive = Hash.new
      interactive[:rectangle] = annotation[:Rect]
      interactive[:file] = annotation[:Contents]
      interactive[:page] = page.number
      interactives << interactive
    end
  end
end

output_filename = ARGV[0].gsub( /\.pdf$/, '.plist' )
output_file = File.open( output_filename, 'w' )

output_file.puts interactives.to_plist

output_file.close
