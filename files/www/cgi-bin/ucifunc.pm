=for comment

  Part of AREDN -- Used for creating Amateur Radio Emergency Data Networks
  Copyright (c) 2015 Darryl Quinn
  See Contributors file for additional contributors

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation version 3 of the License.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  Additional Terms:

  Additional use restrictions exist on the AREDN(TM) trademark and logo.
    See AREDNLicense.txt for more info.

  Attributions to the AREDN Project must be retained in the source code.
  If importing this code into a new or existing project attribution
  to the AREDN project must be added to the source code.

  You must not misrepresent the origin of the material conained within.

  Modified versions must be modified to attribute to the original source
  and be marked in reasonable ways as differentiate it from the original
  version.

=cut

### UCI Helpers START ###
sub uci_get_sectiontype_count()
{
    my ($config, $stype)=@_;
    my $cmd=sprintf('uci show %s|egrep vtun\.\@%s.*=%s|wc -l',$config,$stype,$stype);
    my $res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc,$res);
}

sub uci_get_indexed_option()
{
    my ($config,$stype,$index,$key)=@_;
    my $cmd=sprintf('uci get %s.@%s[%s].%s',$config,$stype,$index,$key);
    my $res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc,$res);
}

sub uci_get_indexed_sectiontype()
{
    my ($config,$stype,$index)=@_;
    my $cmd=sprintf('uci get %s.@%s[%s]',$config,$stype,$index);
    my @res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc, @res);
}

# RETURNS an array of hashes
sub uci_get_all_by_sectiontype()
{
    my ($config,$stype)=@_;
    my @sections=();

    my $cmd=sprintf('uci show %s|grep %s.@%s',$config,$config,$stype);
    my @lines=`$cmd`;
    
    if (scalar @lines) {
        my $lastindex=0;
        my $sect={};
        my @parts=();
        foreach $l (0..@lines-1) {
            @parts=();
            chomp(@lines[$l]);
            @parts = @lines[$l] =~ /^$config\.\@$stype\[(.*)\]\.(.*)\=(.*)/g;1;
            if (scalar(@parts) eq 3) {
                if (@parts[0] ne $lastindex) {
                    push @sections, $sect;
                    $sect={};
                    $lastindex=@parts[0];
                }
                $sect->{@parts[1]} = @parts[2];
                next;
            }        
        }
        push (@sections, $sect);
    } 
    return (@sections);
}

sub uci_add_sectiontype()
{
    my ($config,$stype)=@_;
    system `touch /etc/config/$config` if (! -f "/etc/config/$config");
    my $cmd=sprintf('uci add %s %s',$config,$stype);
    my $res=`$cmd`;

    my $rc=$?;
    return ($rc);
}

sub uci_delete_option()
{
    my ($config,$stype,$index,$option)=@_;
    my $cmd=sprintf('uci delete %s.@%s[%s].%s',$config,$stype,$index,$option);
    my $res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc,$res);
}
sub uci_set_indexed_option()
{
    my ($config,$stype,$index,$option,$val)=@_;
    system `touch /etc/config/$config` if (! -f "/etc/config/$config");
    if (&uci_get_sectiontype_count($config,$stype) eq 0) {
        my $rc=&uci_add_sectiontype($config,$stype);
        # abort if error
        if ($rc) { return $rc};
    }
    my $cmd=sprintf('uci set %s.@%s[%s].%s=%s',$config,$stype,$index,$option,$val);
    my $res=`$cmd`;
    my $rc=$?;
 
    return $rc;
}

sub uci_delete_indexed_type()
{
    my ($config,$stype,$index)=@_;
    my $cmd=sprintf('uci delete %s.@%s[%s]',$config,$stype,$index);
    my $res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc,$res);
}

sub uci_commit()
{
    my ($config)=@_;
    my $cmd=sprintf('uci commit %s',$config);
    my $res=`$cmd`;
    my $rc=$?;
    return $rc;
}

sub uci_revert()
{
    my ($config)=@_;
    my $cmd=sprintf('uci revert %s',$config);
    my $res=`$cmd`;
    my $rc=$?;
    chomp($res);
    return ($rc,$res);
}

### UCI Helpers END ###
sub DEBUGEXIT()
{
    my ($text) = @_;
    http_header();
    html_header("$node setup", 1);
    print "DEBUG-";
    print $text;
    print "</body>";
    exit;
}


#weird uhttpd/busybox error requires a 1 at the end of this file
1

