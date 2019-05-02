#!/usr/bin/perl
#
# List all members of one or more unix groups, all groups or optionally just
# the group specified on the command line
#
# Date:         12/30/2013
# Author:       William H. McCloskey, Jr.
# Changes:      Added logic to detect host type & tailor subset of getent (OSX)
# Attribution:
#   The logic for this script was directly lifted from Zed Pobre's work.
#     See below for Copyright notice.
#   The idea to use dscl to emulate a subset of the now defunct getent on OSX
#     came from
#       http://zzamboni.org/\
#         brt/2008/01/21/how-to-emulate-unix-getent-with-macosxs-dscl/
#     with an example implementation lifted from
#       https://github.com/petere/getent-osx/blob/master/getent
#
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
unless ($os =~ /(HU-UX|SunOS|Linux|Darwin)/)
    {die "\$getent or equiv. does not exist:  Cannot run on $os\n";}

my $wantedgroup = shift;

my %groupmembers;

my @users;

# Acquire the list of @users based on what is available on this OS:
if ($os =~ /(SunOS|Linux|HP-UX)/) {
    #HP-UX & Solaris assumed to be like Linux; they have not been tested.
    my $usertext = `getent passwd`;
    @users = $usertext =~ /^([a-zA-Z0-9_-]+):/gm;
};
if ($os =~ /Darwin/) {
    @users = `dscl . -ls /Users`;
    chop @users;
}

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
    {
        print $member,"\n";
    }
}