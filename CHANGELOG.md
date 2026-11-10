# Change Logs

## v0.0.4

 - fix bug: without a `max` binding ( or with an empty cell ), the maximum was taken as 1, so any value above 1
   showed a full gauge. it now falls back to the new `range.max` config ( default 100 )
 - add test cases for a missing `max`


## v0.0.3

 - extend the lite base ( `@makechart/base` `lite/index.html`, no d3 ): needs `@makechart/base` >= 0.2.0
   and `@plotdb/chart` >= 3.7.0.
   transitions run on `chart.anim`, so animation can be recorded frame by frame ( `anim.manual` / `step` )
 - add test cases ( `test/index.ls`, run with `npm test` via `@makechart/viewer` )


## v0.0.2

 - fix bug: typo `citcle` appended one more circle on every render
 - explicitly extend `@makechart/base` `d3/index.html`, since it still needs d3
 - add test cases ( `test/index.ls`, run with `npm test` via `@makechart/viewer` )


## v0.0.1

init release
