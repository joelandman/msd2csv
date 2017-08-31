# msd2csv
MySQL dump to CSV conversion

# Usage:   (z)cat dump.sql(.gz) | msd2csv.pl > dump.csv

First line will be a comment with the header from the
table definition.   Subsequent lines will be the actual entries

This assumes a single table per sql dump. The entire file will be snarfed from STDIN before processing
CREATE TABLE will be a multi-line affair
INSERT INTO table will be on a single (long) line, possibly multiple of these lines per dump file.

Setting it up to work with streaming data would take a little bit of work.  
