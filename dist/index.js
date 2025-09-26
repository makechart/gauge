(function(){
  var mod;
  module.exports = {
    pkg: {
      name: 'gauge',
      version: '0.0.1',
      extend: {
        name: "base",
        version: "0.0.1"
      },
      dependencies: []
    },
    init: function(arg$){
      var root, context, pubsub;
      root = arg$.root, context = arg$.context, pubsub = arg$.pubsub;
      return pubsub.fire('init', {
        mod: mod({
          context: context
        })
      });
    }
  };
  mod = function(arg$){
    var context, d3, chart, ref$;
    context = arg$.context;
    d3 = context.d3, chart = context.chart;
    return {
      sample: function(){
        return {
          raw: [{
            value: Math.round(100 * Math.random()),
            max: 100,
            unit: 'KG'
          }],
          binding: {
            value: {
              key: 'value'
            },
            max: {
              key: 'max'
            },
            unit: {
              key: 'unit'
            }
          }
        };
      },
      config: (ref$ = chart.utils.config.from({
        preset: 'default'
      }), ref$.text = {
        numberSize: {
          type: 'number',
          'default': 3,
          min: 1,
          max: 10,
          step: 0.1
        },
        unitSize: {
          type: 'number',
          'default': 1,
          min: 0.5,
          max: 10,
          step: 0.1
        }
      }, ref$.wedge = {
        percent: {
          type: 'number',
          'default': 0.7,
          min: 0,
          max: 1,
          step: 0.01
        }
      }, ref$.pin = {
        stroke: {
          type: 'color',
          'default': '#000'
        },
        strokeWidth: {
          type: 'number',
          'default': 10
        },
        length: {
          type: 'number',
          'default': 0.33,
          step: 0.01,
          max: 1,
          min: 0
        }
      }, ref$),
      dimension: {
        value: {
          type: 'R',
          name: "value"
        },
        max: {
          type: 'R',
          name: "max"
        },
        unit: {
          type: 'N',
          name: "unit"
        }
      },
      init: function(){
        var tint, this$ = this;
        this.tint = tint = new chart.utils.tint();
        this.arc = d3.arc();
        this.n = Object.fromEntries(['view', 'number', 'unit'].map(function(it){
          return [it, this$.layout.getNode(it)];
        }));
        this.g = Object.fromEntries(['view', 'number', 'unit'].map(function(it){
          return [it, d3.select(this$.layout.getGroup(it))];
        }));
        return this.v = {
          number: 0,
          unit: '',
          run: 0
        };
      },
      parse: function(){},
      resize: function(){
        var ref$, w, h, b, n, x$, y$, r, this$ = this;
        ref$ = [this.box.width, this.box.height], w = ref$[0], h = ref$[1];
        b = this.layout.getBox('view');
        n = this.layout.getNode('view');
        n.style.width = b.height + "px";
        this.sizeRate = {
          number: this.cfg.text.numberSize,
          unit: this.cfg.text.unitSize
        };
        import$(this.v || (this.v = {}), {
          number: (this.data[0] || {
            value: 0
          }).value || 0,
          unit: (this.binding.value || {}).unit || (this.data[0] || {
            unit: ''
          }).unit || ''
        });
        x$ = this.n.number;
        x$.style.fontSize = this.sizeRate.number + "em";
        x$.textContent = this.v.number;
        y$ = this.n.unit;
        y$.style.fontSize = this.sizeRate.unit + "em";
        y$.textContent = this.v.unit;
        this.r = r = Object.fromEntries(['number', 'unit'].map(function(it){
          return [it, w / (this$.n[it].getBoundingClientRect().width || 1)];
        }));
        (false || !this.cfg.enlarge
          ? ['number', 'unit']
          : ['unit']).map(function(it){
          var ref$;
          return this$.r[it] = (ref$ = r[it]) < 1 ? ref$ : 1;
        });
        this.n.number.style.fontSize = this.sizeRate.number * r.number + "em";
        this.n.unit.style.fontSize = this.sizeRate.unit * r.unit + "em";
        return this.layout.update(false);
      },
      render: function(){
        var d, percent, ref$, ref1$, start, end, box, size, offset, x$, y$, z$, z1$, z2$, this$ = this;
        if (this.cfg != null && this.cfg.palette) {
          this.tint.set(this.cfg.palette.colors.map(function(it){
            return it.value || it;
          }));
        }
        d = this.data[0] || {};
        if (!((this.percent || (this.percent = {})).old != null)) {
          this.percent.old = 0;
        }
        if (this.percent.runningPin != null) {
          this.percent.old = this.percent.runningPin;
          delete this.percent.runningPin;
        }
        this.percent.cur = percent = (ref$ = (ref1$ = (d.value || 0) / (d.max || 1)) < 1 ? ref1$ : 1) > 0 ? ref$ : 0;
        start = Math.PI / 4;
        end = Math.PI * 7 / 4;
        box = this.layout.getBox('view');
        size = Math.min(box.width, box.height) / 2;
        this.arc.innerRadius(size * this.cfg.wedge.percent).outerRadius(size);
        offset = size * (1 - 1 / Math.sqrt(2)) / 2;
        x$ = this.g.view.selectAll('path.wedge').data([0, 1]);
        x$.exit().remove();
        x$.enter().append('path').attr('class', 'wedge').attr('transform', "translate(" + box.width / 2 + "," + (offset + box.height / 2) + ") rotate(180)");
        y$ = this.g.view.selectAll('path.pin').data([0]);
        y$.exit().remove();
        y$.enter().append('path').attr('class', 'pin').attr('transform', "translate(" + box.width / 2 + " " + (offset + box.height / 2) + ") rotate(" + (45 + 270 * percent) + ")").attr('d', "M0 " + size * (1 - this.cfg.pin.length) + "L0 " + size).attr('stroke-linecap', 'round');
        z$ = this.g.view.selectAll('citcle').data([0]);
        z$.exit().remove();
        z$.enter().append('circle');
        z1$ = this.g.number.selectAll('text').data([0]);
        z1$.exit().remove();
        z1$.enter().append('text');
        z2$ = this.g.unit.selectAll('text').data([0]);
        z2$.exit().remove();
        z2$.enter().append('text');
        this.g.view.selectAll('path.wedge').transition().duration(350).attr('transform', "translate(" + box.width / 2 + "," + (offset + box.height / 2) + ") rotate(180)").attrTween('d', function(d, i){
          return function(t){
            var p, angle;
            t = d3.easeCubicInOut(t);
            p = (this$.percent.cur - this$.percent.old) * t + this$.percent.old;
            angle = p * (Math.PI * 6 / 4) + Math.PI / 4;
            this$.arc.startAngle(i === 0 ? start : angle).endAngle(i === 0 ? angle : end);
            return this$.arc();
          };
        }).attr('fill', function(d, i){
          return this$.tint.get(d);
        });
        this.g.view.selectAll('path.pin').transition().duration(350).attr('d', "M0 " + size * (1 - this.cfg.pin.length) + "L0 " + size).attr('fill', 'none').attr('stroke', this.cfg.pin.stroke).attr('stroke-width', this.cfg.pin.strokeWidth).attrTween('transform', function(d){
          return function(t){
            var p;
            t = d3.easeCubicInOut(t);
            this$.percent.runningPin = p = (this$.percent.cur - this$.percent.old) * t + this$.percent.old;
            return "translate(" + box.width / 2 + " " + (offset + box.height / 2) + ") rotate(" + (45 + 270 * p) + ")";
          };
        });
        this.g.number.selectAll('text').attr('font-size', this.sizeRate.number * this.r.number + "em").attr('dominant-baseline', 'hanging').text(Math.round(this.v.run));
        this.g.unit.selectAll('text').attr('font-size', this.sizeRate.unit * this.r.unit + "em").text(function(){
          return this$.v.unit;
        }).attr('dominant-baseline', 'hanging');
        return this.start();
      },
      tick: function(){
        var this$ = this;
        return this.g.number.select('text').text(function(){
          this$.v.run = (this$.v.number - this$.v.run) * 0.1 + this$.v.run;
          if (this$.v.run === this$.v.number) {
            this$.stop();
          }
          return Math.round(this$.v.run);
        });
      }
    };
  };
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
