# Blox

A small framework for implementing Ruby DSLs.

Ruby's syntax, dynamic nature and use of blocks makes it easy to
create domain specific languages.

Blox allows you to focus on implementing the functionality of your
language, and takes care of the bookkeeping job of creating and
walking abstract syntax trees.

## Usage

You define one class for each of the words in your language.  This
class is used for 3 things: first, it is used by blox to generate the
function for that word; second, its instances are used to make up the
AST; and finally, methods of these classes are used to walk the AST.

Blox `create_language` generates a function for each of these classes
and injects these functions into a module -- this module is your
language, and it can then be included into any class that wants to use
your DSL.

## Examples

Look in the samples for examples -- see the `ast/` demo for a trivial
example, and the `webservice/` demo for a slightly less trivial one.
