<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 


<style type="text/css">

    span.move {cursor: pointer; color: navy;}
    .moveColor {color: #660029; font-weight: bold; background-color: #ffffe6;}
    
    td.comment {text-align: center;}
    
    a {text-decoration: none !important;}

</style>   
    
<script type="text/javascript">
  $(document).ready(function(){
	  
   // goReadComment();  // 페이징 처리 안한 댓글 읽어오기
      goViewComment(1); // 페이징 처리한 댓글 읽어오기
	  
	  $("span.move").hover(function(){
		  					 $(this).addClass("moveColor");
	                       }, 
	                       function(){
	                    	 $(this).removeClass("moveColor");  
	                       });
	      
  });// end of $(document).ready(function(){})------------------------
  
  
  // Function Declaration
  
  // == 댓글쓰기 == 
  function goAddWrite() {
	  
	  const commentContent = $("input#commentContent").val().trim();
	  if(commentContent == "") {
		  alert("댓글 내용을 입력하세요!!");
		  return; // 종료
	  }
	  
	  else{
		  if($("input#attach").val() == "") {
			  // 첨부파일이 없는 댓글쓰기인 경우
			  goAddWrite_noAttach();
		  }
		  else {
			 // 첨부파일이 있는 댓글쓰기인 경우 
			 goAddWrite_withAttach();
		  }
	  }
  }// end of function goAddWrite() {}--------------------
  
  // 파일첨부가 없는 댓글쓰기 
  function goAddWrite_noAttach() {
	  
	  <%--
	      // 보내야할 데이터를 선정하는 또 다른 방법
		  // jQuery에서 사용하는 것으로써,
		  // form태그의 선택자.serialize(); 을 해주면 form 태그내의 모든 값들을 name값을 키값으로 만들어서 보내준다. 
		  const queryString = $("form[name=addWriteFrm]").serialize();
	  --%>
	  
	  $.ajax({
		  url:"<%= request.getContextPath()%>/addComment.action",
		  data:{"fk_userid":$("input#fk_userid").val() 
			   ,"name":$("input#name").val() 
			   ,"content":$("input#commentContent").val() 
			   ,"parentSeq":$("input#parentSeq").val()},
	 /*   또는
	      data:queryString, */	   
		  type:"POST",
		  dataType:"JSON",
		  success:function(json){
			 // "{"n":1,"name":"엄정화"}" 또는 "{"n":0,"name":"서영학"}"
			 
			 const n = json.n;
			 if(n == 0) {
				 alert(json.name + "님의 포인트는 300점을 초과할 수 없으므로 댓글쓰기가 불가합니다.");
			 }
			 else {
			  // goReadComment();  // 페이징 처리 안한 댓글 읽어오기
			     goViewComment(1); // 페이징 처리한 댓글 읽어오기
			 }
			 
			 $("input#commentContent").val("");
		  },
		  error: function(request, status, error){
				alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
		  }
	  });
	  
  }// end of function goAddWrite_noAttach() {}--------------------------
  
  
  // ==== #169. 파일첨부가 있는 댓글쓰기 ==== // 
  function goAddWrite_withAttach() {
	  <%-- === ajax로 파일을 업로드할때 가장 널리 사용하는 방법 ==> ajaxForm === //
		   === 우선 ajaxForm 을 사용하기 위해서는 jquery.form.min.js 이 있어야 하며
		       /WEB-INF/tiles/layout/layout-tiles1.jsp 와 
		       /WEB-INF/tiles/layout/layout-tiles2.jsp 에 기술해 두었다. 
	  --%>
	  
	  <%--
	      // 보내야할 데이터를 선정하는 또 다른 방법
		  // jQuery에서 사용하는 것으로써,
		  // form태그의 선택자.serialize(); 을 해주면 form 태그내의 모든 값들을 name값을 키값으로 만들어서 보내준다. 
		  const queryString = $("form[name=addWriteFrm]").serialize();
	  --%>
	    
	  var queryString = $("form[name=addWriteFrm]").serialize();
	  
	  $("form[name=addWriteFrm]").ajaxForm({
		  url:"<%= request.getContextPath()%>/addComment_withAttach.action",
		  data:queryString,
	 	  type:"POST",
	 	  enctype:"multipart/form-data",
		  dataType:"JSON",
		  success:function(json){
			 // "{"n":1,"name":"엄정화"}" 또는 "{"n":0,"name":"서영학"}"
			 
			 const n = json.n;
			 if(n == 0) {
				 alert(json.name + "님의 포인트는 300점을 초과할 수 없으므로 댓글쓰기가 불가합니다.");
			 }
			 else {
			  // goReadComment();  // 페이징 처리 안한 댓글 읽어오기
			     goViewComment(1); // 페이징 처리한 댓글 읽어오기
			 }
			 
			 $("input#commentContent").val("");
			 $("input#attach").val("");
		  },
		  error: function(request, status, error){
				alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
		  }
	  });
	  	  
	  $("form[name=addWriteFrm]").submit();
	 
  }// end of function goAddWrite_noAttach() {}--------------------------
  
  
  // === 페이징 처리 안한 댓글 읽어오기  === //
  function goReadComment() {
	  
	  $.ajax({
		  url:"<%= request.getContextPath()%>/readComment.action",
		  data:{"parentSeq":"${requestScope.boardvo.seq}"},
		  dataType:"JSON",
		  success:function(json){
			  // [{"name":"엄정화","regDate":"2022-04-25 10:23:51","content":"두번째 댓글 입니다."},{"name":"엄정화","regDate":"2022-04-25 10:13:47","content":"첫번째 댓글 입니다."}] 
			  // 또는
			  // [] 
			  
			  let html = "";
			  if(json.length > 0) {
				  $.each(json, function(index, item){
					  html += "<tr>";
					  html += "<td class='comment'>"+(index+1)+"</td>";
					  html += "<td>"+item.content+"</td>";
					  html += "<td class='comment'>"+item.name+"</td>";
					  html += "<td class='comment'>"+item.regDate+"</td>";
					  html += "</tr>";
				  });
			  }
			  else {
				  html += "<tr>";
				  html += "<td colspan='4' class='comment'>댓글이 없습니다</td>";
				  html += "</tr>";
			  }
			  
			  $("tbody#commentDisplay").html(html);
		  },
		  error: function(request, status, error){
				alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
		  }
	  });
	  
  }// end of function goReadComment(){}--------------------------
  
  
  // === #127. Ajax로 불러온 댓글내용을  페이징 처리 하기  === //
  function goViewComment(currentShowPageNo) {
	  
	  $.ajax({
		  url:"<%= request.getContextPath()%>/commentList.action",
		  data:{"parentSeq":"${requestScope.boardvo.seq}",
			    "currentShowPageNo":currentShowPageNo},
		  dataType:"JSON",
		  success:function(json){
			  // == 첨부파일이 기능이 없을시 ==
			  // [{"name":"서영학","regDate":"2022-04-27 15:03:36","content":"열세번째 댓글 입니다."},{"name":"서영학","regDate":"2022-04-27 15:03:28","content":"열두번째 댓글 입니다."},{"name":"서영학","regDate":"2022-04-27 15:03:23","content":"열한번째 댓글 입니다."}] 
			  // 또는
			  // []
			  
			  // == 첨부파일이 기능이 추가된 경우 ==
			  // [{"fileName":"202205030921221211696739401900.jpg","fileSize":"71317","name":"엄정화","regDate":"2022-05-03 09:21:22","content":"첨부파일 추가 연습 2","seq":"4","orgFilename":"berkelekle심플라운드01.jpg"},{"fileName":" ","fileSize":" ","name":"엄정화","regDate":"2022-05-02 16:04:19","content":"댓글쓰기에서 파일첨부 연습 1","seq":"2","orgFilename":" "},{"fileName":" ","fileSize":" ","name":"엄정화","regDate":"2022-05-02 12:44:59","content":"안녕하세요?","seq":"1","orgFilename":" "}]  
			  // 또는
			  // []
			  
			  let html = "";
			  if(json.length > 0) {
				  $.each(json, function(index, item){
					  html += "<tr>";
					  html += "<td class='comment'>"+(index+1)+"</td>";
					  html += "<td>"+item.content+"</td>";
					  
				<%-- === 첨부파일이 기능이 추가된 경우 시작 === --%>	  
				   if(${sessionScope.loginuser != null}) {	  
				      html += "<td><a href='<%= request.getContextPath()%>/downloadComment.action?seq="+item.seq+"'>"+item.orgFilename+"</a></td>";
				   }   
				   else {	  
				      html += "<td>"+item.orgFilename+"</td>";
				   }   
					  
					  html += "<td>"+ Number(item.fileSize).toLocaleString('en') +"</td>";
			    <%-- === 첨부파일이 기능이 추가된 경우 끝 === --%>	
			    
					  html += "<td class='comment'>"+item.name+"</td>";
					  html += "<td class='comment'>"+item.regDate+"</td>";
					  html += "</tr>";
				  });
			  }
			  else {
				  html += "<tr>";
				  html += "<td colspan='4' class='comment'>댓글이 없습니다</td>";
				  html += "</tr>";
			  }
			  
			  $("tbody#commentDisplay").html(html);
			  
			  // 페이지바 함수 호출
			  makeCommentPageBar(currentShowPageNo);
		  },
		  error: function(request, status, error){
				alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
		  }
	  });
	  
  }// end of function goViewComment(currentShowPageNo) {}-------------------------
  
  
  // ==== 댓글내용 페이지바 Ajax로 만들기 ==== //
  function makeCommentPageBar(currentShowPageNo) {
	  
	  <%-- === 원글에 대한 댓글의 totalPage 수를 알아오려고 한다. ===  --%>
	  $.ajax({
		  url:"<%= request.getContextPath()%>/getCommentTotalPage.action",
		  data:{"parentSeq":"${requestScope.boardvo.seq}",
			    "sizePerPage":"5"},
		  type:"GET",
		  dataType:"JSON",
		  success:function(json){
			 //  console.log("확인용 댓글의 전체페이지수 : " + json.totalPage);
			 
			 if(json.totalPage > 0) {
				 // 댓글이 있는 경우 
				 
				 const totalPage = json.totalPage;
				 
				 let pageBarHTML = "<ul style='list-style: none;'>";
				 
				 const blockSize = 10;
			//	 const blockSize = 2;
				 
				// blockSize 는 1개 블럭(토막)당 보여지는 페이지번호의 개수 이다.
				/*
				                 1 2 3 4 5 6 7 8 9 10  [다음][마지막]           -- 1개블럭
				   [맨처음][이전]  11 12 13 14 15 16 17 18 19 20  [다음][마지막]   -- 1개블럭
				   [맨처음][이전]  21 22 23
				*/
				 
				 let loop = 1;
				 /*
			    	loop는 1부터 증가하여 1개 블럭을 이루는 페이지번호의 개수[ 지금은 10개(== blockSize) ] 까지만 증가하는 용도이다.
			     */
			    

			     if(typeof currentShowPageNo == "string") {
			    	 currentShowPageNo = Number(currentShowPageNo);
			     }
			     
			     // *** !! 다음은 currentShowPageNo 를 얻어와서 pageNo 를 구하는 공식이다. !! *** //
			     let pageNo = Math.floor( (currentShowPageNo - 1)/blockSize ) * blockSize + 1;
			     /*
			       currentShowPageNo 가 3페이지 이라면 pageNo 는 1 이 되어야 한다.
			       ((3 - 1)/10) * 10 + 1;
			       ( 2/10 ) * 10 + 1;
			       ( 0.2 ) * 10 + 1;
			       Math.floor( 0.2 ) * 10 + 1;  // 소수부가 있을시 Math.floor(0.2) 은 0.2 보다 작은 최대의 정수인 0을 나타낸다.
			       0 * 10 + 1 
			       1
			       
			       currentShowPageNo 가 11페이지 이라면 pageNo 는 11 이 되어야 한다.
			       ((11 - 1)/10) * 10 + 1;
			       ( 10/10 ) * 10 + 1;
			       ( 1 ) * 10 + 1;
			       Math.floor( 1 ) * 10 + 1;  // 소수부가 없을시 Math.floor(1) 은 그대로 1 이다.
			       1 * 10 + 1
			       11
			       
			       currentShowPageNo 가 20페이지 이라면 pageNo 는 11 이 되어야 한다.
			       ((20 - 1)/10) * 10 + 1;
			       ( 19/10 ) * 10 + 1;
			       ( 1.9 ) * 10 + 1;
			       Math.floor( 1.9 ) * 10 + 1;  // 소수부가 있을시 Math.floor(1.9) 은 1.9 보다 작은 최대의 정수인 1을 나타낸다.
			       1 * 10 + 1
			       11
			    
			       
				    1  2  3  4  5  6  7  8  9  10  -- 첫번째 블럭의 페이지번호 시작값(pageNo)은 1 이다.
				    11 12 13 14 15 16 17 18 19 20  -- 두번째 블럭의 페이지번호 시작값(pageNo)은 11 이다.
				    21 22 23 24 25 26 27 28 29 30  -- 세번째 블럭의 페이지번호 시작값(pageNo)은 21 이다.
				    
				    currentShowPageNo         pageNo
				   ----------------------------------
				         1                      1 = ((1 - 1)/10) * 10 + 1
				         2                      1 = ((2 - 1)/10) * 10 + 1
				         3                      1 = ((3 - 1)/10) * 10 + 1
				         4                      1
				         5                      1
				         6                      1
				         7                      1 
				         8                      1
				         9                      1
				         10                     1 = ((10 - 1)/10) * 10 + 1
				        
				         11                    11 = ((11 - 1)/10) * 10 + 1
				         12                    11 = ((12 - 1)/10) * 10 + 1
				         13                    11 = ((13 - 1)/10) * 10 + 1
				         14                    11
				         15                    11
				         16                    11
				         17                    11
				         18                    11 
				         19                    11 
				         20                    11 = ((20 - 1)/10) * 10 + 1
				         
				         21                    21 = ((21 - 1)/10) * 10 + 1
				         22                    21 = ((22 - 1)/10) * 10 + 1
				         23                    21 = ((23 - 1)/10) * 10 + 1
				         ..                    ..
				         29                    21
				         30                    21 = ((30 - 1)/10) * 10 + 1
				         
				*/
			     
				// === [맨처음][이전] 만들기 === //
				if(pageNo != 1) {
					pageBarHTML += "<li style='display:inline-block; width:70px; font-size:12pt;'><a href='javascript:goViewComment(\"1\")'>[맨처음]</a></li>";
					pageBarHTML += "<li style='display:inline-block; width:50px; font-size:12pt;'><a href='javascript:goViewComment(\""+(pageNo-1)+"\")'>[이전]</a></li>";
				}
				
				while( !(loop > blockSize || pageNo > totalPage) ) {
					
					if(pageNo == currentShowPageNo) {
						pageBarHTML += "<li style='display:inline-block; width:30px; font-size:12pt; border:solid 1px gray; color:red; padding:2px 4px;'>"+pageNo+"</li>";  
					}
					else {
						pageBarHTML += "<li style='display:inline-block; width:30px; font-size:12pt;'><a href='javascript:goViewComment(\""+pageNo+"\")'>"+pageNo+"</a></li>"; 
					}
					
					loop++;
					pageNo++;
					
				}// end of while-----------------------
				
				
				// === [다음][마지막] 만들기 === //
				if( pageNo <= totalPage ) {
					pageBarHTML += "<li style='display:inline-block; width:50px; font-size:12pt;'><a href='javascript:goViewComment(\""+pageNo+"\")'>[다음]</a></li>";
					pageBarHTML += "<li style='display:inline-block; width:70px; font-size:12pt;'><a href='javascript:goViewComment(\""+totalPage+"\")'>[마지막]</a></li>"; 
				}
				 
				pageBarHTML += "</ul>";
				 
				$("div#pageBar").html(pageBarHTML);
			 }// end of if(json.totalPage > 0){}-------------------------------
			  
		  },
		  error: function(request, status, error){
				alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
		  }    
	  });
	  
  }// end of function makeCommentPageBar(currentShowPageNo) {}--------------------
  
</script>

<div style="display: flex;">
<div style="margin: auto; padding-left: 3%;">

	<h2 style="margin-bottom: 30px;">글내용보기</h2>

    <c:if test="${not empty requestScope.boardvo}">
    	<table style="width: 1024px" class="table table-bordered table-dark">
    		<tr>
    		    <th style="width: 15%">글번호</th>
    		    <td>${requestScope.boardvo.seq}</td>
    		</tr>
    		<tr>
    		    <th>성명</th>
    		    <td>${requestScope.boardvo.name}</td>
    		</tr>
    		<tr>
    		    <th>제목</th>
    		    <td>${requestScope.boardvo.subject}</td>
    		</tr>
    		<tr>
    		    <th>내용</th>
    		    <td>
    		      <p style="word-break: break-all;">${requestScope.boardvo.content}</p>
    		      <%-- 
				      style="word-break: break-all; 은 공백없는 긴영문일 경우 width 크기를 뚫고 나오는 것을 막는 것임. 
				           그런데 style="word-break: break-all; 나 style="word-wrap: break-word; 은
				           테이블태그의 <td>태그에는 안되고 <p> 나 <div> 태그안에서 적용되어지므로 <td>태그에서 적용하려면
				      <table>태그속에 style="word-wrap: break-word; table-layout: fixed;" 을 주면 된다.
				 --%>
    		    </td>
    		</tr>
    		<tr>
    		    <th>조회수</th>
    		    <td>${requestScope.boardvo.readCount}</td>
    		</tr>
    		<tr>
    		    <th>날짜</th>
    		    <td>${requestScope.boardvo.regDate}</td>
    		</tr>
    		
    		<%-- === #162. 첨부파일 이름 및 파일크기를 보여주고 첨부파일을 다운로드 되도록 만들기 === --%>
			<tr>
				<th>첨부파일</th>
				<td>
					<c:if test="${sessionScope.loginuser != null}">
						<a href="<%= request.getContextPath()%>/download.action?seq=${requestScope.boardvo.seq}">${requestScope.boardvo.orgFilename}</a>  
					</c:if>
					<c:if test="${sessionScope.loginuser == null}">
						${requestScope.boardvo.orgFilename}
					</c:if>
				</td>
			</tr>
			<tr>
				<th>파일크기(bytes)</th>
				<td><fmt:formatNumber value="${requestScope.boardvo.fileSize}" pattern="#,###" /></td>
			</tr>
    		
    	</table>
    	<br/>
    	
    	<c:set var="v_gobackURL" value='${ fn:replace(requestScope.gobackURL, "&", " ") }' />
    	
    	<div style="margin-bottom: 1%;">이전글제목&nbsp;&nbsp;<span class="move" onclick="javascript:location.href='view_2.action?seq=${requestScope.boardvo.previousseq}&searchType=${requestScope.paraMap.searchType}&searchWord=${requestScope.paraMap.searchWord}&gobackURL=${v_gobackURL}'">${requestScope.boardvo.previoussubject}</span></div>
    	<div style="margin-bottom: 1%;">다음글제목&nbsp;&nbsp;<span class="move" onclick="javascript:location.href='view_2.action?seq=${requestScope.boardvo.nextseq}&searchType=${requestScope.paraMap.searchType}&searchWord=${requestScope.paraMap.searchWord}&gobackURL=${v_gobackURL}'">${requestScope.boardvo.nextsubject}</span></div>
    	<br/> 
    	    	
    	<button type="button" class="btn btn-secondary btn-sm mr-3" onclick="javascript:location.href='<%= request.getContextPath()%>/list.action'">전체목록보기</button>
    	
    	<%-- === #126. 페이징 처리되어진 후 특정 글제목을 클릭하여 상세내용을 본 이후
	                                   사용자가 목록보기 버튼을 클릭했을 때 돌아갈 페이지를 알려주기 위해
	                                   현재 페이지 주소를 뷰단으로 넘겨준다. === --%>
    	<button type="button" class="btn btn-secondary btn-sm mr-3" onclick="javascript:location.href='<%= request.getContextPath()%>${requestScope.gobackURL}'">검색된결과목록보기</button>
    	
    	<button type="button" class="btn btn-secondary btn-sm mr-3" onclick="javascript:location.href='<%= request.getContextPath()%>/edit.action?seq=${requestScope.boardvo.seq}'">글수정하기</button>
    	<button type="button" class="btn btn-secondary btn-sm mr-3" onclick="javascript:location.href='<%= request.getContextPath()%>/del.action?seq=${requestScope.boardvo.seq}'">글삭제하기</button>
    	
    	<%-- === #141. 어떤글에 대한 답변글쓰기는 로그인 되어진 회원의 gradelevel 컬럼의 값이 10인 직원들만 답변글쓰기가 가능하다.  === --%>
    	<c:if test="${sessionScope.loginuser.gradelevel == 10}">
    	    <%-- 
    	    	<span>groupno : ${requestScope.boardvo.groupno}</span>
    	    	<span>depthno : ${requestScope.boardvo.depthno}</span>
    	    --%>	
    	    
    		<button type="button" class="btn btn-secondary btn-sm mr-3" onclick="javascript:location.href='<%= request.getContextPath()%>/add.action?fk_seq=${requestScope.boardvo.seq}&groupno=${requestScope.boardvo.groupno}&depthno=${requestScope.boardvo.depthno}&subject=${requestScope.boardvo.subject}'">답변글쓰기</button> 
    	</c:if>
    	
    	<%-- === #83. 댓글쓰기 폼 추가 === --%>
    	<c:if test="${not empty sessionScope.loginuser}">
    	   <h3 style="margin-top: 50px;">댓글쓰기</h3>
    	
    	   <form name="addWriteFrm" id="addWriteFrm" style="margin-top: 20px;">
    	      <table class="table" style="width: 1024px">
				   <tr style="height: 30px;">
				      <th width="10%">성명</th>
				      <td>
				         <input type="hidden" name="fk_userid" id="fk_userid" value="${sessionScope.loginuser.userid}" />  
				         <input type="text" name="name" id="name" value="${sessionScope.loginuser.name}" readonly />
				      </td>
				   </tr>
				   <tr style="height: 30px;">
				      <th>댓글내용</th>
				      <td>
				         <input type="text" name="content" id="commentContent" size="100" />
				         
				         <%-- 댓글에 달리는 원게시물 글번호(즉, 댓글의 부모글 글번호) --%>
				         <input type="hidden" name="parentSeq" id="parentSeq" value="${requestScope.boardvo.seq}" />
				      </td>
				   </tr>
				   
				   <tr style="height: 30px;">
				      <th>파일첨부</th>
				      <td>
				      	 <input type="file" name="attach" id="attach" />
				      </td>
				   </tr>
				   
				   <tr>
				      <th colspan="2">
				      	<button type="button" class="btn btn-success btn-sm mr-3" onclick="goAddWrite()">댓글쓰기 확인</button>
				      	<button type="reset" class="btn btn-success btn-sm">댓글쓰기 취소</button>
				      </th>
				   </tr>
			  </table>	      
    	   </form>
    	</c:if>
    	
    	
    	<%-- === #94. 댓글 내용 보여주기 === --%>
    	<h3 style="margin-top: 50px;">댓글내용</h3>
		<table class="table" style="width: 1024px; margin-top: 2%; margin-bottom: 3%;">
			<thead>
			<tr>
			    <th style="width: 6%;  text-align: center;">번호</th>
				<th style="text-align: center;">내용</th>
				
				<%-- 첨부파일 있는 경우 시작 --%>
				<th style="width: 15%;">첨부파일</th>
				<th style="width: 8%;">bytes</th>
				<%-- 첨부파일 있는 경우 끝 --%>
				
				<th style="width: 8%; text-align: center;">작성자</th>
				<th style="width: 12%; text-align: center;">작성일자</th>
			</tr>
			</thead>
			<tbody id="commentDisplay"></tbody>
		</table>
		
		<%-- ==== #136. 댓글 페이지바 ==== --%>
    	<div style="display: flex; margin-bottom: 50px;">
    	   <div id="pageBar" style="margin: auto; text-align: center;"></div>
    	</div>
    	
    </c:if>

	<c:if test="${empty requestScope.boardvo}">
    	<div style="padding: 50px 0; font-size: 16pt; color: red;" >존재하지 않습니다</div>
    </c:if>
    
</div>
</div>    
    