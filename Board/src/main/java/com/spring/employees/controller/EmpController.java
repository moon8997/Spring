package com.spring.employees.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.poi.hssf.usermodel.HSSFDataFormat;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.streaming.SXSSFSheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.spring.board.common.MyUtil;
import com.spring.employees.service.InterEmpService;


@Controller
public class EmpController {

	@Autowired
	private InterEmpService service;
	
	// === #175. 다중 체크박스를 사용시 sql문에서 in 절을 처리하는 예제 === //
	@RequestMapping(value="/emp/empList.action")
	public String empmanager_employeeInfoView(HttpServletRequest request, HttpServletResponse response) {
		
	//	getCurrentURL(request); // 로그아웃을 했을 때 현재 보이던 그 페이지로 그대로 돌아가기  위한 메소드 호출 
		
		// employees 테이블에서 근무중인 사원들의 부서번호 가져오기 
		List<String> deptIdList = service.deptIdList();
		
		String str_DeptId = request.getParameter("str_DeptId");
	//	System.out.println("~~ 확인용 str_DeptId => " + str_DeptId);
		
		/*
		 *   ~~ 확인용 str_DeptId => null
		 *   ~~ 확인용 str_DeptId =>
		 *   
			 str_DeptId => -9999,30,50,80
			 str_DeptId => 
			 str_DeptId => 10,30,40,90,100
		 */
		
		String gender = request.getParameter("gender");
	//	System.out.println("~~ 확인용 gender => " + gender);
		/*
			~~ 확인용 gender => null
		*/
		Map<String, Object> paraMap = new HashMap<>(); // 배열을 받을때에는 Object 로 받아야 한다.
	
		if(str_DeptId != null && !"".equals(str_DeptId)) {
			String[] arr_DeptId = str_DeptId.split("\\,"); // split 앞에는 \\ 
			paraMap.put("arr_DeptId", arr_DeptId);
			
			request.setAttribute("str_DeptId", str_DeptId);
			// 뷰단에서 체크되어진 값을 유지시키기 위한 것이다.
		}
		if(gender != null && !"".equals(gender)) {
			paraMap.put("gender",gender);
			
			request.setAttribute("gender", gender);
			// 뷰단에서 선택한 성별을 유지시키기 위한 것이다.
		}
		
		
		List<Map<String, String>> empList = service.empList(paraMap);
				
		request.setAttribute("deptIdList", deptIdList);
		request.setAttribute("empList", empList);
		
		return "emp/empList.tiles2";
		//  /WEB-INF/views/tiles2/emp/empList.jsp 파일을 생성한다.
	}
	
	// === #.176. Excel 파일로 다운받기 예제
	@RequestMapping(value="/excel/downloadExcelFile.action", method = {RequestMethod.POST})
	public String downloadExcelFile(HttpServletRequest request, Model model) {
			
		String str_DeptId = request.getParameter("str_DeptId");
		
		String gender = request.getParameter("gender");

		Map<String, Object> paraMap = new HashMap<>(); // 배열을 받을때에는 Object 로 받아야 한다.
	
		if(str_DeptId != null && !"".equals(str_DeptId)) {
			String[] arr_DeptId = str_DeptId.split("\\,"); // split 앞에는 \\ 
			paraMap.put("arr_DeptId", arr_DeptId);
		}
		if(gender != null && !"".equals(gender)) {
			paraMap.put("gender",gender);
		}
			
		List<Map<String, String>> empList = service.empList(paraMap);

		// === 조회결과물인 empList 를 가지고 엑셀 시트 생성하기 ===
	    // 시트를 생성하고, 행을 생성하고, 셀을 생성하고, 셀안에 내용을 넣어주면 된다.
		
		SXSSFWorkbook workbook = new SXSSFWorkbook();
		
		// 시트생성
		SXSSFSheet sheet = workbook.createSheet("HR사원정보");
		
		// 시트 열 너비 설정
		sheet.setColumnWidth(0, 2000);	
		sheet.setColumnWidth(1, 4000);
	    sheet.setColumnWidth(2, 2000);
	    sheet.setColumnWidth(3, 4000);
	    sheet.setColumnWidth(4, 3000);
	    sheet.setColumnWidth(5, 2000);
	    sheet.setColumnWidth(6, 1500);
	    sheet.setColumnWidth(7, 1500);
		
	    // 행의 위치를 나타내는 변수
	    int rowLocation = 0;
	    
		////////////////////////////////////////////////////////////////////////////////////////
		// CellStyle 정렬하기(Alignment)
		// CellStyle 객체를 생성하여 Alignment 세팅하는 메소드를 호출해서 인자값을 넣어준다.
		// 아래는 HorizontalAlignment(가로)와 VerticalAlignment(세로)를 모두 가운데 정렬 시켰다.
		CellStyle mergeRowStyle = workbook.createCellStyle();
		mergeRowStyle.setAlignment(HorizontalAlignment.CENTER);
		mergeRowStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		// import org.apache.poi.ss.usermodel.VerticalAlignment 으로 해야함.
	    
		CellStyle headerStyle = workbook.createCellStyle();
	    headerStyle.setAlignment(HorizontalAlignment.CENTER);
	    headerStyle.setVerticalAlignment(VerticalAlignment.CENTER);
		
	    // CellStyle 배경색(ForegroundColor)만들기
        // setFillForegroundColor 메소드에 IndexedColors Enum인자를 사용한다.
        // setFillPattern은 해당 색을 어떤 패턴으로 입힐지를 정한다.
	    mergeRowStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex()); // IndexedColors.DARK_BLUE.getIndex() 는 색상(남색)의 인덱스값을 리턴시켜준다.
	    mergeRowStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
	    
	    headerStyle.setFillForegroundColor(IndexedColors.LIGHT_YELLOW.getIndex());  // IndexedColors.LIGHT_YELLOW.getIndex() 는 연한노랑의 인덱스값을 리턴시켜준다.
	    headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
	    
	    // Cell 폰트(Font) 설정하기
        // 폰트 적용을 위해 POI 라이브러리의 Font 객체를 생성해준다.
        // 해당 객체의 세터를 사용해 폰트를 설정해준다. 대표적으로 글씨체, 크기, 색상, 굵기만 설정한다.
        // 이후 CellStyle의 setFont 메소드를 사용해 인자로 폰트를 넣어준다.
	    Font mergeRowFont = workbook.createFont();
	 // import org.apache.poi.ss.usermodel.Font; 으로 한다.
	    mergeRowFont.setFontName("나눔고딕");
	    mergeRowFont.setFontHeight((short)500);
	    mergeRowFont.setColor(IndexedColors.WHITE.getIndex());
	    mergeRowFont.setBold(true);
	    
	    mergeRowStyle.setFont(mergeRowFont);
	    
	    // CellStyle 테두리 Border
        // 테두리는 각 셀마다 상하좌우 모두 설정해준다.
        // setBorderTop, Bottom, Left, Right 메소드와 인자로 POI라이브러리의 BorderStyle 인자를 넣어서 적용한다.
	    headerStyle.setBorderTop(BorderStyle.THICK);
	    headerStyle.setBorderBottom(BorderStyle.THICK);
	    headerStyle.setBorderLeft(BorderStyle.THIN);
	    headerStyle.setBorderRight(BorderStyle.THIN);
	    
	    
	 // CellStyle 천단위 쉼표, 금액
        CellStyle moneyStyle = workbook.createCellStyle();
        moneyStyle.setDataFormat(HSSFDataFormat.getBuiltinFormat("#,##0"));
	    
	 // Cell Merge 셀 병합시키기
        /* 셀병합은 시트의 addMergeRegion 메소드에 CellRangeAddress 객체를 인자로 하여 병합시킨다.
           CellRangeAddress 생성자의 인자로(시작 행, 끝 행, 시작 열, 끝 열) 순서대로 넣어서 병합시킬 범위를 정한다. 배열처럼 시작은 0부터이다.  
        */
        // 병합할 행 만들기
	    Row mergeRow = sheet.createRow(rowLocation);	// 엑셀에서 행의 시작은 0부터 시작한다.
	    
	    // 병합할 행에 "우리회사 사원정보" 로 셀을 만들어 셀에 스타일을 주기
	    for(int i=0; i<8; i++) {
	    	Cell cell = mergeRow.createCell(i);
	    	cell.setCellStyle(mergeRowStyle);
	    	cell.setCellValue("우리회사 사원정보");
	    } // end of for --------
	    
	    // 셀 병합 하기
	    sheet.addMergedRegion(new CellRangeAddress(rowLocation, rowLocation, 0, 7)); // 시작 행, 끝 행, 시작 열, 끝 열 
        ////////////////////////////////////////////////////////////////////////////////////////////////
	    
	    // 헤더 행 생성
        Row headerRow = sheet.createRow(++rowLocation); // 엑셀에서 행의 시작은 0 부터 시작한다.
                                                        // ++rowLocation는 전위연산자임. 
	    
        // 해당 행의 첫번째 열 셀 생성
        Cell headerCell = headerRow.createCell(0); // 엑셀에서 열의 시작은 0부터 한다.
        headerCell.setCellValue("부서번호");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 두번째 열 셀 생성
        headerCell = headerRow.createCell(1); 
        headerCell.setCellValue("부서명");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 세번째 열 셀 생성
        headerCell = headerRow.createCell(2);
        headerCell.setCellValue("사원번호");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 네번째 열 셀 생성
        headerCell = headerRow.createCell(3);
        headerCell.setCellValue("사원명");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 다섯번째 열 셀 생성
        headerCell = headerRow.createCell(4);
        headerCell.setCellValue("입사일자");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 여섯번째 열 셀 생성
        headerCell = headerRow.createCell(5);
        headerCell.setCellValue("월급");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 일곱번째 열 셀 생성
        headerCell = headerRow.createCell(3);
        headerCell.setCellValue("성별");
        headerCell.setCellStyle(headerStyle);
        
        // 해당 행의 여덟번째 열 셀 생성
        headerCell = headerRow.createCell(3);
        headerCell.setCellValue("나이");
        headerCell.setCellStyle(headerStyle);
        
        // ==== HR사원정보 내용에 해당하는 행 및 셀 생성하기 ==== //
        Row bodyRow = null;
        Cell bodyCell = null;
        
        for(int i=0; i<empList.size(); i++) {
        	
        	Map<String, String> empMap = empList.get(i);
        	
        	// 행생성
        	bodyRow = sheet.createRow(i + (rowLocation+1));
        	
        	// 데이터 부서번호 표시
        	bodyCell = bodyRow.createCell(0);
        	bodyCell.setCellValue(empMap.get("department_id")); // hr(mapper)
        	
        	// 데이터 부서명 표시
        	bodyCell = bodyRow.createCell(1);
        	bodyCell.setCellValue(empMap.get("department_name"));
        	
        	// 데이터 사원번호 표시
        	bodyCell = bodyRow.createCell(2);
        	bodyCell.setCellValue(empMap.get("employee_id"));
        	
        	// 데이터 사원명 표시
        	bodyCell = bodyRow.createCell(3);
        	bodyCell.setCellValue(empMap.get("fullname"));
        	
        	// 데이터 입사일자 표시
        	bodyCell = bodyRow.createCell(4);
        	bodyCell.setCellValue(empMap.get("hire_date"));
        	
        	
        	// 데이터 월급 표시
        	bodyCell = bodyRow.createCell(5);
        	bodyCell.setCellValue(Integer.parseInt(empMap.get("monthsal")));
        	bodyCell.setCellStyle(moneyStyle); // 천단위 쉼표, 금액
        	
        	// 데이터 성별 표시
        	bodyCell = bodyRow.createCell(0);
        	bodyCell.setCellValue(empMap.get("gender"));
        	
        	// 데이터 나이 표시
        	bodyCell = bodyRow.createCell(7);
        	bodyCell.setCellValue(Integer.parseInt(empMap.get("age")));
        	
        } // end of for ---------------------------------
        
        model.addAttribute("workbook", Locale.KOREA);
        model.addAttribute("workbook", workbook);
        model.addAttribute("workbookName", "HR사원정보");
        
		return "excelDownloadView";
	  //   "excelDownloadView" 은 
      //  /webapp/WEB-INF/spring/appServlet/servlet-context.xml 파일에서
      //  뷰리졸버 0 순위로 기술된 bean 의 id 값이다.  
	}
	
	// === #177. 차트(그래프)를 보여주는 예제(view)단
	@RequestMapping(value="/emp/chart.action")
	public String empmanager_chart(HttpServletRequest request) {
		return "emp/chart.tiles2";
	}
	
	// === #177. 차트그리기(Ajax) 부서명별 인원수 및 퍼센티지 가져오기 === //
	@ResponseBody
	@RequestMapping(value="/chart/employeeCntByDeptname.action", produces="text/plain;charset=UTF-8")
	public String employeeCntByDeptname() {
		
		List<Map<String, String>> deptnamePercentageList = service.employeeCntByDeptname();
		
		Gson gson = new Gson();
		JsonArray jsonArr = new JsonArray();
		
		for(Map<String, String> map : deptnamePercentageList) {
			JsonObject jsonObj = new JsonObject();
			jsonObj.addProperty("department_name", map.get("department_name"));
			jsonObj.addProperty("cnt", map.get("cnt"));
			jsonObj.addProperty("percentage", map.get("percentage"));
			
			jsonArr.add(jsonObj);
		}// end of for -----------------
		
		return new Gson().toJson(jsonArr);
	}

	// === #179. 차트그리기(Ajax) 성별 인원수 및 퍼센티지 가져오기 === //
	   @ResponseBody
	   @RequestMapping(value="/chart/employeeCntByGender.action", produces="text/plain;charset=UTF-8")
	   public String employeeCntByGender() {
	      
	      List<Map<String, String>> genderPercentageList = service.employeeCntByGender();
	      
	      JsonArray jsonArr = new JsonArray();
	      
	      for(Map<String, String> map : genderPercentageList) {
	         JsonObject jsonObj = new JsonObject();
	         jsonObj.addProperty("gender", map.get("gender"));
	         jsonObj.addProperty("cnt", map.get("cnt"));
	         jsonObj.addProperty("percentage", map.get("percentage"));
	         
	         jsonArr.add(jsonObj);
	      }// end of for----------------------------------------
	      
	      return new Gson().toJson(jsonArr);
	   }
	   
	   
	   
	 // === #200. 기상청 공공데이터(오픈데이터)를 가져와서 날씨정보 보여주기 === //
	 @RequestMapping(value="/opendata/weatherXML.action", method = {RequestMethod.GET})
	 public String weatherXML() {
		 return "opendata/weatherXML";
	 }
	 
//////////////////////////////////////////////////////
//////////////////////////////////////////////////////
@ResponseBody
@RequestMapping(value="/opendata/weatherXMLtoJSON.action", method= {RequestMethod.POST}, produces="text/plain;charset=UTF-8") 
public String weatherXMLtoJSON(HttpServletRequest request) { 

String str_jsonObjArr = request.getParameter("str_jsonObjArr");
/*  확인용
//   System.out.println(str_jsonObjArr);
//  [{"locationName":"속초","ta":"2.4"},{"locationName":"북춘천","ta":"-2.3"},{"locationName":"철원","ta":"-2.0"},{"locationName":"동두천","ta":"-0.7"},{"locationName":"파주","ta":"-1.2"},{"locationName":"대관령","ta":"-3.0"},{"locationName":"춘천","ta":"-1.6"},{"locationName":"백령도","ta":"1.1"},{"locationName":"북강릉","ta":"3.4"},{"locationName":"강릉","ta":"4.3"},{"locationName":"동해","ta":"4.1"},{"locationName":"서울","ta":"-0.3"},{"locationName":"인천","ta":"-0.2"},{"locationName":"원주","ta":"-2.2"},{"locationName":"울릉도","ta":"4.2"},{"locationName":"수원","ta":"1.4"},{"locationName":"영월","ta":"-4.5"},{"locationName":"충주","ta":"-3.0"},{"locationName":"서산","ta":"2.5"},{"locationName":"울진","ta":"3.9"},{"locationName":"청주","ta":"-0.7"},{"locationName":"대전","ta":"2.9"},{"locationName":"추풍령","ta":"3.2"},{"locationName":"안동","ta":"-2.3"},{"locationName":"상주","ta":"1.5"},{"locationName":"포항","ta":"4.7"},{"locationName":"군산","ta":"2.6"},{"locationName":"대구","ta":"1.6"},{"locationName":"전주","ta":"5.7"},{"locationName":"울산","ta":"4.0"},{"locationName":"창원","ta":"4.4"},{"locationName":"광주","ta":"2.8"},{"locationName":"부산","ta":"4.3"},{"locationName":"통영","ta":"5.7"},{"locationName":"목포","ta":"4.5"},{"locationName":"여수","ta":"5.6"},{"locationName":"흑산도","ta":"7.8"},{"locationName":"완도","ta":"7.3"},{"locationName":"고창","ta":"3.5"},{"locationName":"순천","ta":"5.3"},{"locationName":"홍성","ta":"1.7"},{"locationName":"제주","ta":"8.5"},{"locationName":"고산","ta":"9.1"},{"locationName":"성산","ta":"7.5"},{"locationName":"서귀포","ta":"8.8"},{"locationName":"진주","ta":"3.5"},{"locationName":"강화","ta":"-0.9"},{"locationName":"양평","ta":"-1.3"},{"locationName":"이천","ta":"-2.0"},{"locationName":"인제","ta":"-0.5"},{"locationName":"홍천","ta":"-2.6"},{"locationName":"태백","ta":"-1.5"},{"locationName":"정선군","ta":"-1.9"},{"locationName":"제천","ta":"-4.4"},{"locationName":"보은","ta":"-1.2"},{"locationName":"천안","ta":"-1.0"},{"locationName":"보령","ta":"3.6"},{"locationName":"부여","ta":"0.6"},{"locationName":"금산","ta":"3.7"},{"locationName":"세종","ta":"-0.8"},{"locationName":"부안","ta":"5.8"},{"locationName":"임실","ta":"1.6"},{"locationName":"정읍","ta":"5.8"},{"locationName":"남원","ta":"0.1"},{"locationName":"장수","ta":"1.4"},{"locationName":"고창군","ta":"4.3"},{"locationName":"영광군","ta":"4.2"},{"locationName":"김해시","ta":"4.1"},{"locationName":"순창군","ta":"1.0"},{"locationName":"북창원","ta":"5.9"},{"locationName":"양산시","ta":"3.9"},{"locationName":"보성군","ta":"5.1"},{"locationName":"강진군","ta":"4.4"},{"locationName":"장흥","ta":"4.9"},{"locationName":"해남","ta":"6.2"},{"locationName":"고흥","ta":"5.4"},{"locationName":"의령군","ta":"5.7"},{"locationName":"함양군","ta":"4.9"},{"locationName":"광양시","ta":"5.4"},{"locationName":"진도군","ta":"7.0"},{"locationName":"봉화","ta":"-3.3"},{"locationName":"영주","ta":"-4.3"},{"locationName":"문경","ta":"-3.1"},{"locationName":"청송군","ta":"0.5"},{"locationName":"영덕","ta":"4.7"},{"locationName":"의성","ta":"-0.6"},{"locationName":"구미","ta":"2.3"},{"locationName":"영천","ta":"3.4"},{"locationName":"경주시","ta":"4.5"},{"locationName":"거창","ta":"0.8"},{"locationName":"합천","ta":"0.7"},{"locationName":"밀양","ta":"1.1"},{"locationName":"산청","ta":"4.2"},{"locationName":"거제","ta":"5.8"},{"locationName":"남해","ta":"6.2"}]  
*/
//   return str_jsonObjArr;  -- 지역 96개 모두 차트에 그리기에는 너무 많으므로 아래처럼 작업을 하여 지역을  21개(String[] locationArr 임)로 줄여서 나타내기로 하겠다.

str_jsonObjArr = str_jsonObjArr.substring(1, str_jsonObjArr.length()-1);

String[] arr_str_jsonObjArr = str_jsonObjArr.split("\\},");

for(int i=0; i<arr_str_jsonObjArr.length; i++) {
arr_str_jsonObjArr[i] += "}";
}

/*  확인용
for(String jsonObj : arr_str_jsonObjArr) {
System.out.println(jsonObj);
}
*/
// {"locationName":"속초","ta":"15.7"}
// {"locationName":"북춘천","ta":"24.9"}
// {"locationName":"철원","ta":"23.8"}
// {"locationName":"동두천","ta":"26.3"}
// {"locationName":"파주","ta":"25.5"}
// {"locationName":"대관령","ta":"10.8"}
// {"locationName":"춘천","ta":"26.7"}
// {"locationName":"백령도","ta":"13.8"}
// ........ 등등  
// {"locationName":"밀양","ta":"24.7"}
// {"locationName":"산청","ta":"24.2"}
// {"locationName":"거제","ta":"21.0"}
// {"locationName":"남해","ta":"22.7"}}


String[] locationArr = {"서울","인천","수원","춘천","강릉","청주","홍성","대전","안동","포항","대구","전주","울산","부산","창원","여수","광주","목포","제주","울릉도","백령도"};
String result = "[";

for(String jsonObj : arr_str_jsonObjArr) {

for(int i=0; i<locationArr.length; i++) {
//  if( jsonObj.indexOf(locationArr[i]) >= 0 ) { // 북춘천,춘천,북강릉,강릉,북창원,창원이 있으므로  if(jsonObj.indexOf(locationArr[i]) >= 0) { 을 사용하지 않음 
if( jsonObj.substring(jsonObj.indexOf(":")+2, jsonObj.indexOf(",")-1).equals(locationArr[i]) ) { 
result += jsonObj+",";  // [{"locationName":"춘천","ta":"26.7"},{"locationName":"백령도","ta":"13.8"}, ..... {"locationName":"제주","ta":"18.9"}, 
break;
}
}
}// end of for------------------------------

result = result.substring(0, result.length()-1);  // [{"locationName":"춘천","ta":"26.7"},{"locationName":"백령도","ta":"13.8"}, ..... {"locationName":"제주","ta":"18.9"}
result = result + "]";                            // [{"locationName":"춘천","ta":"26.7"},{"locationName":"백령도","ta":"13.8"}, ..... {"locationName":"제주","ta":"18.9"}]

/*  확인용
System.out.println(result);
// [{"locationName":"춘천","ta":"26.7"},{"locationName":"백령도","ta":"13.8"},{"locationName":"강릉","ta":"18.4"},{"locationName":"서울","ta":"27.7"},{"locationName":"인천","ta":"23.8"},{"locationName":"울릉도","ta":"19.2"},{"locationName":"수원","ta":"26.5"},{"locationName":"청주","ta":"26.8"},{"locationName":"대전","ta":"26.4"},{"locationName":"안동","ta":"24.3"},{"locationName":"포항","ta":"19.4"},{"locationName":"대구","ta":"22.7"},{"locationName":"전주","ta":"26.3"},{"locationName":"울산","ta":"20.7"},{"locationName":"창원","ta":"21.9"},{"locationName":"광주","ta":"25.6"},{"locationName":"부산","ta":"22.0"},{"locationName":"목포","ta":"23.2"},{"locationName":"여수","ta":"23.0"},{"locationName":"홍성","ta":"25.0"},{"locationName":"제주","ta":"18.9"}]

*/
return result;
}
	
/*
@ExceptionHandler 에 대해서.....
==> 어떤 컨트롤러내에서 발생하는 익셉션이 있을시 익셉션 처리를 해주려고 한다면
    @ExceptionHandler 어노테이션을 적용한 메소드를 구현해주면 된다
     
   컨트롤러내에서 @ExceptionHandler 어노테이션을 적용한 메소드가 존재하면, 
   스프링은 익셉션 발생시 @ExceptionHandler 어노테이션을 적용한 메소드가 처리해준다.
   따라서, 컨트롤러에 발생한 익셉션을 직접 처리하고 싶다면 @ExceptionHandler 어노테이션을 적용한 메소드를 구현해주면 된다.
*/
@ExceptionHandler(java.lang.Throwable.class)
public void handleThrowable(Throwable e, HttpServletRequest request, HttpServletResponse response) {

e.printStackTrace(); // 콘솔에 에러메시지 나타내기

try {
   // *** 웹브라우저에 출력하기 시작 *** //
   
   // HttpServletResponse response 객체는 넘어온 데이터를 조작해서 결과물을 나타내고자 할때 쓰인다. 
   response.setContentType("text/html; charset=UTF-8");
   
   PrintWriter out = response.getWriter();   // out 은 웹브라우저에 기술하는 대상체라고 생각하자.
   
   out.println("<html>");
   out.println("<head><title>오류메시지 출력하기</title></head>");
   out.println("<body>");
   out.println("<h1>오류발생</h1>");
   
 //  out.printf("<div><span style='font-weight: bold;'>오류메시지</span><br><span style='color: red;'>%s</span></div>", e.getMessage());
   
   String ctxPath = request.getContextPath();
   
   out.println("<div><img src='"+ctxPath+"/resources/images/error.gif'/></div>");
   out.printf("<div style='margin: 20px; color: blue; font-weight: bold; font-size: 26pt;'>%s</div>", "장난금지");
   out.println("<a href='"+ctxPath+"/index.action'>홈페이지로 가기</a>");
   out.println("</body>");
   out.println("</html>");
   
   // *** 웹브라우저에 출력하기 끝 *** //
} catch (IOException e1) {
   e1.printStackTrace();
}

}

	/////////////////////////////////////////////////////////////////////////////////////////
		
	// === 로그인 또는 로그아웃을 했을 때 현재 보이던 그 페이지로 그대로 돌아가기  위한 메소드 생성 === //
	public void getCurrentURL(HttpServletRequest request) {
		HttpSession session = request.getSession();
		session.setAttribute("goBackURL", MyUtil.getCurrentURL(request));
	}	
	
	/////////////////////////////////////////////////////////////////////////////////////////
	
}
