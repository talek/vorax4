# Vorax, an Oracle IDE for Geeks

Hi guys! This is the next major version of Vorax. It's in an early
stage, I know, but is ready for testing. So if you are willing to 
contribute or to test this beta version, you are very welcomed to
do so.

What we have so far:

* All the ruby code is now provided as a gem and it's not mixed
anymore with Vorax vim distribution. Another advantage is that
the dependecies with other packages/gems are automatically 
installed.
* An improved cancel operation for an executing statement.
* The compressed output is now smarter and the user is prompted 
for substitution variables even in this mode. In addition, a new 
"pagezip" mode was added, which provides compression on the
page level (by page we mean what is configured by "set pagesize"
SqlPlus command).
* A better/faster code completion: completion for WITH references
and the package spec is parsed now in order to get other valuable
data, like: constants, type, cursors, exceptions, global 
variables. The next step is to parse the package body as well and
to provide context sensitive completion items like local variables,
private functions etc. Likewise, Vorax completion is now aware
of standard Oracle functions like: INSTR(), ROUND() etc.
* Code folding for PLSQL packages.

## Demo

Just have a look here: http://youtu.be/DInsKTZS028

## Installation

1. ensure you have ruby1.9.3
2. vim 7.3
3. install vorax.gem

```
gem install vorax --no-rdoc --no-ri
```

4. ensure you have a valid Oracle client with sqlplus available
5. install Vorax vim plugin: manually, pathogen, vundle... it's up
to you.

