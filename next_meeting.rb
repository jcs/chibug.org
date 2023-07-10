#!/usr/bin/env ruby
#
# Copyright (c) 2019 joshua stein <jcs@jcs.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

#
# i am incredibly lazy
#

require "date"
require "tempfile"

def find_next_2nd_tuesday(date)
  first = Date.parse(date.strftime("%Y-%m-01"))

  if first.wday <= 2
    # 1st of the month falls on a sunday/monday, second tuesday is 1 week after
    return first + (2 - first.wday) + 7
  else
    return first + (2 - first.wday) + (7 * 2)
  end
end

def ordinal(n)
  case n % 100
  when 11, 12, 13
    "th"
  else
    case n % 10
    when 1
     "st"
    when 2
     "nd"
    when 3
     "rd"
    else
     "th"
    end
  end
end

tues2 = nil

if ARGV[0]
  if ARGV[0].to_s.match(/^\d\d\d\d-\d\d-\d\d$/)
    tues2 = Date.parse(ARGV[0])
  else
    puts "usage: #{$0} [YYYY-mm-dd]"
    exit 1
  end
end

if !tues2
  tues2 = find_next_2nd_tuesday(Date.parse(Date.today.strftime("%Y-%m-01")))

  while tues2 < Date.today
    # assume next month
    tues2 += 28
  end
end

# don't start if git is not up-to-date and pushed
system("git", "pull", "--ff-only") || raise
system("git", "diff", "--quiet", "--exit-code", "master", "origin/master") || raise

File.open(fn = "_posts/#{tues2.strftime("%Y-%m-%d")}-meeting.md", "w+") do |f|
  f.puts <<END
---
layout: post
title: "#{tues2.strftime("%B %-d")}#{ordinal(tues2.day)} Meetup"
---

ChiBUG will be meeting on
#{tues2.strftime("%A, %B %-d")}#{ordinal(tues2.day)}, #{tues2.year}
at
6pm
at
our usual place:
[Giordano's at 1115 W. Chicago Ave. in Oak Park](https://www.google.com/maps/dir//Giordano's,+1115+Chicago+Ave,+Oak+Park,+IL+60302).

If you plan on attending, please post to the
[mailing list](https://groups.io/g/chibug)
so we can get an estimated head count.
If you change your mind or are running late, please email the mailing list so
we can organize accordingly.
END
end

while true do
  system((ENV["VISUAL"] || ENV["EDITOR"] || "/usr/bin/env vi") + " " + fn)

  puts ""
  print "(e)dit again, (c)ontinue, or ^C to abort: [c] "
  opt = STDIN.gets.to_s.strip
  if opt == "" || opt == "c"
    break
  end
end

system("git", "add", fn) || raise
system("git", "commit",
  "-m", "#{tues2.strftime("%Y-%m-%d")}: next meeting") || raise
system("git", "push") || raise

t = Tempfile.new
t.puts "Our next meetup on #{tues2.strftime("%A, %B %-d")}" +
  "#{ordinal(tues2.day)} will be at our normal "
t.puts "location starting at 6pm:"
t.puts ""
t.puts "Giordano’s at 1115 W. Chicago Ave. in Oak Park."
t.puts ""
t.puts "https://chibug.org/#{tues2.strftime("%Y/%m/%d")}/meeting"
t.puts ""
t.puts "Please reply here to the list if you plan on attending."
t.close

system(
	"mutt",
	"-s", "#{tues2.strftime("%B %-d")}#{ordinal(tues2.day)} Meeting",
	"-i", t.path,
	"chibug@groups.io"
)

File.unlink(t.path)
