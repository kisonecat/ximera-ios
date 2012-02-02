#! /usr/bin/ruby

require 'rubygems'
require 'pdf-reader'
require 'zlib'
require 'plist'

receiver = PDF::Reader::RegisterReceiver.new
filename = ARGV[0]

width_in_points = 417.6
width_in_inches = width_in_points / 72.0
width_in_pixels = 768
resolution_in_points_per_inch = width_in_pixels / width_in_inches

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
    media_box = page.page_object[:MediaBox]
    next if page.attributes[:Annots].nil?
    for annotation in page.attributes[:Annots]
      puts annotation
      annotation = page.objects[annotation]
      interactive = Hash.new
      interactive[:rectangle] = annotation[:Rect]

      # change the origin to the upper-left
      interactive[:rectangle][1] = media_box[3] - interactive[:rectangle][1]
      interactive[:rectangle][3] = media_box[3] - interactive[:rectangle][3]

      # change the units from points to pixels
      interactive[:rectangle].collect!{ |x| (x * width_in_pixels / width_in_points).to_i }

      interactive[:filename] = annotation[:Contents]
      interactive[:page] = page.number
      interactives << interactive
    end
  end
end

output_filename = ARGV[0].gsub( /\.pdf$/, '.plist' )
output_file = File.open( output_filename, 'w' )

output_file.puts interactives.to_plist

output_file.close
