# gauge 的 test case ( @makechart/viewer 的 mctest )
mk = (value, max = 100) -> raw: [{value, max, unit: \KG}], binding: {value: {key: \value}, max: {key: \max}, unit: {key: \unit}}
# 沒綁 max: 上限用 config 的 range.max ( 預設 100 )
nomax = (value) -> raw: [{value, unit: \KG}], binding: {value: {key: \value}, unit: {key: \unit}}
# 數字每格往目標靠 10%, 約 400 格才完全停下. lite 版推 anim 的時鐘, d3 版等真實時間
settle = (c, ctx) ->
  if c.anim => for i from 0 til 500 => c.anim.step 16
  else ctx.wait 9000
mctest.suite do
  size: [400, 300]
  data: {half: mk(50), low: mk(12), full: mk(100), over: mk(140), nomax: nomax(72)}
  cases:
    * name: "nomax", data: \nomax, steps: settle
    * name: "nomax-range", data: \nomax, config: {range: {max: 200}}, steps: settle
    * name: "half", data: \half, steps: settle
    * name: "low", data: \low, steps: settle
    * name: "full", data: \full, steps: settle
    * name: "over", data: \over, steps: settle
    * name: "wedge", data: \half, config: {wedge: {percent: 0.4}, pin: {stroke: \#c00, strokeWidth: 4, length: 0.6}}, steps: settle
    * name: "text", data: \half, config: {text: {number-size: 5, unit-size: 2}}, steps: settle
    * name: "palette", data: \half, config: {palette: {colors: <[#f80 #ddd]>}}, steps: settle
    * name: "update", data: \low, steps: [settle, ((c) -> d = mk 80; c.set-raw d.raw, d.binding), settle]

# lite 版才有: 指針與數字的中間格
mctest.suite do
  size: [400, 300]
  data: low: mk 12
  cases:
    * name: "anim:update-frames", data: \low
      steps:
        * settle
        * (c, ctx) ->
            d = mk 80
            c.set-raw d.raw, d.binding
            for i from 1 to 4
              c.anim.step 70
              ctx.capture "t#{i * 70}"
