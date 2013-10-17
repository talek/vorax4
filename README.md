# Vorax, an Oracle IDE for Geeks

Hi guys! This is the next major version of Vorax. It's in an early
stage, I know, but is ready for testing. So if you are willing to 
contribute or to test this beta version, you are very welcome to
do so.

What we have so far:

* An improved cancel operation for an executing statement.
* The compressed output is now smarter and the user is prompted 
for substitution variables even in this mode. In addition, a new 
"pagezip" mode was added, which provides compression on the
page level (by page we mean what is configured by "set pagesize"
SqlPlus command).
* A better/faster code completion.
* Code folding for PLSQL packages.
* Connection profiles management
* Support for PL/SQL editing/compilation.
* Database explorer tree
* Search into Oracle documentation feature

## Demo

Just have a look here: http://youtu.be/DInsKTZS028

## Installation

* ensure you have ruby1.9.3 or ruby2.0
* vim 7.3 compiled with ruby support
* install vorax.gem to get the dependent gems

```
gem install vorax --no-rdoc --no-ri
```

* ensure you have a valid Oracle client with sqlplus available
* install Vorax vim plugin: manually, pathogen, vundle... it's up
to you.

For details don't hesitate to have a look at the project wiki.

