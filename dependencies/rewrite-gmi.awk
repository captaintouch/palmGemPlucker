#!/usr/bin/awk -f
# Converts all links in a Gemtext file to a local form and ensure they have a file extension, e.g.:
#     => gemini://gemini.circumlunar.space/docs Title Text Here
# is turned into:
#     => docs.gmi Title Text Here
# Usage: awk -f rewrite-gmi.awk <gemtext>

/^=>/ {
	# run `basename <url>` shell command and get output
	cmd = "basename " $2;
	cmd | getline local;

	# clear "=> <url>" from $0
	$1 = "";
	$2 = "";

	# add a .gmi extension if the path doesn't have any extension
	if (local !~ /.*\..+$/) {
		ext = ".gmi";
	} else {
		ext = "";
	}

	# write out the modified line
	printf("=> %s%s %s\n", local, ext, $0);

	next;
}

# otherwise print the line unmodified
{ print; }
