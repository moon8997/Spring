<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<style type="text/css">
	.highcharts-figure,
	.highcharts-data-table table {
	    min-width: 320px;
	    max-width: 800px;
	    margin: 1em auto;
	}
	
	.highcharts-data-table table {
	    font-family: Verdana, sans-serif;
	    border-collapse: collapse;
	    border: 1px solid #ebebeb;
	    margin: 10px auto;
	    text-align: center;
	    width: 100%;
	    max-width: 500px;
	}
	
	.highcharts-data-table caption {
	    padding: 1em 0;
	    font-size: 1.2em;
	    color: #555;
	}
	
	.highcharts-data-table th {
	    font-weight: 600;
	    padding: 0.5em;
	}
	
	.highcharts-data-table td,
	.highcharts-data-table th,
	.highcharts-data-table caption {
	    padding: 0.5em;
	}
	
	.highcharts-data-table thead tr,
	.highcharts-data-table tr:nth-child(even) {
	    background: #f8f8f8;
	}
	
	.highcharts-data-table tr:hover {
	    background: #f1f7ff;
	}
	
	input[type="number"] {
	    min-width: 50px;
	}
	
	div#table_container table {width: 100%}
	div#table_container th, div#table_container td {border: solid 1px gray; text-align: center;} 
	div#table_container th {background-color: #595959; color: white;}
</style>

<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
<script src="https://code.highcharts.com/modules/export-data.js"></script>
<script src="https://code.highcharts.com/modules/accessibility.js"></script>

<script src="https://code.highcharts.com/modules/data.js"></script>
<script src="https://code.highcharts.com/modules/drilldown.js"></script>

<div style="display: flex;">	
<div style="width: 80%; min-height: 1100px; margin:auto; ">

	<h2 style="margin: 50px 0;">HR 사원 통계정보(차트)</h2>
	
	<form name="searchFrm" style="margin: 20px 0 50px 0; ">
		<select name="searchType" id="searchType" style="height: 30px;">
			<option value="">통계선택하세요</option>
			<option value="deptname">부서명별 인원통계</option>
			<option value="gender">성별 인원통계</option>
			<option value="deptnameGender">부서명별 성별 인원통계</option>
		</select>
	</form>
	
	<div id="chart_container"></div>
	<div id="table_container" style="margin: 40px 0 0 0;"></div>

</div>
</div>


<script type="text/javascript">
  $(document).ready(function(){
	  
	  $("select#searchType").bind("change", function(){
		  func_choice($(this).val());
		  // $(this).val() 은 "" 또는 "deptname" 또는 "gender" 또는 "deptnameGender" 이다. 
		  
	  });
	  
  });// end of $(document).ready(function(){})-----------------------------

  
  // Function Declaration
  function func_choice(searchType) {
	  
	  switch (searchType) {
		case "": // 통계선택하세요 를 선택한 경우
			$("div#chart_container").empty();
			$("div#table_container").empty();
			$("div.highcharts-data-table").empty();
						
			break;
	
			
		case "deptname": // 부서명별 인원통계 를 선택한 경우 
		
		    $.ajax({
		    	url:"<%= request.getContextPath()%>/chart/employeeCntByDeptname.action", 
		    	dataType:"JSON",
                success:function(json){
                	
                    let resultArr = [];
                    
                    for(let i=0; i<json.length; i++) {
                    	
                    	let obj;
                    	
                    	if(i==0) {
                    		obj = {
                                    name: json[i].department_name,
                                    y: Number(json[i].percentage),
                                    sliced: true,
                                    selected: true
                                  };
                    	}
                    	else {
                    		obj = {
                                    name: json[i].department_name,
                                    y: Number(json[i].percentage)
                                  };
                    	}
                    	
                    	resultArr.push(obj); // 배열속에 객체를 넣기
                    		
                    }// end of for---------------------
                	
                 ////////////////////////////////////////////////////////////
                	Highcharts.chart('chart_container', {
					    chart: {
					        plotBackgroundColor: null,
					        plotBorderWidth: null,
					        plotShadow: false,
					        type: 'pie'
					    },
					    title: {
					        text: '우리회사 부서명별 인원통계'
					    },
					    tooltip: {
					        pointFormat: '{series.name}: <b>{point.percentage:.2f}%</b>'
					    },
					    accessibility: {
					        point: {
					            valueSuffix: '%'
					        }
					    },
					    plotOptions: {
					        pie: {
					            allowPointSelect: true,
					            cursor: 'pointer',
					            dataLabels: {
					                enabled: true,
					                format: '<b>{point.name}</b>: {point.percentage:.2f} %'
					            }
					        }
					    },
					    series: [{
					        name: '인원비율',
					        colorByPoint: true,
					        data: resultArr
					    }]
					});
                 ////////////////////////////////////////////////////////////
                 
	                 let html = "<table>";
	                     html += "<tr>" +
	                                "<th>부서명</th>" +
	                                "<th>인원수</th>" +
	                                "<th>퍼센티지</th>" +
	                             "</tr>";
	                             
	                 $.each(json, function(index, item){
	                	 html += "<tr>" +
				                     "<td>"+ item.department_name +"</td>" +
				                     "<td>"+ item.cnt +"</td>" +
				                     "<td>"+ Number(item.percentage) +"</td>" +
				                 "</tr>";
	                 });
	                 
	                 html += "</table>";
	                 
	                 $("div#table_container").html(html);
                },
                error: function(request, status, error){
					alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
				}
		    });
		
			break;
			
			
		case "gender": // 성별 인원통계 를 선택한 경우  
			
		$.ajax({
		    	url:"<%= request.getContextPath()%>/chart/employeeCntByGender.action", 
		    	dataType:"JSON",
                success:function(json){
                	
                    let resultArr = [];
                    
                    for(let i=0; i<json.length; i++) {
                    	
                    	let obj;
                    	
                    	if(i==0) {
                    		obj = {
                                    name: json[i].gender,
                                    y: Number(json[i].percentage),
                                    sliced: true,
                                    selected: true
                                  };
                    	}
                    	else {
                    		obj = {
                                    name: json[i].gender,
                                    y: Number(json[i].percentage)
                                  };
                    	}
                    	
                    	resultArr.push(obj); // 배열속에 객체를 넣기
                    		
                    }// end of for---------------------
                	
                 ////////////////////////////////////////////////////////////
                	Highcharts.chart('chart_container', {
					    chart: {
					        plotBackgroundColor: null,
					        plotBorderWidth: null,
					        plotShadow: false,
					        type: 'pie'
					    },
					    title: {
					        text: '우리회사 남녀별 인원통계'
					    },
					    tooltip: {
					        pointFormat: '{series.name}: <b>{point.percentage:.2f}%</b>'
					    },
					    accessibility: {
					        point: {
					            valueSuffix: '%'
					        }
					    },
					    plotOptions: {
					        pie: {
					            allowPointSelect: true,
					            cursor: 'pointer',
					            dataLabels: {
					            	enabled: true,
					                format: '<b>{point.name}</b>: {point.percentage:.2f} %'
					            }
					        }
					    },
					    series: [{
					        name: '인원비율',
					        colorByPoint: true,
					        data: resultArr
					    }]
					});
                 ////////////////////////////////////////////////////////////
                 
	                 let html = "<table>";
	                     html += "<tr>" +
	                                "<th>성별</th>" +
	                                "<th>인원수</th>" +
	                                "<th>퍼센티지</th>" +
	                             "</tr>";
	                             
	                 $.each(json, function(index, item){
	                	 html += "<tr>" +
				                     "<td>"+ item.gender +"</td>" +
				                     "<td>"+ item.cnt +"</td>" +
				                     "<td>"+ Number(item.percentage) +"</td>" +
				                 "</tr>";
	                 });
	                 
	                 html += "</table>";
	                 
	                 $("div#table_container").html(html);
                },
                error: function(request, status, error){
					alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
				}
		    });
		
			break;
			
		
		case "deptnameGender": // 부서별 성별 인원통계 를 선택한 경우  
		
			$.ajax({
		    	url:"<%= request.getContextPath()%>/chart/employeeCntByDeptname.action", 
		    	dataType:"JSON",
                success:function(json_1) {
                	
                	let deptnameArr = []; // 부서명별 인원수 퍼센티지 객체배열
                	
                	$.each(json_1, function(index, item){
                		deptnameArr.push({name: item.department_name,
					                      y: Number(item.percentage),
					                      drilldown: item.department_name
					                     });
                	});// end of $.each(json, function(index, item){})------------------ 
                	
                	let genderArr = [];   // 특정 부서명에 근무하는 직원들의 성별 인원수 퍼센티지 객체 배열 
                	
                	$.each(json_1, function(index_1, item_1){
                		
                		$.ajax({
                			url:"<%= request.getContextPath()%>/chart/genderCntSpecialDeptname.action",
                			type:"GET",
                			data:{"deptname":item_1.department_name},
                			dataType:"JSON",
                			success:function(json_2) {
                			   
                				let subArr = [];
                				
                				$.each(json_2, function(index_2, item_2){
                					
                					subArr.push([item_2.gender,
				                                 Number(item_2.percentage)]);
                					
                				});// end of $.each(json_2, function(index_2, item_2){})-----------
                				
                				genderArr.push({name:item_1.department_name,
                					            id:item_1.department_name,
                					            data:subArr});
                				
                			},
                			error: function(request, status, error){
            					alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
            				}
                		});
                		
                	});// end of $.each(json, function(index, item){})------------------
                	
                    
                 ////////////////////////////////////////////////////////////
					Highcharts.chart('chart_container', {
					    chart: {
					        type: 'column'
					    },
					    title: {
					        align: 'left',
					        text: '부서명별 남녀 비율'
					    },
					    subtitle: {
					      <%--  
					    	align: 'left',
					        text: 'Click the columns to view versions. Source: <a href="http://statcounter.com" target="_blank">statcounter.com</a>' 
					      --%>  
					    },
					    accessibility: {
					        announceNewData: {
					            enabled: true
					        }
					    },
					    xAxis: {
					        type: 'category'
					    },
					    yAxis: {
					        title: {
					            text: '구성비율(%)'
					        }
					
					    },
					    legend: {
					        enabled: false
					    },
					    plotOptions: {
					        series: {
					            borderWidth: 0,
					            dataLabels: {
					                enabled: true,
					                format: '{point.y:.2f}%'
					            }
					        }
					    },
					
					    tooltip: {
					        headerFormat: '<span style="font-size:11px">{series.name}</span><br>',
					        pointFormat: '<span style="color:{point.color}">{point.name}</span>: <b>{point.y:.2f}%</b> of total<br/>'
					    },
					
					    series: [
					        {
					            name: "Browsers",
					            colorByPoint: true,
					            data: deptnameArr  // **** 위에서 구한 값을 대입시킴. 부서명별 인원수 퍼센티지 객체 배열 ****// 
					          /*  
					            data: [
					                {
					                    name: "Chrome",
					                    y: 62.74,
					                    drilldown: "Chrome"
					                },
					                {
					                    name: "Firefox",
					                    y: 10.57,
					                    drilldown: "Firefox"
					                },
					                {
					                    name: "Internet Explorer",
					                    y: 7.23,
					                    drilldown: "Internet Explorer"
					                },
					                {
					                    name: "Safari",
					                    y: 5.58,
					                    drilldown: "Safari"
					                },
					                {
					                    name: "Edge",
					                    y: 4.02,
					                    drilldown: "Edge"
					                },
					                {
					                    name: "Opera",
					                    y: 1.92,
					                    drilldown: "Opera"
					                },
					                {
					                    name: "Other",
					                    y: 7.62,
					                    drilldown: null
					                }
					            ]
					         */
					        }
					    ],
					    drilldown: {
					        breadcrumbs: {
					            position: {
					                align: 'right'
					            }
					        },
					        series: genderArr  // **** 위에서 구한 값을 대입시킴. 특정 부서명에 근무하는 직원들의 성별 인원수 퍼센티지 객체 배열 ****//  
					      /*  
					        series: [
					            {
					                name: "Chrome",
					                id: "Chrome",
					                data: [
					                    [
					                        "v65.0",
					                        0.1
					                    ],
					                    [
					                        "v64.0",
					                        1.3
					                    ],
					                    [
					                        "v63.0",
					                        53.02
					                    ],
					                    [
					                        "v62.0",
					                        1.4
					                    ],
					                    [
					                        "v61.0",
					                        0.88
					                    ],
					                    [
					                        "v60.0",
					                        0.56
					                    ],
					                    [
					                        "v59.0",
					                        0.45
					                    ],
					                    [
					                        "v58.0",
					                        0.49
					                    ],
					                    [
					                        "v57.0",
					                        0.32
					                    ],
					                    [
					                        "v56.0",
					                        0.29
					                    ],
					                    [
					                        "v55.0",
					                        0.79
					                    ],
					                    [
					                        "v54.0",
					                        0.18
					                    ],
					                    [
					                        "v51.0",
					                        0.13
					                    ],
					                    [
					                        "v49.0",
					                        2.16
					                    ],
					                    [
					                        "v48.0",
					                        0.13
					                    ],
					                    [
					                        "v47.0",
					                        0.11
					                    ],
					                    [
					                        "v43.0",
					                        0.17
					                    ],
					                    [
					                        "v29.0",
					                        0.26
					                    ]
					                ]
					            },
					            {
					                name: "Firefox",
					                id: "Firefox",
					                data: [
					                    [
					                        "v58.0",
					                        1.02
					                    ],
					                    [
					                        "v57.0",
					                        7.36
					                    ],
					                    [
					                        "v56.0",
					                        0.35
					                    ],
					                    [
					                        "v55.0",
					                        0.11
					                    ],
					                    [
					                        "v54.0",
					                        0.1
					                    ],
					                    [
					                        "v52.0",
					                        0.95
					                    ],
					                    [
					                        "v51.0",
					                        0.15
					                    ],
					                    [
					                        "v50.0",
					                        0.1
					                    ],
					                    [
					                        "v48.0",
					                        0.31
					                    ],
					                    [
					                        "v47.0",
					                        0.12
					                    ]
					                ]
					            },
					            {
					                name: "Internet Explorer",
					                id: "Internet Explorer",
					                data: [
					                    [
					                        "v11.0",
					                        6.2
					                    ],
					                    [
					                        "v10.0",
					                        0.29
					                    ],
					                    [
					                        "v9.0",
					                        0.27
					                    ],
					                    [
					                        "v8.0",
					                        0.47
					                    ]
					                ]
					            },
					            {
					                name: "Safari",
					                id: "Safari",
					                data: [
					                    [
					                        "v11.0",
					                        3.39
					                    ],
					                    [
					                        "v10.1",
					                        0.96
					                    ],
					                    [
					                        "v10.0",
					                        0.36
					                    ],
					                    [
					                        "v9.1",
					                        0.54
					                    ],
					                    [
					                        "v9.0",
					                        0.13
					                    ],
					                    [
					                        "v5.1",
					                        0.2
					                    ]
					                ]
					            },
					            {
					                name: "Edge",
					                id: "Edge",
					                data: [
					                    [
					                        "v16",
					                        2.6
					                    ],
					                    [
					                        "v15",
					                        0.92
					                    ],
					                    [
					                        "v14",
					                        0.4
					                    ],
					                    [
					                        "v13",
					                        0.1
					                    ]
					                ]
					            },
					            {
					                name: "Opera",
					                id: "Opera",
					                data: [
					                    [
					                        "v50.0",
					                        0.96
					                    ],
					                    [
					                        "v49.0",
					                        0.82
					                    ],
					                    [
					                        "v12.1",
					                        0.14
					                    ]
					                ]
					            }
					        ]
					     */  
					        
					    }
					});   	
                 ////////////////////////////////////////////////////////////
                     
                },
                error: function(request, status, error){
					alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
				}
		    });			
		
			break;			
	}
	  
  }// end of function func_choice(searchType) {}---------------------------
  
</script>











    