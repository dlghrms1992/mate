<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>상품추가</title>
</head>
<body>

	<div>
		<form action="">
			
			<label>상품명</label>
			<input type="text" placeholder="상품명"/>
			<br />
			<label>브랜드</label>
			<select class="brand">
			  <option selected>브랜드</option>
			  <option value="1">One</option>
			  <option value="2">Two</option>
			  <option value="3">Three</option>
			</select>
			<br />
			<label>카테고리</label>
			<select class="category">
			  <option selected>카테고리 선택</option>
			  <option value="1">One</option>
			  <option value="2">Two</option>
			  <option value="3">Three</option>
			</select>
			<br />
			<label>가격</label>
			<input type="number" name="price" id="price" />
			<br />
			<input type="submit" value="등록" />
			 
		</form>
	</div>

</body>
</html>