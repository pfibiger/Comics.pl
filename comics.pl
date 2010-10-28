#!/usr/bin/perl

# This script (c) 1999 Philip Fibiger - pnf1@cornell.edu
# it can be freely distributed, as long as this comment
# remains intact
# version 1.9
#
# CHANGELOG:
# 1.0: Initial version.  Has some comics.
# 1.1: Added some more comics.
# 1.2: Added more comics.
# 1.3: Major rewrite.
#      - Rewrote script to use hashes - Jeremy Muhlich
#      - removed unneeded grep() call in pennyarcade handler
#      - added checkboxes for comic selection
#      - added more comics
# 1.4: Comics now sorted alphabetically, 2 new comics added.
# 1.5: More features
#      - images now link to main URL of comic.
#      - proxy support added by Chris Hirsch.
#      - checkboxes for displayed comics appear next to title.
#      - 2 columns of checkboxes; enhanced readability.
# 1.6: More comics
#      - added many many comics
#      - fixed PvP and Penny Arcade (which had recently broken)
#      - now, for proxy support, whoever installs the script on the webserver
#        needs to edit the "$proxy_server = " line below if the *webserver*
#        has to use a proxy to access the web.
# 1.7: Fixes, comic additions
#        Sorry we took so long to get this release out.  A bunch of people
#        sent in fixes for the sites that have changed their format since
#        1.6.  Thanks to all of you, even if we used someone else's fix
#        for a certain comic.  :)
#        - fixed all King Features comics, added Heathcliff and
#          General Protection Fault -- Eike Bernhardt
#        - fixed Close To Home, added Peanuts -- Carsten Clasohm
#        - added Sluggy Freelance -- Leif Sawyer
# 1.8: Some more fixes, preliminary avantgo support
#	 1.7 fixed kingfeatures comics, but since then, the kingfeatures.com
#	 site has thrown us a curveball, and accesses comics via a cgi script
#	 that doesn't allow outside referrers to get the image. if anyone wants
#	 to make kingfeatures comics work, feel free to send in a diff, i
#	 promise to release a fix quickly, if submitted. Also, I started working
#	 on avantgo support. all it does right now is strip all checkboxes and 
#	 the header graphic. It could, using perl graphic manipulation libraries
#	 chop the pictures into 150pixel wide chunks, and then  put them into a
#	 table. Avantgo has a max of 150 wide pixel pictures before it starts to
#	 scale them. It would have to work around the 32k limit, i imagine by
#	 linking to each comic individually. I may putter around with this, but
#	 if anyone has a burning desire to read comics on their palm/pocket pc/
#	 visor, more power to ya'.
#	 - Also fixed Penny Arcade, PVP, and RedMeat. 
# 1.9: New comics, some more fixes?
#	 - Added Jerk City, Bad Tech
#	 - Fixed all King Features - Vitor Colaco
#	 - Fixed General Protection Fault

use LWP::Simple qw(get);
use LWP::UserAgent;
use CGI 2.56 qw(:standard);
use strict;

sub brn {
  return br . "\n";
}

my $ua = new LWP::UserAgent;

# uncomment the following line, and subsitute your
# proxy server address for the dummy address

#  $ua->proxy('http', 'http://proxyserver.com:1280/');

my $html;
my $img;
my $id;
my $info;
my $proxy_address;
my $visited;
my $odd;
my $pic;
my $avantgo;

# For people who would like to add new comics to the page, it is a relatively
# simple procedue. The arrays stored in the hash have 4 parts:
#
# 0) the title
# 1) the base url of the image
# 2) a sub that returns the name of the image itself.
# 3) the url of the comic's homepage
#
# A typical comic is at http://www.testcomic.com/images/test121899.gif .
# The title (0) might be:
#   'Test Comic'
# The base url of the comic (1) would be:
#   'http://www.testcomic.com/images/'
# The bit of code in the subroutine (2) uses get_comic to download the html
# for the webpage the comic sits on, and searches through it for the name
# of today's comic, based on certain patterns that exist in the page.
# The url for the comic's homepage (3) might be:
#   'http://www.testcomic.com'
# The comic image will be a clickable link to this url.


# Downloads a URL, with proxy support.
# params: URL to fetch
# returns: data contained in the file at the URL
sub get_comic {
  my ($url) = @_;
  # Create a request
  my $req = new HTTP::Request( 'GET', $url);
  # Pass request to the user agent and get a response back
  return ($ua->request($req))->content;
}



########################
#some comics are archived by date
my @time = localtime();
my $month = $time[4];
my $mday  = $time[3];
my $year =  $time[5]; 
#######################

print
  header,
  start_html(-title=>'comics.pl - the comics page generator', -bgcolor=>'white'),"\n";

my %comics =
  (
   pennyarcade =>
   [
    'Penny Arcade',
    'http://www.penny-arcade.com/images/2000/',
    sub {
      $html = get_comic('http://www.penny-arcade.com/');
      ($img) = $html =~ /<option.*?<option.*?\"(.*?)\"/is;
      $img =~ s/view\.php3\?date\=//gi;
      $img =~ s/\-//gi;
      $img = $img . "l.jpg";
      return $img;
      
    },
    'http://www.penny-arcade.com'
   ],
   sinfest =>
   [ 'sinfest',
     'http://www.sinfest.net/',
     sub {
       $html = get_comic('http://www.sinfest.net/');
       ($img) = $html =~ m:(/comics/sf\d{4}\d{2}\d{2}\.gif):;
       return $img;
     },
     'http://www.sinfest.net'
   ],
   goats =>
   [ 'Goats',
     'http://www.goats.com/comix/',
     sub {
       $html = get_comic('http://www.goats.com/');
       ($img) = $html =~ m:/comix/(\d+/goats\d+\.gif):;
       return $img;
     },
     'http://www.goats.com/',
   ],   
   citizendog =>
   [
    'Citizen Dog',
    'http://www.uexpress.com/ups/comics/cd/strips/',
    sub {
      $html = get_comic('http://www.uexpress.com/ups/comics/cd/');
      ($img) = $html =~ m:/ups/comics/cd/strips/(cd[0-9]*\.gif):;
      return $img;
    },
    'http://www.uexpress.com/ups/comics/cd/'
   ],
   duplex =>
   [ 'The Duplex',
     'http://www.comics.com/universal/duplex/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/duplex/ab.html'),
       ($img) = $html =~ m:/universal/duplex/archive/images/(duplex\d+.gif):;
       return $img;
     },
     'http://www.comics.com/universal/duplex/ab.html',
   ],
   franknernest =>
   [ 'Frank and Ernest',
     'http://www.comics.com/comics/franknernest/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/franknernest/ab.html'),
       ($img) = $html =~ m:/comics/franknernest/archive/images/(franknernest\d+.jpg):;
       return $img;
     },
     'http://www.comics.com/comics/franknernest/ab.html',
   ],
   evillovecomic =>
   [
   'Evil Love Comic',
   'http://www.angelfire.com/indie/weed/images/',
    sub {
      $img = 'mendont.jpg';
      return $img;
    },
    'http://www.angelfire.com/indie/weed/'
   ],
   badtech =>
   [
   'Bad Tech',
   'http://www.badtech.com/a/0/',
    sub {
      $img = "\/$month\/$mday" . ".jpg";
      return $img;
    },
    'http://www.badtech.com/'
   ],
   allyoop =>
   [ 'Ally Oop',
     'http://www.comics.com/comics/alleyoop/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/alleyoop/ab.html');
       ($img) = $html =~ m:/comics/alleyoop/archive/images/(alleyoop\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/alleyoop/'
   ],
      jerkcity =>
   [ 'Jerk City',
     'http://www.jerkcity.com/',
     sub {
       ($img) = "today.gif";
       return $img;
     },
    'http://www.jerkcity.com/'
   ],
   roseisrose =>
   [ 'Rose Is Rose',
     'http://www.comics.com/comics/roseisrose/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/roseisrose/ab.html');
       ($img) = $html =~ m:/comics/roseisrose/archive/images/(roseisrose\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/roseisrose/'
   ],
   pickles =>
   [ 'Pickles',
     'http://www.comics.com/comics/pickles/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/pickles/ab.html');
       ($img) = $html =~ m:/comics/pickles/archive/images/(pickles\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/pickles/'
   ],
   forbetterorforworse =>
   [ 'For Better or For Worse',
     'http://www.comics.com/comics/forbetter/archive/images/',
     sub {
       $html = get_comic('http://www.fborfw.com/comics/forbetter/ab.html');
       ($img) = $html =~ m:/comics/forbetter/archive/images/(forbetter\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/forbetter/'
   ],
   inthebleachers =>
   [ 'In The Bleachers',
     'http://www.comics.com/universal/bleachers/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/bleachers/ab.html');
       ($img) = $html =~ m:/universal/bleachers/archive/images/(bleachers\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/universal/bleachers/'
   ],
   drabble =>
   [ 'Drabble',
     'http://www.comics.com/comics/drabble/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/drabble/ab.html');
       ($img) = $html =~ m:/comics/drabble/archive/images/(drabble\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/drabble/'
   ],
   arloandjanis =>
   [ 'Arlo and Janis',
     'http://www.comics.com/comics/arlonjanis/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/arlonjanis/ab.html');
       ($img) = $html =~ m:/comics/arlonjanis/archive/images/(arlonjanis\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/arlojanis/'
   ],
   crankshaft =>
   [ 'Crankshaft',
     'http://www.comics.com/universal/crankshaft/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/crankshaft/ab.html');
       ($img) = $html =~ m:/universal/crankshaft/archive/images/(crankshaft\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/universal/crankshaft/'
   ],
   marvin =>
   [
    'Marvin',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/marvin/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Marvin\?date\=\d+)\":g; 
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return "get_image($img)";
    },
    'http://www.kingfeatures.com/comics/marvin/'
   ],
   funkywinkerbean =>
   [
   'Funky Winkerbean',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/fwinker/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Funky_Winkerbean\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/fwinker/'
   ],
#   freeforall =>
#   [
#    'Free For All',
#    'http://www.kingfeatures.com/comics/free/',
#    sub {
#       $html = get_comic('http://www.kingfeatures.com/comics/free/index.htm');
#       my ($frameaddr) = $html =~ m:FRAME SRC="(frt\d+\.htm)":;
#       my $framehtml = get_comic('http://www.kingfeatures.com/comics/free/'.$frameaddr);
#       my @gifs = $framehtml =~ m:\Qimages[1].src\E=\'(frt\d+\.gif)\':g;
#       $img = pop(@gifs);
#       return $img;
#    },
#    'http://www.kingfeatures.com/comics/free/'
#   ],
   babyblues =>
   [
   'Baby Blues',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/babyblue/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Baby_Blues\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/babyblue/'
   ],
   pvp =>
   [ 'PvP',
     'http://www.pvponline.com/archive/2000/',
     sub {
       $html = get_comic('http://www.pvponline.com/');
       ($img) = $html =~ m:archive/2000/(pvp\d*\.gif):;
       return $img;
     },
     'http://www.mpog.com/pvp'
   ],
   redmeat =>
   [ 'Red Meat',
    'http://www.redmeat.com/redmeat/current/',
     sub {
       $html = get_comic('http://www.redmeat.com/current/index.html');
       ($img) = "index-1.gif";
       return $img;
     },
     'http://www.redmeat.com'
   ],
   robotman =>
   [ 'Robotman',
     'http://www.comics.com/comics/robotman/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/robotman/ab.html');
       ($img) = $html =~ m:/comics/robotman/archive/images/(robotman\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/robotman'
   ],
   calvin =>
   [ 'Calvin And Hobbes',
    'http://www.calvinandhobbes.com/strips/',
     sub {
       $html = get_comic('http://www.calvinandhobbes.com');
       ($img) = $html =~ m:http\://www\.calvinandhobbes\.com/strips/(\d\d/\d\d/ch\d+\.gif):;
       return $img;
     },
     'http://www.calvinandhobbes.com'
   ],
   overhedge =>
   [ 'Over The Hedge',
     'http://www.comics.com/comics/hedge/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/hedge/ab.html');
       ($img) = $html =~ m:/comics/hedge/archive/images/(hedge\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/hedge/'
   ],
   liberty =>
   [ 'Liberty Meadows',
     'http://www.comics.com/comics/liberty/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/liberty/ab.html');
       ($img) = $html =~ m:/comics/liberty/archive/images/(liberty\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/liberty/'
   ],
   bc =>
   [ 'B.C.',
     'http://www.comics.com/comics/bc/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/bc/ab.html');
       ($img) = $html =~ m:/comics/bc/archive/images/(bc\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/bc/'
   ],
   wizardofid =>
   [ 'Wizard of Id',
     'http://www.comics.com/comics/wizardofid/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/wizardofid/ab.html');
       ($img) = $html =~ m:/comics/wizardofid/archive/images/(wizardofid\d*\.gif):;
       return $img;
     },
    'http://www.comics.com/comics/wizardofid/'
   ],
   userfriendly =>
   [ 'User Friendly',
     'http://www.userfriendly.org/cartoons/archives/',
     sub {
       $html = get_comic('http://www.userfriendly.org/static/');
       ($img) = $html =~ m:http\://www\.userfriendly\.org/cartoons/archives/(\d\d\w\w\w/xuf\d+\.gif):;
       return $img;
     },
     'http://www.userfriendly.org'
   ],
   dilbert =>
   [ 'Dilbert',
     'http://www.comics.com/comics/dilbert/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/dilbert/ab.html');
       ($img) = $html =~ m:/comics/dilbert/archive/images/(dilbert\d*\.gif):;
       return $img;
     },
     'http://www.dilbert.com'
   ],
   peanuts =>
   [ 'Peanuts',
     'http://www.comics.com/comics/peanuts/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/peanuts/ab.html');
       ($img) = $html =~ m:/comics/peanuts/archive/images/(peanuts\d*\.gif):;
       return $img;
     },
     'http://www.peanuts.com'
   ],
   pcnpixel =>
   [ 'PC and Pixel',
     'http://www.comics.com/comics/pcnpixel/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/pcnpixel/ab.html');
       ($img) = $html =~ m:/comics/pcnpixel/archive/images/(pcnpixel\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/pcnpixel/'
   ],
   luann =>
   [ 'Luann',
     'http://www.comics.com/comics/luann/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/luann/ab.html');
       ($img) = $html =~ m:/comics/luann/archive/images/(luann\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/luann/'
   ],
   foxtrot =>
   [ 'Fox Trot',
     'http://www.comics.com/universal/foxtrot/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/foxtrot/ab.html');
       ($img) = $html =~ m:/universal/foxtrot/archive/images/(foxtrot\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/foxtrot/'
   ],
   garfield =>
   [ 'Garfield',
     'http://www.comics.com/universal/garfield/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/garfield/ab.html');
       ($img) = $html =~ m:/universal/garfield/archive/images/(garfield\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/garfield/'
   ],
   adam =>
   [ 'Adam @ Home',
     'http://www.comics.com/universal/adam/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/adam/ab.html');
       ($img) = $html =~ m:/universal/adam/archive/images/(adam\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/adam/'
   ],
   doonesbury =>
   [ 'Doonesbury',
     'http://www.comics.com/universal/doonesbury/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/doonesbury/ab.html');
       ($img) = $html =~ m:/universal/doonesbury/archive/images/(doonesbury\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/doonesbury/'
   ],
   boondocks =>
   [ 'The Boondocks',
     'http://www.comics.com/universal/boondocks/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/boondocks/ab.html');
       ($img) = $html =~ m:/universal/boondocks/archive/images/(boondocks\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/boondocks/'
   ],
   nonsequitur =>
   [
     'Non Sequitur',
     'http://www.non-sequitur.net/archive/',
     sub {
	$html = get_comic('http://www.non-sequitur.net/');
	($img) = $html =~ m:non\-sequitur\.net/archive/(.*?\.gif):;
	return $img;
	},
     'http://www.non-sequitur.net'
   ],
   aftery2k =>
   [
     'After Y2K',
     'http://www.geekculture.com/geekycomics/Aftery2k/y2Kimages/',
     sub {
	$html = get_comic('http://www.geekculture.com/geekycomics/Aftery2k/aftery2kmain.html');
	($img) = $html =~ m:y2Kimages/(\d*\.gif):;
	return $img;
        },
	'http://www.geekculture.com/geekycomics/Aftery2k/aftery2kmain.html'
   ],
   fifthwave =>
   [ 'The 5th Wave',
     'http://www.comics.com/universal/fifthwave/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/universal/fifthwave/ab.html');
       ($img) = $html =~ m:/universal/fifthwave/archive/images/(fifthwave\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/universal/fifthwave/'
   ],
   closehome =>
   [ 'Close To Home',
     'http://www.uexpress.com/ups/comics/cl/strips/',
     sub {
       $html = get_comic('http://www.uexpress.com/ups/comics/cl/');
       ($img) = $html =~ m:/ups/comics/cl/strips/(cl\d*\.gif):;
       return $img;
     },
     'http://www.uexpress.com/ups/comics/cl/'
   ],
   zits =>
   [
   'Zits',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/zits/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Zits\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/zits/'
   ],
      zits =>
   [
   'The Amazing Spiderman',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/spidermn/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Spiderman\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/spidermn/'
   ],
   hagar =>
   [ 
   'Hagar The Horrible',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/hagar/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Hagar_The_Horrible\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/hagar/'
   ],
   beetle =>
   [ 
   'Beetle Bailey',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/bbailey/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Beetle_Bailey\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/blondie/'
   ],
   blondie =>
   [ 
   'Blondie',
    'http://est.rbma.com/content/',
    sub {
      $html = get_comic('http://www.kingfeatures.com/comics/blondie/comic.htm');
      ($img) = $html =~ m:IMG src=\"(http\:\/\/est\.rbma\.com\/content\/Blondie\?date\=\d+)\":g;
      ($img) =~ s/http\:\/\/est\.rbma\.com\/content\///gi;
      return $img;
    },
    'http://www.kingfeatures.com/comics/blondie/'
   ],
   drfun =>
   [ 'Doctor Fun',
     'http://metalab.unc.edu/Dave/Dr-Fun/',
     sub {
       return 'latest.jpg';
     },
     'http://metalab.unc.edu/Dave/Dr-Fun/html/'
   ],
   sluggy =>
   [ 'Sluggy Freelance',
     'http://pics.sluggy.com/comics/',
     sub {
       $html = get_comic('http://www.sluggy.com/');
       ($img) = $html =~ m:http\://pics\.sluggy\.com/comics/(\d+\w+\.gif):;
       if ($img == "" ) {
	 my($x);
	 my($imgn,$i,$imge) = $html =~
	   m|http://pics\.sluggy\.com/comics/(\d+b)(\d+)(\.jpg)|;
	 print "<!-- $imgn$i$imge -->\n";
	 for ($x = 1; $x <= 5; $x++) {
	   print a({-href => 'http//pics.sluggy.com/comics/'},
		   img({-src=> "http://pics.sluggy.com/comics/".$imgn.$x.$imge,
			-border=>'NO'}));
	 }
	 $img = $imgn . "6" . $imge;
       }
       return $img;
     },
     'http://www.sluggy.com'
   ],
   heathcliff =>
   [ 'Heathcliff',
     'http://www.comics.com/comics/heathcliff/archive/images/',
     sub {
       $html = get_comic('http://www.comics.com/comics/heathcliff/ab.html');
       ($img) = $html =~ m:/comics/heathcliff/archive/images/(heathcliff\d*\.gif):;
       return $img;
     },
     'http://www.comics.com/comics/heathcliff/'
   ],
   gpf =>
   [ 'General Protection Fault',
     'http://www.gpf-comics.com/comics/',
     sub {
       $html = get_comic('http://www.gpf-comics.com/');
       ($img) = $html =~ m:comics/(gpf\d*\.gif):;
       return $img;
     },
     'http://www.gpf-comics.com/'
   ],
);

#print
#  header,
#  start_html(-title=>'comics.pl - the comics page generator', -bgcolor=>'white'),"\n";

$avantgo = param('_avantgo');
Delete('_avantgo');

if (!$avantgo) {
print a({-href => 'http://www.fdntech.com'}, img({-src=>'http://www.people.cornell.edu/pages/pnf1/comics/fdnpix2.jpg', -border=>'NO'})),br, br, brn;
  }

# get visited flag and delete the param so it's not treated as a comic
$visited = param('_visited');
Delete('_visited');

# begin the form
print start_form(-method => 'GET');

# print out name and image for each comic
foreach $id (sort &param) {
  $info = $comics{$id};
  if (!$avantgo) {
  print b(checkbox(-name  => $id,
		 -label =>' '.$comics{$id}->[0]));
    }
  print br, brn;
  # call parsing code for this comic, to get the image name
  $pic = &{$info->[2]};
  # check to see that the search code got the webpage and parsed it correctly
  if ($pic) {
    # yes, everything looks ok
    print a({-href => $info->[3]}, img({-src=>$info->[1].$pic, -border=>'NO'}));
  } else {
    # no, an empty string was returned which means something went wrong
    print a({-href => $info->[3]}, 'This comic');
    print ' cannot currently be viewed (either the site is unavailable or the HTML format changed). ';
    print 'You can reload this page to try to fetch the comic again.';
  }
  print br, br, brn;
  # Remove the hash entry for this comic, so we don't print a
  # checkbox for it at the bottom of the page.
  delete $comics{$id};
}

# print checkboxes for unselected comics
if (!$avantgo) {
  if (!$visited) {
    # Set the params for all comics, to make the checkboxes appear
    # as checked when they're printed out.
    foreach $id (keys(%comics)) {
      param($id, 'on');
    }
  print h1('Select only the comics you want to see:');
  } else {
    print hr, h1('Currently unselected comics:');
  }
  print br, '<table border="0" cellpadding="5" cellspacing="5">', "\n";
  $odd = 1;
  foreach $id (sort(keys(%comics))) {
    print '<tr>' if $odd;
    print '<td>';
    print checkbox(-name    => $id,
    		   -label   => ' '.$comics{$id}->[0]);
    print '</td>';
    print "</tr>\n" if !$odd;
    $odd = !$odd;
  }
  print "</tr>\n" if !$odd;
  print '</table>', "\n";
}
#tell comics to use minimal formatting, for avantgo users
 print checkbox(-name	   => '_avantgo',
                -label     => 'are you using avantgo?');

# tell subsequent calls to the script that this is not the user's first
# visit, and thus not to print only the checkboxes
print hidden(-name =>  '_visited',
	     -value => 'yes'), "\n";
# submit button
print br, submit(-value => 'Get comics'), brn;

# explicitly do NOT use CGI's end_form because we don't want the extra
# state-preserving CGI params that it creates.
print '</form>', "\n";

print '(Bookmark the resulting page to save your preferences!)', brn;

print end_html;
