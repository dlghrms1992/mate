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
  ```
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
          // 요청 email 회원 유효성 
          if( member == null || member.getMemberId() == null) {

           log.debug("naverMap = {}", map);
           model.addAttribute("snsMember", map);
           return "member/login";
          }else {

           log.debug("map = {}", map);
           session.setAttribute("loginMember", member);
           return "redirect:/";

          }	

   }

  ```

### 2. 문자 인증 기능(Coolms API)

### 3. 게시판(고객센터)

### 4. 게시판(ERP)




