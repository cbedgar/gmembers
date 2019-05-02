#!/usr/bin/perl
#
# List all members of one or more unix groups, all groups or optionally just
# the group specified on the command line
#
#	MIT License, see LICENSE file included with project
#
# Copyright © 2013 William H. McCloskey, Jr., © 2019 Clement B. Edgar III
# Copyright © 2010-2013 by Zed Pobre (zed@debian.org or zed@resonant.org)
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#

use strict; use warnings;

$ENV{"PATH"} = "/usr/bin:/bin";

# Only run on supported $os:
my $os;
($os)=(`uname -a` =~ /^([\w-]+)/);
$os =~ /Darwin/ or die "You need a mac!  Cannot run on $os\n";

my $wantedgroup = shift;

my %groupmembers;

# Acquire the list of @users
my @users = `dscl . -ls /Users`;
chop @users;
;

# Now just do what Zed did - thanks Zed.
foreach my $userid (@users)
{
    my $usergrouptext = `id -Gn $userid`;
    my @grouplist = split(' ',$usergrouptext);

    foreach my $group (@grouplist)
    {
        $groupmembers{$group}->{$userid} = 1;
    }
}

if($wantedgroup)
{
    print_group_members($wantedgroup);
}
else
{
    foreach my $group (sort keys %groupmembers)
    {
        print "Group ",$group," has the following members:\n";
        print_group_members($group);
        print "\n";
    }
}

sub print_group_members
{
    my ($group) = @_;
    return unless $group;

    foreach my $member (sort keys %{$groupmembers{$group}})
    	{	print $member, " " }
    print "\n";
}
