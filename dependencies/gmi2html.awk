#!/usr/bin/gawk -f

BEGIN{
    # Printing header!
    print "<!DOCTYPE html>\n\
<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"\" xml:lang=\"\">\n\
<head>\n\
    <meta charset=\"utf-8\" />\n\
    <style type=\"text/css\">\n\
        body{\n\
            margin:auto;\n\
            max-width:40em;\n\
            font-size: 150%;\n\
        }\n\
        code{font-family: monospace;}\n\
    </style>\n\
</head>\n\
<body>"

    # Control variables
    pre = 0
    list = 0
}

# First we change all &, < and > into &amp;, &lt; and &gt;. This will cause conflicts
# with links (=>) and quotes (>) but it will be easier to check only then than
# keep converting at each rule.
{
    gsub(/&/, "\\&amp;")
    gsub(/</, "\\&lt;")
    gsub(/>/, "\\&gt;")
}

/^```/&&(pre == 0){
    # We must close the list!
    if(list == 1){
        list = 0
        print "</ul>"
    }
    pre = 1
    printf "<pre><code>"
    next
}

/^```/&&(pre == 1){
    pre = 0
    print "</code></pre>"
    next
}

(pre == 1){
    print $0
    next
}

/\* /{
    if(list == 0){
        list = 1
        print "<ul>"
    }
    sub(/\* [ \t]*/, "")
    print "<li>"$0"</li>"
    next
}

# If the list has ended
(list == 1){
    list = 0
    print "</ul>"
}

/^---[-]*[ \t]*$/{
    print "<hr/>"
    next
}

/^[ \t]*$/{
    print "<br/>"
    next
}

/^###/{
    sub(/^#[#]*[ \t]*/, "")
    print "<h3>"$0"</h3>"
    next
}

/^##/{
    sub(/^#[#]*[ \t]*/, "")
    print "<h2>"$0"</h2>"
    next
}

/^#/{
    sub(/^#[#]*[ \t]*/, "")
    print "<h1>"$0"</h1>"
    next
}

/^&gt;/{
    sub(/^&gt;[ \t]*/, "")
    print "<blockquote><p>&gt; "$0"</p></blockquote>"
    next
}

/^=&gt;/{
    sub(/^=&gt;[ \t]*/, "")

    url=$0
    sub(/[ \t].*$/, "", url)

    text=$0
    sub(/^[^ \t]*/, "", text)
    sub(/^[ \t]*/, "", text)
    sub(/[ \t]*$/, "", text)

    # If it's a local gemini file, link to the html:
    if((url !~ /^[a-zA-Z]*:\/\//) && ((url ~ /\.gmi$/) || (url ~ /\.gemini$/))){
        sub(/\.gmi$/, ".html", url)
        sub(/\.gemini$/, ".html", url)
    }

    if(text == ""){
        text = url
    }

    print "<p><a href=\""url"\">"text"</a></p>"
    next
}

{
    print "<p>"$0"</p>"
}

END{
    # Closes open list
    if(list == 1){
        print "</ul>"
    }
    print "</body>\n</html>"
}