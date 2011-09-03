//= require d3
//= require d3.layout
//= require d3.geom

(function( $ ){
	$.fn.tiesGraph = function( data ) {
		//TODO: better handling of width and height
		var w = 860,
                    h = 500,
                    fill = d3.scale.category20();

                var vis = d3.select(this.selector)
                            .append("svg:svg")
                            .attr("width", w)
                            .attr("height", h);

                var force = d3.layout.force()
                              .charge(-120)
                              .linkDistance(40)
                              .nodes(data.nodes)
                              .links(data.links)
                              .size([w, h])
                              .start();

                var link = vis.selectAll("line.link")
                              .data(data.links)
                              .enter().append("svg:line")
                              .attr("class", "link")
                              .style("stroke-width", function(d) { return Math.sqrt(d.value); })
                              .attr("x1", function(d) { return d.source.x; })
                              .attr("y1", function(d) { return d.source.y; })
                              .attr("x2", function(d) { return d.target.x; })
                              .attr("y2", function(d) { return d.target.y; });

                var node = vis.selectAll("g.node")
                              .data(data.nodes)
                              .enter().append("svg:g")
                              .attr("class", "node")
                              .call(force.drag);

		node.append("svg:image")
                    .attr("class", "circle")
		    .attr("xlink:href", function(d) { return d.logo; })
                    .attr("x", "-10px")
                    .attr("y", "-10px")
                    .attr("width", "20px")
                    .attr("height", "20px");

                node.append("svg:title")
                    .text(function(d) { return d.name; });

                vis.style("opacity", 1e-6)
                   .transition()
                   .duration(1000)
                   .style("opacity", 1);

                force.on("tick", function() {
                       link.attr("x1", function(d) { return d.source.x; })
                           .attr("y1", function(d) { return d.source.y; })
                           .attr("x2", function(d) { return d.target.x; })
                           .attr("y2", function(d) { return d.target.y; });

                       node.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
                });
        };
})( jQuery );

