#!/usr/bin/perl
use lib $ENV{RLWRAP_FILTERDIR};
use RlwrapFilter;

use Data::Dumper;
use File::Basename;
use FileHandle;
use IPC::Open2;

$compProg = dirname($0) . "/comp.exp";
$pid = open2(*R, *W, $compProg);
#$pid = open2(*R, *W, "cat -nu");

$filter = new RlwrapFilter;
$filter->completion_handler(sub {
#print Dumper @_;
    $line = shift(@_);
    $ltoken = shift(@_);

    # filepath
    if ($ltoken =~ /^[\/\.]/) {
        return @_;
    }

    $subcom = $line . "\n";
    while (1) {
        print W $ARGV[0] . " " . $subcom;
        $got = <R>;
        if ($got !~ /^[^\s]+$/) {last};
        $subcom = $got;
    }
    @cmpl = split(/[\s]+/, $got);

#print Dumper @cmpl;
#print Dumper @_;
    (@cmpl, @_);
});

$filter -> run;
