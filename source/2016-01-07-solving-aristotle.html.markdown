---
title: Solving "Aristotle's Number Puzzle" with Constraint Satisfaction
date: 2016/01/07
category: technology
tags: puzzles, java
published: false
---

My parents got me a puzzle for Christmas titled _Aristotle's Number Puzzle_.
The puzzle is simple: **arrange the numbers 1 through 19 pieces so that, across
the large hexagon, every row sums to 38**.

![The Puzzle, in its box](/images/2016/aristotle_puzzle.jpg)

Upon opening it, my first reaction was that it should be easy to solve this
thing with a computer. Like hell I'm going to arduiously try to do this through
trial-and-error if I can make electrons do it for me instead!

> Work smarter, not harder
> –My Mom

Although this gift was _certainly_ designed to give its recipients a devilish
couple hours of laboring, I'm far too impatient for that! (Maybe I'm just
trying too hard [to be a virtuous
programmer](http://c2.com/cgi/wiki?LazinessImpatienceHubris)...)

# The Challenge
When thinking of how to accomplish this puzzle, modelling it as a [Constraint
Satisfaction Problem][wikipedia] was my first instinct. This would conceptually
allow me to assign a variable for each of the 19 spaces, and set up some sum
constraints. With the proper library, it should only take me about 20 lines of
code to conquer this puzzle.

# Overview of Constraint Satisfaction
A constraint satisfaction problem is given in terms of three arrays (as
described [on wikipedia][wikipedia]):

1. An array of variables to solve,
2. The range for those variables' values, and
3. A set of constraints expressed in terms of those variables

TODO: summarize a bit about how the constraints are solved

# Modelling the problem
We'll need a way to model our problem as a CSP. Let's start by assigning each
hex a variable:

![Giving each hex a letter a-z](/images/2016/aristotle_problem.png)

At this point, the equations fall out pretty easily:

~~~
a + b + c         = 38
d + e + f + g     = 38
h + i + j + k + l = 38
m + n + o + p     = 38
q + r + s         = 38

a + d + h         = 38
b + e + i + m     = 38
c + f + j + n + q = 38
g + k + o + r     = 38
l + p + s         = 38

h + m + q         = 38
d + i + n + r     = 38
a + e + j + o + s = 38
b + f + k + p     = 38
c + g + l         = 38

a != b != c != d != [...] != s
~~~

If we constrain all our variables from 1 to 19, this means we'll make 15**19 =
2.2e22 attempts at maximum. That is a lot, however, we can apply mathematic
optimizations while bruteforcing to dramatically reduce the state space. [A
competing blog post solving the same
problem](http://hwiechers.blogspot.com/2013/03/solving-artitotles-number-puzzle.html)
does some formula reduction before attempting bruteforce. However, since this
is literally a toy project, I decided that the
[YAGNI](https://en.wikipedia.org/wiki/You_aren't_gonna_need_it) principle
applies here–let's see if we can bruteforce the equations without any
optimization!

# Choosing a Library
Finding a library which handles an naïvely-large state space performantly while
also allowing us to express our somewhat non-standard formulas will be a
challenge.

When trying to quickly prototype something, my goto language is **Ruby**.
Although I knew of some constraint satisfaction implementations, none were
general enough to really help me. RubyGems/Bundler use [special-purpose
dependency
solving](http://ruby-doc.org/stdlib-1.9.3/libdoc/rubygems/rdoc/Gem/DependencyList.html#method-i-why_not_ok-3F)
to evaluate a Gemfile.lock, but that's a far cry from being expressive enough
for me to re-use.

[Berkshelf](https://github.com/berkshelf/berkshelf), a reimplementation of
Ruby's Bundler for Chef cookbooks that keeps even details like the syntax of
the .lock file similar, actually originally used a different constraint solving
library: gecode. Unfortunately, [Gecode/R](http://gecoder.rubyforge.org/), a
Ruby binding to this library, only supports really old versions of Ruby and I
don't want to deal with that. So close! (By the way, Berkshelf rewrote their
constraint satisfier in pure Ruby at some point, because the native extensions
were too bothersome to install. Heh.)

Time to broaden the horizons. Searching for `[constraint satisfaction library]`
returns the Choco library, and I'm down with Java. It looks to be expressive
enough for this problem's purposes, and has good documentation.

# First Attempt at a Solution
First, let's instantiate a solver instance:

~~~ java
Solver solver = new Solver("aristotle's number puzzle");
~~~

Then, add the variables:

~~~java
// create a "fixed" variable for our answer, 38:
IntVar sum = VariableFactory.fixed(38, solver);

// create an array of 19 integer variables ranging 1 -> 19
IntVar[] vars = VariableFactory.boundedArray("A", 19, 1, 19, solver);
~~~

Next, I aliased some short names for these variables, so I could refer to them
by name instead of by their array index:

~~~java
IntVar a = vars[0];
IntVar b = vars[1];
IntVar c = vars[2];
IntVar d = vars[3];
// [...]
IntVar s = vars[18];
~~~

Then, using the "sum" constraint which accepts an arbitrary number of variables
in an `IntVar[]` array, set up the constraints:

~~~java
// left -> right
solver.post(IntConstraintFactory.sum(new IntVar[]{a, b, c}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{d, e, f, g}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{h, i, j, k, l}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{m, n, o, p}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{q, r, s}, sum));

// top -> bottom left
solver.post(IntConstraintFactory.sum(new IntVar[]{a, d, h}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{b, e, i, m}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{c, f, j, n, q}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{g, k, o, r}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{l, p, s}, sum));

// top -> bottom right
solver.post(IntConstraintFactory.sum(new IntVar[]{h, m, q}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{d, i, n, r}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{a, e, j, o, s}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{b, f, k, p}, sum));
solver.post(IntConstraintFactory.sum(new IntVar[]{c, g, l}, sum));
~~~

We only need one more thing: the constraint that no two variables should be
equal. Conveniently, this is supported by the Choco library:

~~~java
solver.post(IntConstraintFactory.alldifferent(vars));
~~~

With those constraints, and a bit more boilerplate, Choco is able to solve the
problem remarkably quickly: about 500ms on my Macbook Air. Since it took only
137 backtracks (according to the detailed statistics), I assume this library is
heavily optimizing the input equations. Cool!

I daresay that my _first_ attempt at a solution will also be my _last_!

Here's the solution:

![The solution](/images/2016/aristotle_solution.png)

All the code for this silly endeavor [is on Github
here](https://github.com/tdooner/aristotle-solver-csp).

[wikipedia]: https://en.wikipedia.org/wiki/Constraint_satisfaction_problem
