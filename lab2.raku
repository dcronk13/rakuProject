######################################### 	
#    CS 381 - Programming Lab #1		#
#										#
#  < SOLUTION >							#
#  David Cronk							#
#  cronkd@oregonstate.edu				#
#########################################
my $name = "David Cronk";

#########################################
##
##  ETHICS Reminder
##
##  Yes: use the internet to learn Raku
##
##  No: don't use other people to do your work
##
#########################################

#########################################
# VARIABLE DEFINITIONS 
#########################################

# pseudo-constants...
# ... the tests override your choice, so
#     you can set your preferred value
my $STOP_WORDS = 0;           # flag - filter stopwords, 0 (off) | 1 (on)
my $DEBUG = 0;				  # flag - debug words, 0 (off) | 1 (on)
my $SEQUENCE_LENGTH = 10;	  # length of song title, suggested default 10
my $FILE = "";

# variable initialization...
# ... you will use all three at some point

# array of song tracks
my @tracks = ();
# hash of hashes for bigram counts
my %counts = ();
# hash of words already used in current sequence, reset for new sequence
my %word_history = ();


#########################################
# Functions that you will edit
#########################################

# This extracts a title from the raw track input line
sub extract_title {
	if ($DEBUG) {say "<extracting titles>\n";}
	my @tracktitles = ();
	
	for @tracks -> $track {
	
		################
		# LAB 1 TASK 1 #
		################

		#Here, .*\> grabs (but doesn't capture) everything up until >
		#* makes it so it grabs the longest occurence, so it finds the last >. I don't know if there is some >
		#is present in a title, which may be causing the mismatch of values

		#(.+) grabs all of the title, and <["]> serves as a stop. Could've used \" but wanted to practice char sets
		#if ($track ~~ /.*\>(.+)<["]>/) {
		#		@tracktitles.push: $0;
		#	}
		#Some tracks had ending " and others didn't. Couldn't find a solution in one regex, so had an else for
		#titles with no ending "
		if ($track ~~ /.*SEP\>(.+)$/) {
			@tracktitles.push: $0;
			}
		}

	# Updates @tracks
	return @tracktitles;
}

# This removes comments and parenthetical information
sub comments {
	if ($DEBUG) {say "<filtering comments>\n";}
	my @filteredtitles = ();
	
	# This loops through each track
	for @tracks -> $title { 

		##########################
		# LAB 1 TASK 2           #
		##########################
		#(   [   {   \   /  _   -   :   "   `   +   =   feat.
		#I think all this section works as intended. takes first instance of () text and everything after to replace
		#with nothing
		$_ = $title;
		$_ ~~ s/\(.*$//;
		$_ ~~ s/\[.*$//;
		$_ ~~ s/\{.*$//;
		$_ ~~ s/\\.*$//;
		$_ ~~ s/\/.*$//;
		$_ ~~ s/_.*$//;
		$_ ~~ s/\-.*$//;
		$_ ~~ s/\:.*$//;
		$_ ~~ s/\".*$//;
		$_ ~~ s/\`.*$//;
		$_ ~~ s/\+.*$//;
		$_ ~~ s/\=.*$//;
		$_ ~~ s/feat\..*$//;

		
		# Add the edited $title to the new array of titles
		@filteredtitles.push: $_;
	}
	# Updates @tracks
	return @filteredtitles;
}

# This removes punctutation
sub punctuation {
	if ($DEBUG) {say "<filtering punctuation>\n";}
	my @filteredtitles = ();

	##########################
	# LAB 1 TASK 3           #
	##########################
	
	for @tracks -> $title { 
		##########################
		$_ = $title;

		#Again, think this function works fine, takes instance of unwanted character globally and replaces with nothing
		$_ ~~ s:g/\?//;
		$_ ~~ s:g/\x[00BF]//;
		$_ ~~ s:g/\!//;
		$_ ~~ s:g/\x[00A1]//;
		$_ ~~ s:g/\.//;
		$_ ~~ s:g/\;//;
		$_ ~~ s:g/\://;
		$_ ~~ s:g/\&//;
		$_ ~~ s:g/\$//;
		$_ ~~ s:g/\*//;
		$_ ~~ s:g/\@//;
		$_ ~~ s:g/\%//;
		$_ ~~ s:g/\#//;
		$_ ~~ s:g/\|//;

		########################## End Task 3
		# Add the edited $title to the new array of titles
		@filteredtitles.push: $_;
	}
		
	# Updates @tracks	
	return @filteredtitles;			
}


# This removes non-English characters, trailing whitespace, and blank titles
sub clean {
	if ($DEBUG) {say "<filtering non-ASCII characters>\n";}
	my @filteredtitles = ();
	
	##########################
	# TASK 4, 5, 6, 7 Below  #
	##########################
		
	# This loops through each track
	for @tracks -> $title {
	
		##########################
		# LAB 1 TASK 4           #
		##########################

		$_ = $title;

		#Tried doing these separately. Starting apostrophe worked fine, but second cause only the track to be pushed for some reason
		#That is why I combined both. This may be a cause of some issues
		$_ ~~ s/^\'+//;
		$_ ~~ s/\'+$//;

		$_ ~~ s/^\s*//;
		$_ ~~ s/\s*$//;    # trim trailing whitespace



		########################## End Task 4

	
		##########################
		# LAB 1 TASK 5           #
		##########################

		#Tried to set a negated character set with <-[\w\s']> and searched globally throughout string to see if there
		#was a match and if so, would go next

		#Found this cut too little, and I think it was the \w, as after checking the prints, the n~ character still appeared

		#As such, switched the logic to see if the title had only A-z, 0-9, space and '. If the whole string containted
		#only those characters, would keep, and if not, would skip
		if ($_ ~~ m:g/<-[A..Za..z\d\s\']>/) {
			next;
		}


		########################## End Task 5
	
		
	
		##########################
		# LAB 1 TASK 6           #
		##########################

		#These two should work, if title from start to finish is only space or ', skips
		if ($_ ~~ /^(\s*)$/) {
			next;
		}


		if ($_ ~~ /^(\'*)$/) {
			next;
		}
	
		########################## End Task 6
	

		##########################
		# LAB 1 TASK 7           #
		##########################

		#This worked as intended
		@filteredtitles.push: lc($_);
		########################## End Task 7
		
	}
	# Updates @tracks	
	return @filteredtitles;			
}
	
# This removes common stopwords	
sub stopwords {
	if ($DEBUG) {say "<filtering stopwords>\n";}
	my @filteredtitles = ();

	##########################
	# LAB 1 TASK 8 #
	##########################

	for @tracks -> $title { 

		##########################
		$_ = $title;

		#Some of the logic didn't make sense here for me.
		#Was simple, but some cases didn't seem right to me but didn't know if it was intended behavior
		#For example, I found one title "Tha Me Dis", became Th Me Dis
		#So this would say that the a at the end of Tha was being picked up and replaced, regardless if h is a boundary
		#I tried using [\s] to go before the boundary so it would pattern match but not be captured, but
		#this caused a whitespace to be taken out before the word as well

		$_ ~~ s:g:i/<|w>a<|w>\s//;
		$_ ~~ s:g:i/<|w>an<|w>\s//;
		$_ ~~ s:g:i/<|w>and<|w>\s//;
		$_ ~~ s:g:i/<|w>by<|w>\s//;
		$_ ~~ s:g:i/<|w>for<|w>\s//;
		$_ ~~ s:g:i/<|w>from<|w>\s//;
		$_ ~~ s:g:i/<|w>in<|w>\s//;
		$_ ~~ s:g:i/<|w>of<|w>\s//;
		$_ ~~ s:g:i/<|w>on<|w>\s//;
		$_ ~~ s:g:i/<|w>or<|w>\s//;
		$_ ~~ s:g:i/<|w>out<|w>\s//;
		$_ ~~ s:g:i/<|w>the<|w>\s//;
		$_ ~~ s:g:i/<|w>to<|w>\s//;
		$_ ~~ s:g:i/<|w>with<|w>\s//;


		##########################
		# Add the edited $title to the new array of titles
		@filteredtitles.push: $_;
	}
	
	########################## End Task 8
	
	# Updates @tracks	
	return @filteredtitles;			
}


# This splits the tracks into words and builds the bi-gram model
sub build_bigrams {

	##########################
	# LAB 2 TASK 1: Bigram Counts
	##########################
	#Run on track array for every title
	for @tracks -> $title {
		#Store title
		$_ = $title;

		#This creates an array arr, which takes the title $_ and splits it into
		#words seperated by space. ie. "take me home" would give ["take","me","home"]
		my @arr = $_.split(/\s+/);
		#Run a loop, starting at 0 (for arr index) to the number of elements in the split string array, inc 1
		loop (my $i = 0; $i < @arr.elems - 1; $i++){
			#if the split word already exists as a key in the hash table
			if (%counts{@arr[$i]}:exists) {
				#if the next word exists within the first key word.
				#Hash table is set up like this {happy => {gilmore => 1, go => 2}}
				#so %counts{happy}{gilmore} for example returns the value 1
				if (%counts{@arr[$i]}{@arr[$i+1]}:exists) {
					#if it exists already, increment the value by 1
					%counts{@arr[$i]}{@arr[$i+1]} = 1 + %counts{@arr[$i]}{@arr[$i+1]};
				}
				#Else the first key exists but not the second key
				else {
					#Add that key pair to the hashtable
					%counts{@arr[$i]}{@arr[$i+1]} = 1;
				}
			}
			#Else the first key does not exist, add it and the next word as a pair with value 1
			else {
			%counts{@arr[$i]}{@arr[$i+1]} = 1;
			}
		}
	}
	########################## End Task Bigram Counts
	if ($DEBUG) {say "<bigram model built>\n";}	
}


# This finds the most-common-word (mcw) to follow the given word
sub mcw {
	# Seed word (arg) for which we find the next word
	my $word = @_[0];
	# Store the most common next word in this variable and return it.
	my $best_word = '';

	##########################
	# LAB 2 TASK 2: MCW
	##########################
	##
	## Find all available "next" words for $word
	## Sort them (there is a function for that)
	##   so your results are deterministic and match the tests
	##
	## Iterate through all the available words
	##   that follow $word in the %counts
	##
	## Remember to check the %word_history	
	##   and skip that word if used before
	##
	## Find the candidate word with highest count,
	##   update $best_word (it gets returned)
    ## 
	## In case of ties, stick with first one found
	##    (i.e. use strictly > in your count comparison if)
	##    that way you make the same choice the tests do
	##
	## This comment is longer than your code will be for this task. 
	##########################

	#best val used to keep track of the greatest value in hash table
	#this is set to 0 so the first word pair in loop gets set to best_value and best_word
	my $best_val = 0;
	#This gets an array of the key values for a word in the hash table and stores as an array. Looking at the set up
	#This would give an array of ["gilmore",1,"go",2]
	#This section gotten from the lab help video, thank you Kingston!
	my @kv_array = %counts{$word}.kv;

	#Loop over that array starting at 0, running for full number of elements this time, with inc being +2 to avoid values
	loop (my $i = 0; $i < @kv_array.elems; $i+=2) {
		#$i+1 will return value of key.
		#If value of key is greater than current best_val (init 0)
		if (@kv_array[$i+1] > $best_val) {
			#If this key exists in word_history, skip
			if (%word_history{@kv_array[$i]}:exists) {
				next;
			}
			#Else, update best word and value
			$best_word = @kv_array[$i];
			$best_val = @kv_array[$i+1];
		}
		#Had to include this section to match output, as tie cases were random
		#If value is equal to best value
		elsif (@kv_array[$i+1] == $best_val) {
			#If current word is less than best word lexicographically
			if (@kv_array[$i] lt $best_word) {
				#If in word_history, skip
				if (%word_history{@kv_array[$i]}:exists) {
					next;
				}
				#else update values
				$best_word = @kv_array[$i];
			}
		}
	}
	#Add word to word_history
	%word_history{$best_word} = 1;
	########################## End Task MCW
	

	if ($DEBUG) {say "  <mcw for \'$word\' is \'$best_word'\>\n";}
	
	# return the most common word to follow word
	return $best_word
}



# This builds a song title based on mcw
sub sequence {
	if ($DEBUG) {say "<sequence for \'@_[0]\'>\n";}
	
	# clear word history for new sequence
	%word_history = ();
		
	##########################
	# LAB 2 TASK 3: Build Song Title
	##########################
	## Use the seed word to build a sequence.
	## For each word, look up the mcw
	## Add to sequence.
	## Repeat until next word is empty or newline
	## Mind the max $SEQUENCE_LENGTH
	## Remember to track word history using %word_history
	## My solution is about 12 lines (and could have been less)
	##########################
	#Word holds the start word
	my $word = @_[0];
	#sequence holds the entire string to be returned, starts as word
	my $seq = $word;
	#count keeps track of number of words in sequence, if it is greater than max sequence length, end loop
	my $count = 1;
	#Add start word to word_history
	%word_history{$word} = 1;
	#while gotten word is not empty/newline an d count is still less than seq_length
	while ($word ne '' && $word ne '\n' && $count < $SEQUENCE_LENGTH) {
		#get next mcw
		$word = mcw(lc($word));
		#if this word is empty/newline, dont add and break loop
		if ($word eq '' || $word eq '\n') {
			last;
		}
		#Else it is valid, concat both a space and the word to string
		$seq ~= ' ' ~ $word;
		#increment count
		$count += 1;
	}
	# return sequence
	return $seq;
	########################## End Task Song Title
}

##############################################################################
##             End Functions that students edit                              #
##############################################################################

##############################
##                           #
##     READ ONLY BELOW       #
##                           #
##############################

##############################
##############################
##############################
##                           #
##     Menu System           #
##                           # 
##############################
##                           # 
##  Read and understand      #
##   how to use the commands #
##                           # 
##  You do not need to edit  # 
##    the menu code below.   # 
##                           # 
##  You may expand the menu  # 
##   to you add your own     #
##   commands, if desired.   # 
##  				         # 
##  Do not break any of the  # 
##   existing command rules  # 
##   or you will fail tests. # 
##                           # 
##############################

# This is the "command" loop that runs until end-of-input
for lines() {    
	
	# split line into array of words
	my @input = split(/\s+/, $_);	
	# command is @input[0], first word
    my $command = lc(@input[0]);
	# argument is @input[1], second word
	
	if ($command eq "load") { 
		# load the input file
		my $file = lc(@input[1]);
		$FILE = $file;				
		load($file);	
	}elsif ($command eq "length") { 	
		# change the sequence length
		if ($DEBUG) {say "<sequence length " ~ @input[1] ~ ">\n";}
		$SEQUENCE_LENGTH = @input[1];
	}elsif ($command eq "debug") { 
		# toggle debug mode on/off
		if (lc(@input[1]) eq "on") {
			if ($DEBUG) {say "<debug on>\n";}
			$DEBUG = 1;
		}elsif (lc(@input[1]) eq "off") {
			if ($DEBUG) {say "<debug off>\n";}
			$DEBUG = 0;
		}else {
			say "**Unrecognized argument to debug: " ~ @input[1] ~ "\n";
		}
	}elsif ($command eq "count") { 
		if (lc(@input[1]) eq "tracks") {
			# count the number of lines in @tracks			
			count_lines(@tracks);
		}elsif (lc(@input[1]) eq "words") {
			# count the number of words in @tracks
			count_words(@tracks);
		}elsif (lc(@input[1]) eq "characters") {
			# count the number of characters in @tracks
			count_characters(@tracks);
		}else {
			say "**Unrecognized argument: " ~ @input[1] ~ "\n";
		}
	}elsif ($command eq "stopwords") { 
		# toggle stopwords on/off
		if (lc(@input[1]) eq "on") {
			if ($DEBUG) {say "<stopwords on>\n";}
			$STOP_WORDS = 1;
		}elsif (lc(@input[1]) eq "off") {
			if ($DEBUG) {say "<stopwords off>\n";}
			$STOP_WORDS = 0;
		}else {
			say "**Unrecognized argument: " ~ @input[1] ~ "\n";
		}
	}elsif ($command eq "filter") { 
		if (@input[1] eq "title") {		
			# extract the title from the line
			@tracks = extract_title();
		}elsif (@input[1] eq "comments") {
			# filter out extra phrases from the titles
			@tracks = comments();
		}elsif (@input[1] eq "punctuation") {
			# filter out punctuation		
			@tracks = punctuation();
		}elsif (@input[1] eq "unicode") {
			# filter out non-ASCII characters		
			@tracks = clean();
		}elsif (@input[1] eq "stopwords" && $STOP_WORDS) {	
			# filter out common words, if enabled
			@tracks = stopwords();		
		}else {
			say "**Unrecognized argument to stopwords: " ~ @input[1] ~ "\n";
		}	
	}elsif ($command eq "preprocess") { 
		# preprocess does all of the filtering tasks at once and builds bigrams
		
		# first, extract the title from the line
		@tracks = extract_title();
		# next, filter out extra phrases from the titles
		@tracks = comments();
		# next, filter out punctuation
		@tracks = punctuation();
		# next, filter out non-ASCII characters, blank titles
		@tracks = clean();		
		# next, filter out common words, if enabled
		if ($STOP_WORDS) {@tracks = stopwords();}
		
		# build bi-gram model counting occurences of word pairs
		build_bigrams();
	}elsif ($command eq "build") {
		# build bi-gram model counting occurences of word pairs
		build_bigrams();
	}elsif ($command eq "mcw") {
		# say the most-common-word to follow given word
		say mcw(lc(@input[1]));
	}elsif ($command eq "sequence") { 
		# say a song title based on the given word
		say sequence(lc(@input[1])).Str;
	}elsif ($command eq "print") {
		if (@input[1]) {
			say_some_tracks(val(@input[1]));
		}else {
			say_all_tracks(@tracks);
		}
	}elsif ($command eq "author") { 
		say "Lab1 by $name run";		
	}elsif ($command eq "name") { 
		say sequence(lc($name));               
	}elsif ($command eq "random") { 
		say sequence((%counts.keys)[%counts.keys.rand]).Str;			
	}else {
		# warn user if command was ignored
		say "**Unrecognized command: " ~ $command;
	}	
}


##############################
##############################
##############################
##                           #
##     Helper Functions      #
##                           # 
##############################
##                           # 
## Below contains important  # 
## functions the menu uses.  # 
##                           # 
##                           #
## Feel free to look around. #
##                           # 
## Help yourself to the      #
##     cookies and punch.    #
##                           #
## Look but don't touch.     #
##                           #
## You break it,             #
##         you bought it!    # 
##############################

# This loops through N lines of the array 
sub say_some_tracks($n) {
	if ($DEBUG) {say "<printing $n tracks>\n";}	
	loop (my $i=0; $i < $n; $i++) {
		say @tracks[$i];
	} 
}

# This loops through each line of the array
sub say_all_tracks {	
	if ($DEBUG) {say "<saying all tracks>\n";}	
	# are you sure you want to? (use CTRL+C to kill it)
	my $fh = open "tracks.out", :w;
	for (@_) { 
		$fh.say($_);
	} 
	$fh.close;
}

# Count lines of array
sub count_lines {
	if ($DEBUG) {say "<counting number of tracks>\n";}
	say @_.elems;
}

# Count words, after splitting on whitespace
sub count_words {
	if ($DEBUG) {say "<counting number of words>\n";}
	my $word_count = @_.words;
	say $word_count.elems;
}

# Count individual characters
sub count_characters {
	if ($DEBUG) {say "<counting number of characters>\n";}
	say @_.chars;
}

# Loads the tracks file into an array
sub load {
	for @_.IO.lines -> $line {
		@tracks.push($line); 
	}
	if ($DEBUG) {say "<loaded " ~ $FILE ~ ">"};	
}