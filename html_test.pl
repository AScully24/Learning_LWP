#!/usr/bin/perl -w
use strict;
use HTML::TreeBuilder 3;  # make sure our version isn't ancient
use LWP::Simple;


#Gets the text content of a post
sub getText{
        my $finalString = "";
        my @array = $_[0]->find_by_attribute("class","js-tweet-text tweet-text");
	foreach(@array){
                 $finalString .= $_->as_text();
        }
        return $finalString;
}

# Gets the poster user name of a block.
sub getPosterUserName{
        #Gets the tags within the html that handle twitter links.
	my @twitterLinks = $_[0]->find_by_tag_name("s","b");
	
	my $finalString = "";
	my $isSearch = 0;
	my $continueLoop = 1;
	my $counter = 0;
	
        while($continueLoop){
                 my $string = $twitterLinks[$counter]->as_text();
                 
                 if($string eq "@") {
                          $isSearch = 1;
                 }elsif($isSearch){
                          $finalString = $string;
                          $continueLoop = 0;
                 }
                 
                 $counter++;
        }
        return $finalString;
}

sub getAtMessages{
        #Gets the tags within the html that handle twitter links.
	my @twitterLinks = $_[0]->find_by_tag_name("s","b");
	
	my $finalString = "";
	my $isSearch = 0;
	my $atCount = 0; #If 1, it is the post, and we ignore. Anything after the first user name is user.
	
        foreach(@twitterLinks){
                 my $string = $_->as_text();
                 
                 if($string eq "@") {
                          $isSearch = 1;
                          $atCount++;
                 }elsif($atCount >= 2 && $isSearch){
                          $finalString .= $string . " ";
                          $isSearch = 0;
                 }
        }
        return $finalString;         
}

sub getTimePosted{
	my @twitterLinks = $_[0]->find_by_attribute("class","tweet-timestamp js-permalink js-nav js-tooltip");
	my $finalString = $twitterLinks[0]->attr("title");
        return $finalString;
}

#Gets the list of hashtags involved in a post
sub getTwitterLinks{
        #Handles arguements. First argument is the filter (either @ or #) that we asrte search for.
        #Second gets the tags within the html that handle twitter links.
	my $search = $_[0]; 
	my @twitterLinks = $_[1]->find_by_tag_name("s","b");
	
	my $finalString = "";
	my $isSearch = 0;
        foreach(@twitterLinks){
                 my $string = $_->as_text();;
                 
                 
                 if($string eq $search) {
                          $isSearch = 1;
                 }elsif($isSearch){
                          $finalString = $finalString .= $string . " ";
                          $isSearch = 0;
                 }
        }
        return $finalString;
}

my $webpage = "https://twitter.com/hashtag/ostrich";
my $pageHTML = get $webpage;

my $root = HTML::TreeBuilder->new;
$root->parse($pageHTML);
#$root->parse_file("report.txt");
$root->eof( );  # done parsing for this tree
#$root->dump;   # print( ) a representation of the tree

#my @array = $root->find_by_attribute("class","js-tweet-text tweet-text");
my @array = $root->find_by_attribute("class","content");

#$array[1]->dump;

open(my $fh, ">", "report.txt");

#Titles
print $fh "HashTags|Tweet|Tweeters UserName|Tweeted to:\n";

foreach(@array){
  print $fh getTwitterLinks("#",$_), "|",getText($_), "|", getPosterUserName($_), "|", getAtMessages($_), "|", getTimePosted($_), "\n";  
}

close $fh;



$root->delete; # erase this tree because we're done with it


