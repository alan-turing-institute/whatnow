# Tables

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


## Definitions

A partial order is a set with a reflexive, transitive, anti-symmetric binary
relation. A tree, $T$, is a partial order having a least element (the "root")
and such that, for every $x\in T$, the set $\{y\in T\mid y\leq x\}$ is totally
ordered.

(Equivalently a tree is a directed, acyclic graph such that one element has no
children and every other element has at most one child. The tree in the first
definition is then the transitive closure of this one. In this view, the "arrows
point upwards, from the leaves to the root.")

Let $X$ be a partial order. A _slice_ of $X$ is a subset $S\subset X$
such that:

a. No two $s,t\in S$ are comparable (ie, $S$ is an antichain); and 

b. For any $x\notin S$, there is some $s\in S$ which is comparable to $x$; and,
   for all $s_i\in S$ that are comparable to $x$, either $x\leq s_i$ or $s_i\leq
   s$.
   
Condition (b) says that the slice divides the partial order into two three
parts: those less than the slice, those greater than the slice, and the slice.

A _tiling_ of $X$ is a subset $S\subset X$, such that:

a. $S$ is a slice of $X$; and

b. Every $x\in X$ is in the upper set of at most one $s\in S$.





Let $R$ and $C$ be two finite trees. The _product_, $R \times_{<} C$ is the
partial order whose underlying set is $R\times C$ and where $(r, c) \leq (r',
c')$ if and only if $r \leq r'$ and $c \leq c'$. 

Note that the product is not a tree. If we think of elements of $R\times_< C$
that are pairs of leaves of $R$ and $C$ as the "cells" of the table, then cells
can end up "belonging to" multiple groups in an inconsistent way. We need to
choose particular ways of grouping cells: that is, a consistent subset of
$R\times_< C$.

Let $t\in T$ be a node in a 

A _mondrian_ is a pair of structures, $R$ and $C$ (for 'row' and 'column'),
together with a partial order $T\subset R\times C$ such that: 

1. The order on $T$ is that induced by $R\times_< C$;
2. For every $(r, c)\in R\times_< C$, the set of nodes $(s, t)\in T$ such that
   $(s, t) \leq (r, c)$ is totally ordered;
3. For every node $t\in T$

Condition (2) prohibits "double-counting" of cells in the table: if a cell is
part of more than one group in $T$, then one of those groups must include the
other. (It also implies that $T$ is a tree.) Condition (3) says that there are
no "holes:" every group is covered by its children.




