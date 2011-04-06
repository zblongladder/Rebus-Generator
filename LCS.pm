#!/usr/bin/perl

package LCS;

use strict;
use List::Util qw(max);

# A Perl implementation of a dynamic-programming solution to the
# least-common-subsequence problem with two input strings. It's
# NP-hard with n inputs, but with a limited number, it's polynomial
# time...specifically, O(n*m) for inputs of length n and m.

# This could probably be made a bit more Perl-ish, but I'm focusing on
# cleanliness and readability...I try not to bring any cowboy
# coding to work. It's a real danger in Perl, making something completely
# unreadable and unsupportable.


# globals

our %weights;

# end globals

sub charAt($$){ # yup, Perl doesn't have a string function that returns the character in the Nth position. I decided to stick this in a subroutine, since it'll be more readable than doing the substr($x,$y,1) thing all over the place.
  my($string,$position) = @_;
  return substr($string,$position,1);
}

sub populate_weights($){
  my ($weightfile,) = @_;
  open WEIGHT_FILE, $weightfile;
  while(<WEIGHT_FILE>){
    next if(/^#/); # skip weightfile comments -- i.e., lines beginning in #
    if(/^(\w)\s+(\d+)(#.*)?$/){ # a letter, whitespace to separate, a digit signifying weight, and optionally an inline comment comprises a line
      $weights{$1} = $2;
    }
  }
  for("a".."z","A".."Z"){
    unless(defined($weights{$_})){ # defined() rather than boolean test b/c weight could be 0
      $weights{$_} = 1; # defaulting to 1.
    }
  }
}


sub lcs($$){ # Since the weightedLCS just tracks weights and doesn't actually use them in the algorithm, the resultant weight can just be ignored and the same code reused.
  return weightedLCS(@_,"");
}

sub weightedLCS($$$){ #simple dynamic-programming solution to the least-common-subsequence problem for two input strings with weight-tracking tacked on
  my ($string1,$string2,$weight_file) = @_;
  populate_weights($weight_file);
  my @length_arr; # two-dimensional array to memoize lengths/weights

  #NB: (1..length $STRING) so we don't end up referenceing @arr[-1]
  for my $string1_pos(1..length $string1){
    for my $string2_pos(1..length $string2){
      if(charAt($string1,$string1_pos-1) eq charAt($string2,$string2_pos-1)){
	$length_arr[$string1_pos][$string2_pos] = $length_arr[$string1_pos-1][$string2_pos-1]+$weights{charAt($string1,$string1_pos-1)};
      }
      else{
	$length_arr[$string1_pos][$string2_pos] = max ( $length_arr[$string1_pos][$string2_pos-1] , $length_arr[$string1_pos-1][$string2_pos] );
       }
    }
  }
  my $length_to_return = $length_arr[length $string1][length $string2];
  return ($length_to_return, \@length_arr);
}

sub getLCSString($$$){
  my ($string1, $string2, $length_arr_ref) = @_;
  my @length_arr = @$length_arr_ref;
  my ($count1,$count2) = (length $string1, length $string2);
  my $toReturn="";
  while ($count1!=0 && $count2!=0){
    if(charAt($string1,$count1-1) eq charAt($string2,$count2-1)){
      $toReturn .= charAt($string1,$count1-1);
      $count1--;
      $count2--;
    }
    elsif($length_arr[$count1][$count2-1] < $length_arr[$count1-1][$count2]){
      $count1--;
    }
    else{
      $count2--;
    }
  }
  return scalar reverse $toReturn;
}

return 1;
