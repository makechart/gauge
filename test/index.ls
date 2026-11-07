# gauge 的 test case ( @makechart/viewer 的 mctest )
mk = (value, max = 100) -> raw: [{value, max, unit: \KG}], binding: {value: {key: \value}, max: {key: \max}, unit: {key: \unit}}
mctest.suite do
  size: [400, 300]
  data: {half: mk(50), low: mk(12), full: mk(100), over: mk(140)}
  cases:
    * name: "half", data: \half
    * name: "low", data: \low
    * name: "full", data: \full
    * name: "over", data: \over
    * name: "update", data: \low, steps: (c) -> d = mk 80; c.set-raw d.raw, d.binding
