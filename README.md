# Final-Project
## 작성자 : 이호근

### 팀원
* 이호근 
* 박준혁 
* 박도균
* 김가영
* 김종완
* 김찬희

------------------------
## 프로젝트 기획 이유
>  연 평균 3% 이상의 성장을 하고 있는 키덜트 시장
>  상품의 품목이 많은 만큼 재고관리를 해야하는 것은 필수적이다.
>  상품 관리가 가능한 ERP 시스템을 구축하고, 지점과 제조사와 소통으로 게시판에 요청 및 신상품 홍보를 하며
>  재고 관리에 더욱 효율적으로 할 수 있게 구현 해봤습니다.
>  온라인 뿐만 아니라 오프라인 지점도 있다해서, 오프라인과 쇼핑몰의 소통 믹 재고관리도 할 수 있게 구현함
--------------------------
## 개발 환경
* OS : Windows 10
* DBMS/Server : Oracle 11, Tomcat 8.5
* Framework/PlatForm : Mybatis, Bootstrap, Maven, jQuery, MVC Spring
* 개발 언어 : JAVA, JSP, JavaScript, SQL, HTML
* 개발 도구 : SpringToolSuite4, SQL Developer

------------------------
## 주요 테이블
* MEMBER ( 쇼핑몰 회원 관리 테이블 )
  * 쇼핑몰 회원 정보가 관리되는 테이블
  * MEMBER_ID COLUMN을 Primary key로 사용
* EMP ( 관리자 회원 관리 테이블 )
  * ERP 시스템 사용자 정보가 관리되는 테이블
  * EMP_ID COLUMN을 Primary key로 사용
  * STATUS값으로 지점, 제조사, admin회원을 구분할 수 있다. ( 0 = admin, 1 = 지점, 2 = 제조사 )
 
* PRODUCT ( 상품 정보 관리 테이블 )
  * 취급 상품 정보가 관리되는 테이블
  * PRODUCT_NO COLUMN을 Primary key로 사용
  * ENABLED COLUMN값으로 판매 상태를 결정하도록 한다. ( '0'일 경우 판매, '1'일 경우 판매 중지)

* STOCK ( 상품 재고 관리 테이블 )
  * 각 지점 별 취급 상품의 재고를 관리하는 테이블
  * 각 지점에서 판매를 원하는 상품을 발주시 해당 테이블에 상품의 정보가 입력되며 재고 관리가 가능하게된다.
  * PRODICT_ID와 EMP_ID를 Primary key로 사용

* REQUEST_LOG ( 발주 요청 관리 테이블 )
  * 지점에서 신청한 발주 요청을 관리하는 테이블
  * REQUEST_NO COLUMN을 Primary key로 사용
  *제조사 회원이 발주 승인시 CONFIRM COLUMN 값이 '1'로 update되며 동시에 입고 로그 테이블에 해당 상품 정보가 입력되는 Trigger가 실행된다.

* RECEIVE ( 입고 요청 관리 테이블 )
  * 제조사 회원이 발주 요청 승인 시, 실행되는 Trigger에 의해 입고 요청 정보가 입력되는 테이블
  * RECEIVE_NO COLUMN을 Primary key로 사용
  * 지점 회원이 입고 요청 목록을 확인 후, 승인 시 CONFIRM COLUMN 값이 '1'로 update되며 입출고 로그 테이블에 기록되는 Trigger가 실행된다.
  * 입출고 로그 테이블에 입력이 감지되면 그 상태값이 'I'일 경우, 해당 상품과 지점 정보를 통해 상품 재고 테이블의 재고를 update는 Trigger가 실행되며 재고 관리가 가능하다.
-------------------------------------------------------------------------------------
## 주요 기능(작성자 본인이 구현 기능 이주로 작성되었습니다.) 

### 1. 로그인 기능 (로그인 API[카카오,네이버])
  * 일반 로그인과 SNS 로그인을 할 수 있는 두 가지 방법이있다. 일반 로그인은 회원가입 toggle-tab에서 문자인증을 하면 
  * 회원 가입을 하고 일반 로그인을 하면 되는 것이고, SNS 로그인은 회원 가입 이력이 없다면 각 SNS기능에서 로그인 했을 시 
  * 회원 가입 toggle-tab으로 아이디, 비밀번호, 이름,성별 등을 제외하고, "핸드폰 인증"만 하면 가입이 된다.
  * 가입을 하고 다음에 로그인을 했을 시 연동되어있는 계정으로 로그인이 된다.
  ```java
     // naverLogin 성공시
   @RequestMapping(value = "/callback.do", method = { RequestMethod.GET, RequestMethod.POST })
   public String callback(Model model, @RequestParam String code, @RequestParam String state, HttpSession session)
     throws IOException, ParseException, java.text.ParseException {
          OAuth2AccessToken oauthToken;
          oauthToken = naverLoginBO.getAcessToken(session, code, state);
          log.debug("oauthToken = {}", oauthToken);

          apiResult = naverLoginBO.getUserProfile(oauthToken);

          JSONParser parser = new JSONParser();
          Object obj = parser.parse(apiResult);
          JSONObject jsonObj = (JSONObject) obj;

          JSONObject responseOBJ = (JSONObject) jsonObj.get("response");

          // 자동 회원가입 되게 하기.
          Map<String, Object> map = new HashMap<>();
          map.put("memberPWD", (String) responseOBJ.get("id"));
          map.put("memberName", (String) responseOBJ.get("name"));
          map.put("gender", (String) responseOBJ.get("gender"));
          map.put("memberId", (String) responseOBJ.get("email"));

          Member member = memberService.selectOneMember((String)responseOBJ.get("email"));
          // 요청 email 회원 유효성 검사
          if( member == null || member.getMemberId() == null) {
           model.addAttribute("snsMember", map);
           return "member/login";
          }else {
          // 가입이 되어있다면 세션 값 
           session.setAttribute("loginMember", member);
           return "redirect:/";

          }	

   }

  ```

### 2. 문자 인증 기능(Coolms API)
   * 회원가입이나 비밀번호 찾기를 할 때 필수적인 요소인 문자인증 시스템이다.
   * 기존의 랜덤함수를 선언하고 핸드폰 번호를 입력하면 해당 번호로 랜덤 숫자 6개를 리턴해주게 된다.
   * 다시 모달창을 띠워 리턴 받은 6개의 숫자를 상대방의 문자의 내용의 숫자와 비교한다.
   * 결과 값이 일치하면 1로 일치하지 않으면 0으로 리턴하게 된다.
   ```javascript
   // 문자인증 검사
    $(function() {
       $("#phone-send").click(function(){
        var $phone = $("#phone").val();
        console.log($phone);
        if(typeof $phone == "undefined" || $phone == ""){
         alert("핸드폰 번호를 입력하세요");
         return false;
        }
        $.ajax({
         url:"${ pageContext.request.contextPath}/member/phoneSend.do",
         data:{
          receiver: $phone
         },
         dataType:"json",
         method: "post",
         success: function(data){
           var $num = $("#MocheckNum_").html(data);
           console.log(data);						
           openModal(data);		
         },
         error: function(xhr, status, err){
           console.log(xhr);
           console.log(status);
           console.log(err);
         }
        }); 

       });
  });
   ```
    
   ```java
   // 요청 번호로 문자 전송
     @ResponseBody
      @PostMapping("/member/phoneSend.do")
       public String PhoneSend(@RequestParam("receiver") String phone) {
          log.debug("phone = {}", phone);
          String apiKey = "NCSMEQ9SPX8T4FEH";
          String apiSecret = "RXFWNUW0XYKAATDX5WPNYE0PGPL9VOHH";
          Message coolsms = new Message(apiKey,apiSecret);

          HashMap<String, String> map = new HashMap<>();
          Random rnd = new Random();
          String checkNum = "";

          for(int i = 0 ; i < 6 ; i++) {			
           String ran = Integer.toString(rnd.nextInt(10));
           checkNum += ran;
          }

          map.put("type", "SMS");
          map.put("to", phone);
          map.put("from", "01026596065");
          map.put("text", "본인확인"
              +"인증번호(" + checkNum+ ")입력시 정상처리 됩니다.");	

          log.debug("map = {}", map);
          try {
           JSONObject obj = (JSONObject) coolsms.send(map);
          } catch (CoolsmsException e) {
           e.printStackTrace();
          }

          return checkNum;
       }
     
   ```
   ```javascrpit
   //인증 번호 
     function phoneCheck(){
		
       var num = $("#MophoneNum_").val();
       var num2 = 	$("#MocheckNum_").val();
       console.log(num);
       if(num != num2){
        alert("인증번호가 다릅니다.");

       }else {
        alert("인증 되었습니다.");
        $("#phone-send").val("인증완료").prop("disabled", "disabled");
        $("#myModal").removeClass("show");
        closeReturnModal();
		 }
   ```
### 3. 게시판(고객센터)
  * 회원들이 불량 및 반품 그리고 요구사항을 처리할 수 있는 게시판이다. 일반 회원들은 게시글을 올릴때 
  * 자기자신만 올릴 수 있는 비밀글 기능과 자신이 올렸던 글을 확인할 수 있는 내글 보기 기능들이 있다.
  * 일반 회원들은 댓글은 달지 못하지만, 관리자만의 게시글에 대한 댓글을 등록 할 수 있다.
  * 그리고 게시글의 페이징 처리를 해두어 게시글 목록의 가독성을 더 높였다.
  ```javascript
  // 내글만 보기 function
  $(function() {
    $("input:checkbox[id='csMyListFrm']").change(function() {
     console.log($(this).val());
     var checked = $(this);
     var memberId = $(this).val();
     var $frm = $("#csMyListFrm");
     if (this.checked) {
      $frm.submit();
      $("input:checkbox[id='csMyListFrm']").prop("checked", true);
     } else {
      location.href = "${ pageContext.request.contextPath}/cs/cs.do";
     }

    });

    $(".notice").css("background-color","rgba(164, 80, 68, 0.2)");
	});
  ```javascript
  // 비밀글 설정 했을 시 본인과 관리자를 구분해주는 유효성 검사
  $(function() {
		$("tr[data-no]")
			.click(
				function() {
					var csNo = $(this).attr("data-no");
					var memberId = $(this).find(".csMemberId").text();
					var secret = $(this).find(".secret").text();
					var loginMember = '${ loginMember.memberId}';

					console.log(secret);
					console.log(memberId);
					console.log(loginMember);

					if (secret == '1' && loginMember != 'admin'
							&& loginMember != memberId) {

						alert("비밀글 입니다. 본인만 확인 할 수 있다.");
						return;
					}

					location.href = "${ pageContext.request.contextPath }/cs/csDetail.do?csNo="
							+ csNo;

				});
	});
  ```
### 4. 게시판(ERP)
 * 관리자 ERP 페이지에서 제조사/지점/관리자가 이용할 수 있는 게시판이다. 
 * 제조사는 자신의 신상품을 홍보 할 수 있다. 지점은 상품 재고가 부족하면 부족한 상품의 고유번호를 등록하고 게시판의 글을 등록하면 타지점
 * 해당 재조사가 있다고 알려준 후 사후처리를 할 수 있게 처리했다.
 * 관리자는 공지사항 및 전반 적인 게시판을 이용 할 수 있다.
 * 이 때 내용은 Ckeditor를 통해 입력받도록 API를 적용시켜두었으며, 본문에 들어갈 이미지는 별도의 테이블에 보관된다.
 * 마지막으로 게시글을 읽게 되면 쿠키값에 저장해서 비교하는 조회수 처리를 해 두었다.
 ```java
  @PostMapping("/ERP/empBoardCkEnroll.do")
  public String empBoardCKEnroll(RedirectAttributes redirectAttr, EmpBoard empBoard, EMP emp,
     @RequestParam(value = "content", defaultValue = "내용을 입력해 주세요") String content,
     @RequestParam("imgDir") String imgDir, HttpServletRequest request, Model model,
     @RequestParam("upFile") MultipartFile[] upFiles) throws IllegalStateException, IOException {

    if (!content.equals("내용을 입력해 주세요.")) {
     String repCont = content.replaceAll("temp", imgDir);
     empBoard.setContent(repCont);
    }

    List<EmpBoardImage> empBoardImageList = new ArrayList<>();
    String saveDirectory = request.getServletContext().getRealPath("/resources/upload/empBoard");
    for (MultipartFile upFile : upFiles) {

     if (upFile.isEmpty()) {
      continue;
     } else {
      String renamedFilename = Utils.getRenamedFileName(upFile.getOriginalFilename());
      File dest = new File(saveDirectory, renamedFilename);
      upFile.transferTo(dest);
      EmpBoardImage empBoardImage = new EmpBoardImage();
      empBoardImage.setOriginalFilename(upFile.getOriginalFilename());
      empBoardImage.setRenamedFilename(renamedFilename);
      empBoardImageList.add(empBoardImage);
     }

    }
    log.debug("empBoardImageList = {}", empBoardImageList);
    empBoard.setEmpBoardImageList(empBoardImageList);
    empBoard.setEmpId(emp.getEmpId());

    log.debug("empBoard = {}", empBoard);

    int result = erpService.insertEmpBoard(empBoard);

    String tempDir = request.getServletContext().getRealPath("/resources/upload/temp");
    // ProductImage 저장 폴더
    String realDir = request.getServletContext().getRealPath("/resources/upload/" + imgDir);
    File folder1 = new File(tempDir);
    File folder2 = new File(realDir);

    // file입력 처리 -> DB에 image등록과 동시에 fileDir옮기기
    if (result > 0) {
     // folder1의 파일 -> folder2로 복사
     FileUtils.fileCopy(folder1, folder2);
     // folder1의 파일 삭제
     FileUtils.fileDelete(folder1.toString());
     redirectAttr.addFlashAttribute("msg", "게시글 등록 성공");
    } else {
     // folder1의 파일 삭제
     FileUtils.fileDelete(folder1.toString());
     redirectAttr.addFlashAttribute("msg", "게시글 등록 실패");
    }

    return "redirect:/ERP/EmpBoardList.do";
  }
 ```
 ```java
 //조회수 처리
		Cookie[] cookies = request.getCookies();
		String boardCookieVal = "";
		boolean hasRead = false;

		if (cookies != null) {
			for (Cookie c : cookies) {
				String name = c.getName();
				String value = c.getValue();

				if ("erpBoardCookie".equals(name)) {
					boardCookieVal = value;
				}

				if (value.contains("[" + no + "]")) {
					hasRead = true;
					break;
				}
			}
		}

		if (hasRead == false) {
			Cookie erpBoardCookie = new Cookie("erpBoardCookie", boardCookieVal + "[" + no + "]");
			erpBoardCookie.setMaxAge(365 * 24 * 60 * 60);
			erpBoardCookie.setPath(request.getContextPath() + "/ERP/EmpBoardDetail.do");
			response.addCookie(erpBoardCookie);
		}
  
  //service단에서 유효성 검사를 처리했다.
  	@Override
   public EmpBoard selectOneEmpBoard(int no, boolean hasRead) {
     int result = 0;
     if (hasRead == false) {
      result = erpDAO.increaseReadCount(no);
     }

     return erpDAO.selectOneEmpBoard(no);
   } 
 ```
### 5. 관리자의 회원 관리(회원 검색, 삭제)
    * 관리자는 회원 검색 및 삭제만 구현했다.
    * 삭제 테이블에 Trigger로 회원 삭제가 됬을 시 삭제된 회원을 관리하는 연산을 구현해 놓았다.

### 6. ERP 현황보기(발주, 입고,재고관리 지점/제조사관리 페이지의 검색 및 페이징 처리)
    * 관리자페이지에서 리스트 불러오기 및 검색 및 페이징 처리를 구현했다.
 
### 7. 회원 정보 수정 및 탈퇴
    * 유저 마이페이지에서 패스워드를 검사를 성공 했을시 수정 및 삭제를 구현했다.
---------------------------------------
## 이 외 구현 기능
  * 오프라인 지점 위치보기
  * 상품 검색시 요청 키워드 필터링
  * 상품 추가 및 삭제
  * 상품 구매 및 장바구니 추가
  * 제조사 등록 및 수정 삭제
