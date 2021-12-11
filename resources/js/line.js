var margin = {top: 20, right: 50, bottom: 30, left: 100}
var parseTime = d3.timeParse("%m/%d/%Y");


d3.csv("https://raw.githubusercontent.com/s10singh97/Influence_COVID/main/resources/data/vaccine.csv")
  .then(function(data){
    const arr = []
    for(var i = 0; i < data.length; i++){
      arr.push(data[i]);
    }
  
    state_name = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida",
     "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", 
     "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
     "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", 
     "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", 
     "West Virginia", "Wisconsin", "Wyoming"];

    state_abb = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", 
     "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", 
     "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"];

    var input;
    
    select = document.getElementById("selected_state");
  
    for (const val of state_name)
    {
        var option = document.createElement("option");
        option.value = val;
        option.text = val.charAt(0).toUpperCase() + val.slice(1);
        select.appendChild(option);
    }

    arr.forEach(function(row){
      row.Date = parseTime(row.Date)
    });

    $('select').on('change', function (e) {
      
      d3.select("g").remove();
      var svg = d3.select("svg")
      var g = svg.append("g").attr("transform", `translate(${margin.left}, ${margin.top})`);
      var width =  +svg.attr("width") - margin.left - margin.right;
      var height = +svg.attr("height") - margin.top - margin.bottom;

      var optionSelected = $("option:selected", this);
      input = this.value;
  
      let ind = state_name.indexOf(input);
      input_code = state_abb[ind];

      state_rows = arr.filter(function(item){
        return item.Location == input_code;
      });
  
      var xScale = d3.scaleTime().range([0, width]);
      var yScale = d3.scaleLinear() 
        .range([height, 0]);

      var yAxis = d3.axisLeft().scale(yScale).ticks(10);

      xScale
        .domain(d3.extent(state_rows, d => d.Date));
      yScale
        .domain(d3.extent(state_rows, d => Math.max(d.Administered_Janssen, d.Administered_Moderna, d.Administered_Pfizer)));

      // Administered Janssen
      g.append("g")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(xScale).ticks(10));
      g.append("g")
        .call(d3.axisLeft(yScale))
  
      var line = d3.line()
        .x(d => xScale(d.Date))
        .y(d => yScale(d.Administered_Janssen));
  
      g.append("path")
        .datum(state_rows)
        .attr("class", "line_janssen")
        .attr("fill", "none")
        .attr("fill-opacity", 0)
        .attr("stroke-opacity", 0)
        .transition()
        .duration(1000)
        .attr("fill-opacity", 1)
        .attr("stroke-opacity", 1)
        .attr("d", line);

      // Administered Moderna
      g.append("g")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(xScale).ticks(10));
      g.append("g")
        .call(d3.axisLeft(yScale))
  
      var line = d3.line()
        .x(d => xScale(d.Date))
        .y(d => yScale(d.Administered_Moderna));
  
      g.append("path")
        .datum(state_rows)
        .attr("class", "line_moderna")
        .attr("fill", "none")
        .attr("fill-opacity", 0)
        .attr("stroke-opacity", 0)
        .transition()
        .duration(1000)
        .attr("fill-opacity", 1)
        .attr("stroke-opacity", 1)
        .attr("d", line);

      // Administered Pfizer
      g.append("g")
        .attr("transform", `translate(0, ${height})`)
        .call(d3.axisBottom(xScale).ticks(10));
      g.append("g")
        .call(d3.axisLeft(yScale))
  
      var line = d3.line()
        .x(d => xScale(d.Date))
        .y(d => yScale(d.Administered_Pfizer));
  
      g.append("path")
        .datum(state_rows)
        .attr("class", "line_pfizer")
        .attr("fill", "none")
        .attr("fill-opacity", 0)
        .attr("stroke-opacity", 0)
        .transition()
        .duration(1000)
        .attr("fill-opacity", 1)
        .attr("stroke-opacity", 1)
        .attr("d", line);
      
    });

  })