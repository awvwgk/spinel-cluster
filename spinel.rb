#!/bin/ruby
#
# Copyright (C) 2017 awvwgk
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  
#
# If not, see <http://www.gnu.org/licenses/>.
#

require 'optparse'
options = Hash.new
usage   = "Usage: ruby spinel.rb a A B X r x y z\n" +
	" – lattice constant a and cut-off radius r in Å\n" +
    " – position in primitive cell (x y z) in a, range from 1 to 1\n"
OptionParser.new do |option|
	option.banner = usage
	option.on_tail '-h','--help','Display this message' do
		puts option
		exit
	end
end.parse!
unless ARGV[3]
	puts usage+"\n   example: 8.080 Mg Al O 25.0 0.5 0.5 0.5\n\n"
    exit
end

# extend Array somewhat
class Array
	def in_range? r
		r2 = ((self[1]-$x)**2 + (self[2]-$y)**2 + (self[3]-$z)**2)
		r2<= r**2 # returns boolean
	end
	# place on face centered lattice
	def place_ccp atom,x,y,z
		x,y,z = $a*x,$a*y,$a*z
		of,tf,oh = $a/4,3*$a/4,$a/2
		self << [atom,x+of,y,z]
		self << [atom,x,y+of,z]
		self << [atom,x,y,z+of]
		self << [atom,x+tf,y,z]
		self << [atom,x,y+tf,z]
		self << [atom,x,y,z+tf]
		self << [atom,x+oh,y+of,z]
		self << [atom,x+oh,y,z+of]
		self << [atom,x+of,y+oh,z]
		self << [atom,x,y+oh,z+of]
		self << [atom,x+of,y,z+oh]
		self << [atom,x,y+of,z+oh]
		self << [atom,x+oh,y+tf,z]
		self << [atom,x+oh,y,z+tf]
		self << [atom,x+tf,y+oh,z]
		self << [atom,x,y+oh,z+tf]
		self << [atom,x+tf,y,z+oh]
		self << [atom,x,y+tf,z+oh]
		self << [atom,x+of,y+of,z+of]
		self << [atom,x+tf,y+of,z+of]
		self << [atom,x+of,y+tf,z+of]
		self << [atom,x+of,y+of,z+tf]
		self << [atom,x+tf,y+tf,z+of]
		self << [atom,x+tf,y+of,z+tf]
		self << [atom,x+of,y+tf,z+tf]
		self << [atom,x+tf,y+tf,z+tf]
		self << [atom,x+oh,y+oh,z+of]
		self << [atom,x+oh,y+of,z+oh]
		self << [atom,x+of,y+oh,z+oh]
		self << [atom,x+oh,y+oh,z+tf]
		self << [atom,x+oh,y+tf,z+oh]
		self << [atom,x+tf,y+oh,z+oh]
	end
	# place in octaedral holes (½)
	def place_ohh atom, x, y, z
		x,y,z = $a*x,$a*y,$a*z
		of,tf,oh = $a/4,3*$a/4,$a/2
		self << [atom,x,y,z]
		self << [atom,x,y+oh,z+oh]
		self << [atom,x+oh,y,z+oh]
		self << [atom,x+oh,y+oh,z]
		self << [atom,x,y+of,z+of]
		self << [atom,x,y+tf,z+tf]
		self << [atom,x+of,y+tf,z]
		self << [atom,x+of,y,z+tf]
		self << [atom,x+tf,y+of,z]
		self << [atom,x+tf,y,z+of]
		self << [atom,x+of,y+of,z+oh]
		self << [atom,x+of,y+oh,z+of]
		self << [atom,x+tf,y+tf,z+oh]
		self << [atom,x+tf,y+oh,z+tf]
		self << [atom,x+oh,y+tf,z+of]
		self << [atom,x+oh,y+of,z+tf]
	end
	# place in tetraedral holes (⅛)
	def place_tdh atom, x, y, z
		x,y,z = $a*x,$a*y,$a*z
		oe,te,se,fe = $a/8,3*$a/8,5*$a/8,7*$a/8
		self << [atom,x+oe,y+fe,z+se]
		self << [atom,x+oe,y+se,z+fe]
		self << [atom,x+te,y+oe,z+oe]
		self << [atom,x+te,y+fe,z+fe]
		self << [atom,x+fe,y+te,z+te]
		self << [atom,x+fe,y+se,z+se]
		self << [atom,x+se,y+fe,z+oe]
		self << [atom,x+se,y+oe,z+fe]
	end
end

# get commandline argument
argv = ARGV.dup
$a = ARGV.shift.to_f # lattice constant in Å
A,B,X  = ARGV.shift,ARGV.shift,ARGV.shift # atom types 
$r_max = ARGV.shift.to_f # cut-off radius in Å
$x,$y,$z = ARGV.shift.to_f,ARGV.shift.to_f,ARGV.shift.to_f
# note: no sanity check!

ratio = ($r_max/$a).ceil + 1 # ++ to be sure 

spinel = Array.new

((-ratio)..(ratio)).each do |i|
	((-ratio)..(ratio)).each do |j|
		((-ratio)..(ratio)).each do |k|
			spinel.place_ccp X, i, j, k
			spinel.place_ohh B, i, j, k
			spinel.place_tdh A, i, j, k
		end
	end
end

spinel.uniq! # not necessary…

spinel.select! do |atom|
	atom.in_range? $r_max # perform spherical cut-off
end
# print to STDOUT, file may be possible
puts spinel.length
puts "generated with 'ruby spinel.rb %.5f %s %s %s %.5f %.2f %.2f %.2f'" % argv
spinel.each do |atom|
	puts "%2s\t%.10f\t%.10f\t%.10f" % atom
end
