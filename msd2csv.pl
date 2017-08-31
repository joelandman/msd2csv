#!/usr/bin/env perl

# convert a mysql dump into real CSV
#
# Usage:   (z)cat dump.sql(.gz) | msd2csv.pl > dump.csv
#
# First line will be a comment with the header from the
# table definition
# Subsequent lines will be the actual entries
#
# this assumes a single table per sql dump.
# the entire file will be snarfed from STDIN before processing
# CREATE TABLE will be a multi-line affair
# the INSERT INTO table will be on a single (long) line.
# perfect for regex

# ############################################################################
# Copyright (c) 2017 Joseph Landman (joe.landman@gmail.com)

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ############################################################################

use strict;

my ($line,@lines,$out,@fields,$what,$table,$out,@header);

# grab all the data into RAM ... this could be a problem
# for very large dumps (comparable to the size of memory)

# note also that this reads 1 line at a time, not normally 
# efficient, though mysqldump appears to write a very long 
# INSERT INTO( ... line, so it isn't as ineffecient as one
# might suppose

chomp(@lines = <>);
$out = "";
foreach $line (@lines) {
  $line =~ s/^\s+//g;

  if ($line =~ /^\`(.*?)\`/) {
      push @header,'"'.$1.'"';
      next;
  }

  if ($line =~ /^INSERT INTO/) {
      $out .= &parse_insert($line) . "\n";
  }
}
printf "%s\n",join(",",@header);
print $out;

sub parse_insert {
  my $l = shift;
  my (@ins,$o);

  # parse out the separators
  $l =~ s/\),\(/\n/g;
  $l =~ s/^INSERT.*?\(//m;

  # now clean up the data 
  $l =~ s/\)$//m;
  $l =~ s/\'\,/\"\,/gm;
  $l =~ s/\,\'/\,\"/gm;
  $l =~ s/\'\n/\"\n/gm;

  # return it
  return $l;
}
