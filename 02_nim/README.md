# Nim Day #2

For this challenge, I wanted to play with template-izing everything and make 
basically a fully-inlined version of this solution.

I also avoided regexes because that would be too easy, but didn't go as deep as 
using (`std/strscans`)[https://nim-lang.org/docs/strscans.html] this time around.
I'm sure there will be other times i can play with low-level string parsing this AoC.

This was a fun challenge to watch evolve.

## retro from day 2:

* i'm still learning nim. while i'm not a fan of TDD, especially in the "write tests first" form, it can really be helpful while learning to test each component.
* this is the first time i've done file-reading in nim that wasn't just a (`staticRead/slurp`)[https://nim-lang.org/docs/system.html#slurp%2Cstring].. some thoughts:
  * i absolutely love that nim respects the 90's-interp-langs (`perl`,`ruby`,`python`,`php`) usage of `slurp` to mean `consume entire file`
  * i'm not sure if `gorge` is nim-specific or not, but slurp -> gorge makes me giggle :) 
  * iterating file lines from a string filename with 
    (`syncio.lines`)[https://nim-lang.org/docs/syncio.html#lines.i%2CFile] 
    feels a little bit too much like python in an uncomfortable way.
    * Pythonistas are fond of the term `Pythonic` for idiomatic python 
    * We should start using the term `Pythonicky` to describe the problematic
      idioms of python. This proc totally feels pythonicky. I don't like it.
      * perhaps this is because i really dislike python's `str.join(array)` 
        rather than `array.join(string)`. Python isn't unique here, but I 
        really don't like that convention.
    * this is perhaps because i've been calling it as `fn.lines`. 
      `lines fn` and `lines(fn)` may have better in this case - 
      (UFCS)[https://en.wikipedia.org/wiki/Uniform_Function_Call_Syntax] 
      is one of my favorite features of nim, and when something can be 
      expressed as `action thing`, rather than `thing.action()` or `action(thing)`, 
      i tend to prefer it (as long as it's a one-parameter function). Feels cleaner 
      and more readable.
    * i do think `lines fn` makes more sense than `fn.lines`, and kinda feels
      like an `undo` of the pythonicky. I love that nim leaves the decision of
      "what's most readable" up to the programmer, rather than the language. `UFCS` is awesome.
