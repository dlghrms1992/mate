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
4. ck에디터 이미지 등록
//CKeditor 파일 업로드
	@RequestMapping(value = "/imageFileUpload.do", method = RequestMethod.POST)
	@ResponseBody
	public String fileUpload(HttpServletRequest request, HttpServletResponse response,
							 MultipartHttpServletRequest multiFile) throws Exception {
		request.setCharacterEncoding("utf-8");
		JsonObject json = new JsonObject();
		PrintWriter printWriter = null;
		OutputStream out = null;
		MultipartFile file = multiFile.getFile("upload");
		
		//파일이 넘어왔을 경우
		if(file != null) {
			if(file.getSize() > 0 ) {
				//이미지 파일 검사
				if(file.getContentType().toLowerCase().startsWith("image/")) {
					try {
						String fileName = Utils.getRenamedFileName(file.getOriginalFilename());
						byte[] bytes = file.getBytes();
						String uploadPath = request.getServletContext().getRealPath("/resources/upload/temp");
						File uploadFile = new File(uploadPath);
						if(!uploadFile.exists()) {
							uploadFile.mkdirs();
						}
						//String renamedFilename = Utils.getRenamedFileName(fileName);
						//uploadPath = uploadPath + "/" + fileName;
						out = new FileOutputStream(new File(uploadPath, fileName));
						out.write(bytes);
						
						printWriter = response.getWriter();
						response.setContentType("text/html");
						String fileUrl = request.getContextPath() + "/resources/upload/temp/" + fileName;
						
						//json 데이터로 등록
						json.addProperty("uploaded", 1);
						json.addProperty("fileName", fileName);
						json.addProperty("url", fileUrl);
						
						printWriter.println(json);
						
					} catch(IOException e) {
						e.printStackTrace();
					} finally {
						if(out != null)
							out.close();
						if(printWriter != null)
							printWriter.close();
					}
				}
			}
		}
		//파일이 넘어오지 않았을 경우
		return null;
	}
//5. ck에디터를 이용한 게시판 등록 
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
//6. 페이징 처리
		int numPerPage = 10;
		int pageBarSize = 5;
		Map<String, Object> param = new HashMap<>();
		Pagebar pb = new Pagebar(cPage, numPerPage, request.getRequestURI(), pageBarSize);
		if (status != null && !status.equals("")) {
			String[] st = status.split(",");
			param.put("status", st);
		}
		param.put("searchType", searchType);
		param.put("searchKeyword", searchKeyword);

		pb.setOptions(param);
		List<Map<String, Object>> list = erpService.empList(pb);
		String pageBar = pb.getPagebar();

		log.debug("list= {}", list);
		model.addAttribute("pageBar", pageBar);
//7. 페이징 클래스 
	private int cPage;
	private int numPerPage;
	private int totalContents;
	private String url;
	private int pageBarSize;
	
	private int totalPage;
	private int pageStart;
	private int pageEnd;
	private int pageNo;
	
	private int start;
	private int end;
	private Map<String, Object> options;
	
	public Pagebar(int cPage, int numPerPage, String url, int pageBarSize) {
		this.cPage = cPage;
		this.numPerPage = numPerPage;
		this.url = url;
		this.pageBarSize = pageBarSize;
	}
	
	public int getcPage() {
		return cPage;
	}

	public void setcPage(int cPage) {
		this.cPage = cPage;
	}

	public int getNumPerPage() {
		return numPerPage;
	}

	public void setNumPerPage(int numPerPage) {
		this.numPerPage = numPerPage;
	}

	public int getTotalContents() {
		return totalContents;
	}

	public void setTotalContents(int totalContents) {
		this.totalContents = totalContents;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public int getPageBarSize() {
		return pageBarSize;
	}

	public void setPageBarSize(int pageBarSize) {
		this.pageBarSize = pageBarSize;
	}

	public int getTotalPage() {
		return totalPage;
	}

	public void setTotalPage(int totalPage) {
		this.totalPage = totalPage;
	}
	
	public int getStart() {
		this.start = (this.cPage-1)*this.numPerPage +1;
		return this.start;
	}
	
	public int getEnd() {
		this.end = this.cPage*this.numPerPage;
		return this.end;
	}
	
	public void setOptions(Map<String, Object> options) {
		this.options = options;
	}
	
	public String getPagebar() {
		//url에 조건 추가
		this.url += "?";
		if(this.options != null && !this.options.isEmpty()) {
			for(String key : this.options.keySet()) {
				if(this.options.get(key) != null && !this.options.get(key).equals("")) {
					if(this.options.get(key).getClass().isArray()) {
						this.url += "&" + key + "=";
						String[] values = (String[])this.options.get(key);
						for(int i = 0; i < values.length ; i++) {
							this.url += values[i];
							if(i != values.length-1) this.url += ",";
						}
					}
					else {
						Object value = this.options.get(key);
						if( value instanceof Integer) {
							value = (int)this.options.get(key);
						}else if(value instanceof String) {
							value = (String)this.options.get(key);
						}
						
						this.url += "&" + key + "=" + value;
					}
				}
			}
		}
		this.totalPage = (int)(Math.ceil(new Double(this.totalContents)/this.numPerPage));
		this.pageStart = ((this.cPage-1) / this.pageBarSize) * this.pageBarSize + 1;
		this.pageEnd = (this.pageStart + this.pageBarSize) -1;
		this.pageNo = this.pageStart;
		
		StringBuilder pageBar = new StringBuilder();
		
		if(pageNo == 1) {
			
		}else {
			pageBar.append("<a href='"+this.url+"&cPage="+(this.pageNo-1)+"'>이전</a>\n");
		}
		
		//PageNo
		while(this.pageNo <= this.pageEnd && this.pageNo <= this.totalPage) {
			//현재페이지인 경우
			if(pageNo==cPage) {
				pageBar.append("<span class='cPage' style='background-color:#F2F2F2;'>"+this.pageNo+"</span>\n");
			}
			//현재페이지가 아닌경우
			else {
				pageBar.append("<a href='"+this.url+"&cPage="+this.pageNo+"'>"+this.pageNo+"</a>\n");
			}
			this.pageNo++;
			
		}
		
		//다음
		if(this.pageNo > this.totalPage ) {
			
		}else {
			pageBar.append("<a href='"+this.url+"&cPage="+this.pageNo+"'>다음</a>\n");
		}
		System.out.println(pageBar.toString());
		return pageBar.toString();
	}
