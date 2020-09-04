# Whatnow

What am I supposed to be working on at the moment? How are my projects going?
This is a collection of scripts for answering those questions, assuming you work
in REG at the Turing.

## Background

REG uses three systems for project management.

1. GitHub issues. Each of our projects has a unique GitHub issue in the Hut23
   repo. We organise these into three GitHub “projects” (like kanban boards),
   which themselves are organised by the phase of the project.
   
2. A commercial system, Harvest, which we use for time tracking.

3. An add-on to Harvest, called Forecast, which we use for scheduling.

Whatnow collects data from all three and reports summary information for
specified projects (usually those for which the current user is part of the
project, project lead, or Programme lead).


## Usage (vapourware)

### Typical questions

1. What projects am I supposed to be working on?

2. For projects of interest, 
   - are timesheets up to date?
   - are we on track?
   - where are we?

- Projects of interest are:
   - projects where I am listed as project lead on GitHub
   - projects I'm working on
   - projects my reports are working on

3. Are all allocations to projects with issue numbers?

4. Has a person spent more than 6 months on a project? 


## Design notes

### Forecast API

#### Entities

1. Projects

2. Clients

3. People

4. Schedule
