## Checks

### GitHub only

- Does every project in GitHub have:
  - a yaml block
  - at least one person assigned
  - a Programme tag
  
- For every project in GitHub:
  - Have we passed latest start date?
  - Are we within 3 months of earliest start date and not yet in "Awaiting start"?
  - Have we been in a proposal phase for more than 6 months?
  - Has there been movement in a proposal phase in the last 1 month?
  
- Does every project start/end on a Monday/Friday?

### Forecast only

- Does every project have:
  - A Hut23 issue code?
  - A Client?
  
- Does every assignable person:
  - Have capacity of 40?
  - Have an email?
  
  

## Long term ideas

- `whatnow [--human | --csv | --gantt | --md] [--wide | --long]` 

- By default one year, from now, in weeks. Maybe `--from` and `--months= |
  --weeks=`

- `whatnow --check-only`

- `--self | --all` 

- `--projects | --people` `--assignments` 

- `whatnow [--use-cache=minutes | --refresh]`

- ASCII / Unicode Gantt: 
  - `***` `+++` `---` `...` `ooo` `OOO` `XXX` `###` `:::` `===` `$$$`
  - `!!!` `%%%` `^^^` `vvv` `,,,` `///` `???` `~~~` `∞∞∞` `¡¡¡` `‡‡‡`
  - `≈≈≈` `øøø` `›››` `»»»` `>>>` `ØØØ` 
  - `|Jan |Feb |Mar  | ...`

- Append-only modifications to project metadata

  Add modifications to a comment in the issue; have whatnow use the last
  modification.
  
- Placeholders in Forecast should have the same names as column headings in the
  Project Tracker.

  Furthermore, placeholders should only exist for projects with confirmed
  funding.
  
  
