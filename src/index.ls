module.exports =
  pkg:
    name: 'gauge', version: '0.0.1'
    # lite: 不帶 d3 的 base. 補間改用 chart.anim, 可以逐格錄影 ( 見 @plotdb/chart utils/anim )
    extend: {name: "@makechart/base", path: "lite/index.html"}
    dependencies: []

  init: ({root, context, pubsub}) ->
    pubsub.fire \init, mod: mod {context}

mod = ({context}) ->
  {chart} = context
  {shape, anim: {join, ease}} = chart.utils
  sample: ->
    raw: [{value: Math.round(100 * Math.random!), max: 100, unit: \KG}]
    binding:
      value: {key: \value}
      max: {key: \max}
      unit: {key: \unit}
  config: chart.utils.config.from({
    preset: \default
  }) <<<
    text:
      #enlarge: type: \boolean, default: false
      number-size: type: \number, default: 3, min: 1, max: 10, step: 0.1
      unit-size: type: \number, default: 1, min: 0.5, max: 10, step: 0.1
    wedge:
      percent: type: \number, default: 0.7, min: 0, max: 1, step: 0.01
    pin:
      stroke: type: \color, default: \#000
      strokeWidth: type: \number, default: 10
      length: type: \number, default: 0.33, step: 0.01, max: 1, min: 0
  dimension:
    value: {type: \R, name: "value"}
    max: {type: \R, name: "max"}
    unit: {type: \N, name: "unit"}
  init: ->
    @tint = tint = new chart.utils.tint!
    @arc = shape.arc!
    @n = Object.fromEntries <[view number unit]>.map ~> [it, @layout.get-node(it)]
    @g = Object.fromEntries <[view number unit]>.map ~> [it, @layout.get-group(it)]
    @v = number: 0, unit: '', run: 0

  parse: ->

  resize: ->
    [w,h] = [@box.width, @box.height]
    b = @layout.get-box \view
    n = @layout.get-node \view
    n.style.width = "#{b.height}px"

    @size-rate = number: @cfg.text.number-size, unit: @cfg.text.unit-size
    @{}v <<< do
      number: (@data.0 or {value: 0}).value or 0
      unit: (@binding.value or {}).unit or (@data.0 or {unit: ''}).unit or ''
    @n.number
      ..style.fontSize = "#{@size-rate.number}em"
      ..textContent = @v.number
    @n.unit
      ..style.fontSize = "#{@size-rate.unit}em"
      ..textContent = @v.unit
    @r = r = Object.fromEntries <[number unit]>.map ~> [it, (w / (@n[it]getBoundingClientRect!width or 1))]
    (if false or !@cfg.enlarge => <[number unit]> else <[unit]>).map ~> @r[it] = (r[it] <? 1)
    @n.number.style.fontSize = "#{@size-rate.number * r.number}em"
    @n.unit.style.fontSize = "#{@size-rate.unit * r.unit}em"

    @layout.update false

  render: ->
    if @cfg? and @cfg.palette => @tint.set(@cfg.palette.colors.map -> it.value or it)
    d = @data.0 or {}
    if !(@{}percent.old?) => @percent.old = 0
    if @percent.running-pin? =>
      @percent.old = @percent.running-pin
      delete @percent.running-pin
    @percent.cur = percent = ((d.value or 0) / (d.max or 1)) <? 1 >? 0
    start = Math.PI / 4
    end = Math.PI * 7 / 4
    box = @layout.get-box \view
    size = (Math.min box.width, box.height) / 2
    @arc
      .innerRadius(size * @cfg.wedge.percent)
      .outerRadius size

    offset = size * (1 - (1/Math.sqrt(2))) / 2

    tween = (n, attrs) ~> @anim.tween n, attrs, {duration: 350}
    one = (root, tag, cls, data) ->
      j = join {root, tag, cls, data}
      j.exit.map -> it.remove!
      j
    wj = one @g.view, \path, \wedge, [0,1]
    wj.enter.map ->
      it.setAttribute \transform, "translate(#{box.width/2},#{offset + box.height/2}) rotate(180)"
    pj = one @g.view, \path, \pin, [0]
    pj.enter.map ~>
      it.setAttribute \transform, "translate(#{box.width/2} #{offset + box.height/2}) rotate(#{45 + (270 * percent)})"
      it.setAttribute \d, "M0 #{size * (1 - @cfg.pin.length)}L0 #{size}"
      it.setAttribute \stroke-linecap, \round
    one @g.view, \circle, null, [0]
    tn = one(@g.number, \text, null, [0]).nodes.0
    tu = one(@g.unit, \text, null, [0]).nodes.0

    # 補間函式拿到的 t 已經套過一次 ease, 這裡再套一次 ( 同 d3 版 )
    wj.nodes.map (n, i) ~>
      tween n, do
        transform: "translate(#{box.width/2},#{offset + box.height/2}) rotate(180)"
        d: (t) ~>
          t = ease.cubic-in-out t
          p = (@percent.cur - @percent.old) * t + @percent.old
          angle = p * ( Math.PI * 6 / 4 ) + Math.PI / 4
          @arc
            .startAngle if i == 0 => start else angle
            .endAngle  if i == 0 => angle else end
          @arc!
        fill: @tint.get n.__data__

    pj.nodes.map (n) ~>
      tween n, do
        d: "M0 #{size * (1 - @cfg.pin.length)}L0 #{size}"
        fill: \none
        stroke: @cfg.pin.stroke
        "stroke-width": @cfg.pin.strokeWidth
        transform: (t) ~>
          t = ease.cubic-in-out t
          @percent.running-pin = p = (@percent.cur - @percent.old) * t + @percent.old
          "translate(#{box.width/2} #{offset + box.height/2}) rotate(#{45 + (270 * p)})"

    tn
      ..setAttribute \font-size, "#{@size-rate.number * @r.number}em"
      ..setAttribute \dominant-baseline, \hanging
      ..textContent = Math.round(@v.run)
    tu
      ..setAttribute \font-size, "#{@size-rate.unit * @r.unit}em"
      ..textContent = @v.unit
      ..setAttribute \dominant-baseline, \hanging
    @start!

  tick: ->
    # 每格往目標靠 10% ( 以格數計, 錄影時跟著 anim 的 step 走 )
    @v.run = (@v.number - @v.run) * 0.1 + @v.run
    if @v.run == @v.number => @stop!
    if (n = @g.number.querySelector \text) => n.textContent = Math.round(@v.run)
