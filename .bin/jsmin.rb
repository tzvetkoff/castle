#!/usr/bin/env ruby

EOF = -1
$theA = ""
$theB = ""

# isAlphanum -- return true if the character is a letter, digit, underscore,
# dollar sign, or non-ASCII character
def isAlphanum(c)
   return false if !c || c == EOF
   return ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
           (c >= 'A' && c <= 'Z') || c == '_' || c == '$' ||
           c == '\\' || (c[0].class == String ? c[0].ord : c[0]) > 126)
end

# get -- return the next character from stdin. Watch out for lookahead. If
# the character is a control character, translate it to a space or linefeed.
def get()
  c = $stdin.getc
  return EOF if(!c)
  c = c.chr
  return c if (c >= " " || c == "\n" || c.unpack("c") == EOF)
  return "\n" if (c == "\r")
  return " "
end

# Get the next character without getting it.
def peek()
    lookaheadChar = $stdin.getc
    $stdin.ungetc(lookaheadChar)
    return lookaheadChar.chr
end

# mynext -- get the next character, excluding comments.
# peek() is used to see if a '/' is followed by a '/' or '*'.
def mynext()
    c = get
    if (c == "/")
        if(peek == "/")
            while(true)
                c = get
                if (c <= "\n")
                return c
                end
            end
        end
        if(peek == "*")
            get
            while(true)
                case get
                when "*"
                   if (peek == "/")
                        get
                        return " "
                    end
                when EOF
                    raise "Unterminated comment"
                end
            end
        end
    end
    return c
end


# action -- do something! What you do is determined by the argument: 1
# Output A. Copy B to A. Get the next B. 2 Copy B to A. Get the next B.
# (Delete A). 3 Get the next B. (Delete B). action treats a string as a
# single character. Wow! action recognizes a regular expression if it is
# preceded by ( or , or =.
def action(a)
    if(a==1)
        $stdout.write $theA
    end
    if(a==1 || a==2)
        $theA = $theB
        if ($theA == "\'" || $theA == "\"")
            while (true)
                $stdout.write $theA
                $theA = get
                break if ($theA == $theB)
                raise "Unterminated string literal" if ($theA <= "\n")
                if ($theA == "\\")
                    $stdout.write $theA
                    $theA = get
                end
            end
        end
    end
    if(a==1 || a==2 || a==3)
        $theB = mynext
        if ($theB == "/" && ($theA == "(" || $theA == "," || $theA == "=" ||
                             $theA == ":" || $theA == "[" || $theA == "!" ||
                             $theA == "&" || $theA == "|" || $theA == "?" ||
                             $theA == "{" || $theA == "}" || $theA == ";" ||
                             $theA == "\n"))
            $stdout.write $theA
            $stdout.write $theB
            while (true)
                $theA = get
                if ($theA == "/")
                    break
                elsif ($theA == "\\")
                    $stdout.write $theA
                    $theA = get
                elsif ($theA <= "\n")
                    raise "Unterminated RegExp Literal"
                end
                $stdout.write $theA
            end
            $theB = mynext
        end
    end
end

# jsmin -- Copy the input to the output, deleting the characters which are
# insignificant to JavaScript. Comments will be removed. Tabs will be
# replaced with spaces. Carriage returns will be replaced with linefeeds.
# Most spaces and linefeeds will be removed.
def jsmin
    $theA = "\n"
    action(3)
    while ($theA != EOF)
        case $theA
        when " "
            if (isAlphanum($theB))
                action(1)
            else
                action(2)
            end
        when "\n"
            case ($theB)
            when "{","[","(","+","-"
                action(1)
            when " "
                action(3)
            else
                if (isAlphanum($theB))
                    action(1)
                else
                    action(2)
                end
            end
        else
            case ($theB)
            when " "
                if (isAlphanum($theA))
                    action(1)
                else
                    action(3)
                end
            when "\n"
                case ($theA)
                when "}","]",")","+","-","\"","\\", "'", '"'
                    action(1)
                else
                    if (isAlphanum($theA))
                        action(1)
                    else
                        action(3)
                    end
                end
            else
                action(1)
            end
        end
    end
end

ARGV.each do |anArg|
    $stdout.write "// #{anArg}\n"
end

jsmin
