//#= r!!equire d3

var niceDate = function(date){
  parts = date.split('-');
  return parts[2]+"/"+parts[1]+"/"+parts[0];
}

var margin = {top: 20, right: 20, bottom: 20, left:50},
    width = 760,
    height = 300;

function switch_disable_text(disable){
  var $submit = $('.generate');
  var $dis_txt = $submit.text();
  $submit.text($submit.data('disable-with')).data('disable-with', $dis_txt).attr('disabled', disable);
}

$('.generate').click(function(){
  var params = {
      type: $('.tab-pane.active')[0].id,
      filter_month: $('#filter_month').val(),
      filter_year: $('#filter_year').val(),
      metric: $('#metric').val(),
      site_id: $('#site_id').val()
  }
  switch_disable_text(true);
  $.getJSON('/admin/stats', params, function(data){
    switch_disable_text(false);
    if(params.type == 'day')
        daily_chart(data);
    else if(params.type == 'month')
        monthly_chart(data);
  });
  return false;
});

//$('#site_id').change(function(){
//    $('#monthly_stats').slideUp();
//    $('#daily_stats').slideUp();
//});
//
//$('#filter_month').change(function(){
//    $('#daily_stats').slideUp();
//});
//$('#filter_year').change(function(){
//    $('#monthly_stats').slideUp();
//});

function monthly_chart(data){
    var barWidth = 40;
    var firstpadding = 10;

    var x = d3.scale.linear()
        .domain([0, 12])
        .range([0, width]).nice();

    var y = d3.scale.linear()
        .domain([0, d3.max(data, function(d){ return d.views; })])
        .rangeRound([height, 0]);

    var svg = d3.select("#monthly_stats").html(null).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
       .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.selectAll("rect")
       .data(data)
       .enter()
         .append("rect")
         .attr("class", "bar")
         .attr("x", function(d, index) { return x(index) + firstpadding; })
         .attr("y", function(d) { return y(d.views); })
         .attr("height", function(d) { return height - y(d.views); })
         .attr("width", barWidth);

    svg.selectAll("text")
       .data(data)
       .enter()
        .append("text")
        .attr("x", function(d, index) { return x(index) + firstpadding + barWidth; })
        .attr("y", function(d) { return y(d.views); })
        .attr("dx", -barWidth/2)
        .attr("dy", "-0.3em")
        .attr("text-anchor", "middle")
        .text(function(d) { return d.views;});

    var month_names = eval($('input[name=month_names]').val());

    svg.selectAll("text.yAxis")
       .data(data)
       .enter().append("text")
          .attr("x", function(d, index) { return x(index) + firstpadding + barWidth; })
          .attr("y", height)
          .attr("dx", -barWidth/2)
          .attr("text-anchor", "middle")
          .attr("style", "font-size: 12; font-family: Helvetica, sans-serif")
          .text(function(d, index) { return month_names[index+1]; })
          .attr("transform", "translate(0, 15)")
          .attr("class", "yAxis");

    //Draw the axis
    var xAxis = d3.svg.axis()
        .scale(x)
        .ticks(false)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append('text')
        .attr("transform", "rotate(-90)")
        .attr("y", 0 - margin.left)
        .attr("x",0 - (height / 2))
        .attr("dy", "1em")
        .style("text-anchor", "middle")
        .text($('#metric option:selected').text());

    $('#monthly_stats').prepend('<div class="pull-right">Total: <b>'+d3.sum(data, function(d){ return d.views; })+'</b></div><div>'+$('#site_id option:selected').text()+'</div>')
    .slideDown();
}

function daily_chart(data){
    var parseDate = d3.time.format("%Y-%m-%d").parse;

    var x = d3.time.scale()
        .domain(d3.extent(data, function(d) { return parseDate(d.date); }))
        .range([0, width]);

    var y = d3.scale.linear()
        .domain(d3.extent(data, function(d) { return d.views; }))
        .rangeRound([height, 0]).nice();

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom")
        .tickFormat(d3.time.format("%d/%m"));

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");

    var line = d3.svg.line()
        .x(function(d) { return x(parseDate(d.date)); })
        .y(function(d) { return y(d.views); });

    var svg = d3.select("#daily_stats").html(null).append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
      .append('text')
        .attr("transform", "rotate(-90)")
        .attr("y", 0 - margin.left)
        .attr("x",0 - (height / 2))
        .attr("dy", "1em")
        .style("text-anchor", "middle")
        .text($('#metric option:selected').text());

    svg.append("path")
        .datum(data)
        .attr("class", "line")
        .attr("d", line);

    var dots = svg.selectAll("dot")
        .data(data)
        .enter()
        .append("g")
        .attr('class', 'dot');

    dots.append('circle')
        .attr("fill", "steelblue")
        .attr("r", 3)
        .attr("cx", function(d) { return x(parseDate(d.date)); })
        .attr("cy", function(d) { return y(d.views); })

    dots.append("text")
        .attr("x", function(d) { return x(parseDate(d.date)); })
        .attr("y", function(d) { return y(d.views) - 10; })
        .attr('class', 'stats-label')
        .text(function(d) { return d.views; });

    $('#daily_stats').prepend('<div class="pull-right">Total: <b>'+d3.sum(data, function(d){ return d.views; })+'</b></div><div>'+$('#site_id option:selected').text()+'</div>')
    .slideDown();
}
