1. 로그인 화면 a태크 클릭시 toggle 함수

	$(function() {

		$('#login-form-link').click(function(e) {
			$("#login-form").delay(100).fadeIn(100);
			$("#register-form").fadeOut(100);
			$("#passwordForm").fadeOut(100);
			$('#register-form-link').removeClass('active');
			$(this).addClass('active');
			e.preventDefault();
		});
		$('#register-form-link').click(function(e) {
			$("#register-form").delay(100).fadeIn(100);
			$("#login-form").fadeOut(100);
			$("#passwordForm").fadeOut(100);
			$('#login-form-link').removeClass('active');
			$(this).addClass('active');
			e.preventDefault();
		});

		$('#passwordFinderA').click(function(e) {
			$("#passwordForm").delay(100).fadeIn(100);
			$("#register-form").fadeOut(100);
			$("#login-form").fadeOut(100);
			$('#login-form-link').removeClass('active');	
			$(this).addClass('active');
			e.preventDefault();
		});
		$('#password-form-link').click(function(e) {
			$("#login-form").delay(100).fadeIn(100);
			$("#passwordForm").fadeOut(100);
			$("#register-form").fadeOut(100);
			$('#login-form-link').removeClass('active');
			$(this).addClass('active');
			e.preventDefault();
		});
		
		if(${ not empty snsMember }){
			
			$("#register-form").delay(100).fadeIn(100);
			$("#login-form").fadeOut(100);
			$('#login-form-link').removeClass('active');
			$("#register-form").addClass('active');
			
		}
		
	});

2. 회원가입시 문자인증 ajax처리 및 인증완료 처리
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
// 인증번호 유효성 검사 처리
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
		
	};

	function check(){
		 var $frm = $("#register-form");
		 var $phone = $("#phone-send").val();

		 if($phone == '문자인증'){
			alert("핸드폰 인증을 해주세요");
		}else{
			$frm.submit();
		}
	}

3. SNS 로그인 및 회원가입 controller 처리
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
		
// Database에 정보가 없다면 회원가입 페이지로 이동 후 자동 입력
		Member member = memberService.selectOneMember((String)responseOBJ.get("email"));
		if( member == null || member.getMemberId() == null) {
			model.addAttribute("snsMember", map);
			return "member/login";
		}else {
			
			log.debug("map = {}", map);
			session.setAttribute("loginMember", member);
			return "redirect:/";
			
		}	

	}