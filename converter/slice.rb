#! /usr/bin/ruby

# slice.rb
# 
# convert PDF into tiles to be fed into one of the content readers
#   
# This file is part of ximera.
# 
# ximera is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# ximera is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with ximera.  If not, see <http://www.gnu.org/licenses/>.


require 'rubygems'
require 'tmpdir'

input_file = ARGV[0]

width_in_points = 417.6
height_in_inches = 225
height_in_points = height_in_inches * 72.0
width_in_inches = width_in_points / 72.0
desired_width_in_pixels = 768
resolution_in_points_per_inch = desired_width_in_pixels / width_in_inches

input_directory = Dir.pwd

Dir.mktmpdir do |dir|
  `pdftk #{input_file} burst output #{dir}/page%03d.pdf`

  pdf_filenames = Dir.new(dir).entries.select{ |x| x.match( /page[0-9]*\.pdf$/ ) }

  for filename in pdf_filenames
    crop_resolution = 10
    `./pdfdraw -r #{crop_resolution} -o #{dir}/#{filename}.png #{dir}/#{filename}`
    verbose = `convert -verbose -trim #{dir}/#{filename}.png /dev/null`
    if verbose.match( /=>([0-9]+)x([0-9]+) ([0-9]+)x([0-9]+)([+-][0-9]+)([+-][0-9]+)/ )
      height = ($2.to_i) * 72 / crop_resolution
      y_offset = ($6.to_i) * 72 / crop_resolution
      next if height < 0
      margin = 72.0 * 0.1
      height = height + 2 * margin
      y_offset = y_offset - margin
      new_crop_box = "0 #{height_in_points - (y_offset + height)} #{width_in_points} #{height_in_points - y_offset}"
      `perl -pe "s/(Crop|Media)Box\\\s*\\\[(.+?)\\\]/\\\$1Box\\\[#{new_crop_box}\\\]/g;" #{dir}/#{filename} | pdftk - output #{dir}/cropped-page.pdf`
      `./pdfdraw -a -r #{resolution_in_points_per_inch} -o #{dir}/#{filename}.png #{dir}/cropped-page.pdf`
      `convert -crop 256x256 +repage #{dir}/#{filename}.png #{filename.gsub(/\.pdf$/,'').gsub(/^page/,'tile')}-%03d.png`
    end
  end
end
