# Textable

## Overview

This note provides a functional description of _tables_: rectangular arrays,
formatted as plain text. Here are some examples of tables.

This is a plain table, having $n$ rows and $m$ columns and $n \times m$ cells,
with no structure:

```
|---+---|
| a | b |
|---+---|
| c | d |
|---+---|
```

Here is a more interesting table. The cells marked `A` and `B` are groups of
adjacent cells. Furthermore, this structure extends throughout the table as
shown by the distinction between "major rules," `|`, and "minor rules," `:`.

```
|-------+-------|
|   A   |   B   |
|---+---+---+---|
| a : b | c : d |
|---+---+---+---|
| e : f | g : h |
|---+---+---+---|
```

The following table is illegal: A group must form a rectangle, so the cell
marked `A` is not a valid grouping:

```
|-------+-------|
|   A   |   B   |
|   :---+---+---|
|   : b | c : d |
|---+---+---+---|
| e : f | g : h |
|---+---+---+---|
```

Here is another illegal table. Although the cell marked `C` is a valid group, it
is not consistent with the columnar groupings of `A` and `B`. The groups must be
consistent through the rows.

```
|-------+-------|
|   A   |   B   |
|---+---+---+---|
| a : b | c : d |
|---+---+---+---|
| e :   C   : h |
|---+---+---+---|
```

However, the following table _is_ legal: The columnar grouping is consistent
throughout the rows. We don't care which rows the groups occur on.

```
|-------+-------|
|   A   |   B   |
|---+---+---+---|
|       C       |
|---+---+---+---|
| e : f | g : h |
|---+---+---+---|
```

Everything said above about columnar groups also applies to row groups. This
table is why you can't simply "group the columns; then group the rows" and be
done with it: cell A is simultaneously a column group and a row group.

```
|---+---+---+---|
| a | b : c | d |
|---+---+---+---|
| e |       | f |
|···|   A   |···|
| g |       | h |
|---+---+---+---|
| i | j : k | l |
|---+---+---+---|
```


## Partial orders and trees

A partial order is a set with a reflexive, transitive, anti-symmetric binary
relation. In this note, all partial orders will be finite. 

A tree, $T$, is a partial order having a least element (the "root")
and such that, for every $x\in T$, the set $\{y\in T\mid y\leq x\}$ is totally
ordered.

(Equivalently a tree is a directed, acyclic graph such that one element has no
parent and every other element has at most one parent. The tree in the first
definition is then the transitive closure of this one. In this view, the "arrows
point upwards, from the leaves to the root.")

For an element of a tree, $t\in T$, a child of $t$ is an element $c$ such that
$c < t$ and there is no other $c'$ where $c < c' < t$.

An ordered tree is a tree such that there is a (separate) total order on the
children of each element. Two ordered trees are isomorphic if there is an
isomorphism of their sets that preserves both the partial order and the ordering
of children.


## Definitions

Let $X$ be a partial order. A _slice_ of $X$ is a subset $S\subset X$ such that:

a. No two $s,t\in S$ are comparable (_i.e._, $S$ is an antichain); and 

b. For any $x\notin S$, there is some $s\in S$ which is comparable to $x$; and,
   for all $s_i\in S$ that are comparable to $x$, either all $x\leq s_i$ or all
   $s_i\leq s$.
   
Condition (b) says that the slice divides the partial order into three parts:
those less than the slice, those greater than the slice, and the slice.

A _tiling_ of $X$ is a slide $S\subset T$ such that every $x\in X$ is in the
upper set of at most one $s\in S$. A tiling is a slice where "the intersection
of two distinct tiles is empty."

Let $R$ and $C$ be two finite trees. The _product_, $R \times_{<} C$ is the
partial order whose underlying set is $R\times C$ and where $(r, c) \leq (r',
c')$ if and only if $r \leq r'$ and $c \leq c'$.

Note that the product is not a tree. If we think of elements of $R\times_< C$
that are pairs of leaves of $R$ and $C$ as the "cells" of the table, then cells
can end up "belonging to" multiple groups in an inconsistent way.

A _mondrian_ is an ordered tree $R$ (the "row structure") and an ordered tree
$C$ (the "column structure") together with a tiling of $R\times_< C$.


## Constructing mondrians

A table is a mondrian that has a value associated with each element of the slice. 

- Row-wise bind
- Column-wise bind
- Splicing bind




## Formatting tables

The main challenge in formatting a table is working out the widths of the
columns and the heights of the rows.

    
