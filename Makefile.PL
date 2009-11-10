use inc::Module::Install;
use strict;

name 'WWW-Wave-Sniff';
all_from 'lib/WWW/Wave/Sniff.pm';

requires Readonly => '1.03';
requires Moose => '0.55';
requires LWP => '5.812';
requires JSON => '2.16';

# ok, do the hard work!
WriteAll;

#fin#

