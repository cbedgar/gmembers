#!/usr/bin/perl
#
# List all members of one or more unix groups, all groups or optionally just
# the group specified on the command line
#
#   MIT License, see LICENSE file included with project
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
(my $os) = (`uname -a` =~ /^([\w-]+)/);
$os =~ /Darwin/ or die "You need a mac!  Cannot run on $os\n";

my %groupmembers = ();
my $group_field_size = 0;

# Acquire the list of @users
my @users = `dscl . -ls /Users`;
chop @users;

# Now just do what Zed did - thanks Zed.
foreach my $userid (@users)
{
    my $usergrouptext = `id -Gn $userid`;
    my @grouplist = split(' ',$usergrouptext);

    foreach my $group (@grouplist)
    {
        $groupmembers{$group}->{$userid} = 1;
        $group_field_size < length $group
            and $group_field_size = length $group;
    }
}

my @wantedgroups = @ARGV ? @ARGV : sort keys %groupmembers;
    # look at specified groups if they exist, else look at all groups

my @groups_with_one;    # place groups with only a single user in them at the end
my @groups_with_many;   # put the groups with multiple users at the front
foreach my $group (@wantedgroups) {
    if ( keys %{$groupmembers{$group}} == 1) {
        push @groups_with_one, $group;
    }
    else {
        push @groups_with_many, $group;
    }
}

foreach my $group ( @groups_with_many, @groups_with_one ) {
#       print "DEBUG: \$group_field_size = $group_field_size\n";
    printf( '%*s  :  ', -$group_field_size, $group );
    print( join( ' ', sort keys %{$groupmembers{$group}}), "\n");
}
