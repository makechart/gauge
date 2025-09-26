module.exports =
  pkg:
    name: 'gauge', version: '0.0.1'
    extend: {name: "base", version: "0.0.1"}
    dependencies: []

  init: ({root, context, pubsub}) ->
    pubsub.fire \init, mod: mod {context}

mod = ({context}) ->
  {d3,chart} = context
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
    @arc = d3.arc!
    @n = Object.fromEntries <[view number unit]>.map ~> [it, @layout.get-node(it)]
    @g = Object.fromEntries <[view number unit]>.map ~> [it, d3.select(@layout.get-group(it))]
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

    @g.view.selectAll \path.wedge .data [0,1]
      ..exit!remove!
      ..enter!append \path .attr \class, \wedge
        .attr \transform, "translate(#{box.width/2},#{offset + box.height/2}) rotate(180)"
    @g.view.selectAll \path.pin .data [0]
      ..exit!remove!
      ..enter!append \path .attr \class, \pin
        .attr \transform, "translate(#{box.width/2} #{offset + box.height/2}) rotate(#{45 + (270 * percent)})"
        .attr \d, "M0 #{size * (1 - @cfg.pin.length)}L0 #{size}"
        .attr \stroke-linecap, \round
    @g.view.selectAll \citcle .data [0]
      ..exit!remove!
      ..enter!append \circle
    @g.number.selectAll \text .data [0]
      ..exit!remove!
      ..enter!append \text
    @g.unit.selectAll \text .data [0]
      ..exit!remove!
      ..enter!append \text

    @g.view.selectAll \path.wedge
      .transition!duration 350
      .attr \transform, "translate(#{box.width/2},#{offset + box.height/2}) rotate(180)"
      .attrTween \d, (d,i) ~>
        (t) ~>
          t = d3.easeCubicInOut t
          p = (@percent.cur - @percent.old) * t + @percent.old
          angle = p * ( Math.PI * 6 / 4 ) + Math.PI / 4
          @arc
            .startAngle if i == 0 => start else angle
            .endAngle  if i == 0 => angle else end
          @arc!
      .attr \fill, (d,i) ~> @tint.get d

    @g.view.selectAll \path.pin
      .transition!duration 350
      .attr \d, "M0 #{size * (1 - @cfg.pin.length)}L0 #{size}"
      .attr \fill, \none
      .attr \stroke, @cfg.pin.stroke
      .attr \stroke-width, @cfg.pin.strokeWidth
      .attrTween \transform, (d) ~> (t) ~>
        t = d3.easeCubicInOut t
        @percent.running-pin = p = (@percent.cur - @percent.old) * t + @percent.old
        "translate(#{box.width/2} #{offset + box.height/2}) rotate(#{45 + (270 * p)})"

    @g.number.selectAll \text
      .attr \font-size, "#{@size-rate.number * @r.number}em"
      .attr \dominant-baseline, \hanging
      .text Math.round(@v.run)

    @g.unit.selectAll \text
      .attr \font-size, "#{@size-rate.unit * @r.unit}em"
      .text ~> @v.unit
      .attr \dominant-baseline, \hanging
    @start!

  tick: ->
    @g.number.select \text .text ~>
      @v.run = (@v.number - @v.run) * 0.1 + @v.run
      if @v.run == @v.number => @stop!
      return Math.round(@v.run)
