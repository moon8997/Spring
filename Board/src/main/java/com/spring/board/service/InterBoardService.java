package com.spring.board.service;

import java.util.*;

import com.spring.board.model.*;

public interface InterBoardService {

	int test_insert();

	List<TestVO> test_select();

	int test_insert(Map<String, String> paraMap);

	int test_insert(TestVO vo);

	////////////////////////////////////////////////////////////////////////////
	
	// 시작페이지에서 메인 이미지를 보여주는 것 
	List<String> getImgfilenameList();

	// 로그인 처리하기 
	MemberVO getLoginMember(Map<String, String> paraMap);

	// 글쓰기(파일첨부가 없는 글쓰기) 
	int add(BoardVO boardvo);

	// 페이징 처리를 안한 검색어가 없는 전체 글목록 보여주기 
	List<BoardVO> boardListNoSearch();

	// 글조회수 증가와 함께 글1개를 조회를 해주는 것 
	BoardVO getView(Map<String, String> paraMap);

	// 글조회수 증가는 없고 단순히 글1개 조회만을 해주는 것이다.
	BoardVO getViewWithNoAddCount(Map<String, String> paraMap);

	// 1개글 수정하기 
	int edit(BoardVO boardvo);

	// 1개글 삭제하기 
	int del(Map<String, String> paraMap);

	// 댓글쓰기(transaction 처리)
	int addComment(CommentVO commentvo) throws Throwable;

	// 원게시물에 딸린 댓글들을 조회해오기
	List<CommentVO> getCommentList(String parentSeq);

	// BoardAOP 클래스에서 사용하는 것으로 특정 회원에게 특정 점수만큼 포인트를 증가하기 위한 것 
	void pointPlus(Map<String, String> paraMap);

	// == 페이징 처리를 안한 검색어가 있는 전체 글목록 보여주기 == //
	List<BoardVO> boardListSearch(Map<String, String> paraMap);

	// 검색어 입력시 자동글 완성하기
	List<String> wordSearchShow(Map<String, String> paraMap);

	// 총 게시물 건수(totalCount) 구하기  - 검색이 있을때와 검색이 업을때로 나뉜다
	int getTotalCount(Map<String, String> paraMap);

	// 페이징 처리한 글목록 가져오기(검색이 있든지, 없든지 모두 다 포함 한 것)
	List<BoardVO> boardListSearchWithPaging(Map<String, String> paraMap);

	// 원게시물에 딸린 댓글들을 페이징 처리에서 조회해오기(Ajax 로 처리) === //
	List<CommentVO> getCommentListPaging(Map<String, String> paraMap);

	// 원글 글번호(parentSeq) 여기에 해당하는 댓글 totalPage 수 알아오기
	int getCommentTotalPage(Map<String, String> paraMap);

	// 글쓰기(파일첨부가 있는 글쓰기)
	int add_withFile(BoardVO boardvo);

	// 댓글 1개를 조회해주는 것
	CommentVO getCommentOne(String seq); 
	
	// == #183. Spring Scheduler(스프링스케쥴러3) === //
	
	// === Spring Scheduler 를 사용하여 특정 URL 사이트로 연결하기 === 
	// !!<주의>!! Scheduler로 사용되는 메소드는 반드시 파라미터가 없어야 한다. !!!
	void branchTimeAlarm();
	
	
	// === Spring Scheduler 를 사용하여 email 발송하기 === 
    // <주의> 스케줄러로 사용되어지는 메소드는 반드시 파라미터가 없어야 한다.!!!!
    // 매일 새벽 4시 마다 고객이 예약한 2일전에 고객에게 예약이 있다는 e메일을 자동 발송 하도록 하는 예제를 만들어 본다. 
    // 고객들의 email 주소는 List<String(e메일주소)> 으로 만들면 된다.
    // 또는 e메일 자동 발송 대신에 휴대폰 문자를 자동 발송하는 것도 가능하다.     
    void reservationEmailSending() throws Exception;
	
	
}
