# 마사지1004 지역별 이미지 자동 적용 스크립트
# 이 파일은 massage1004-site 폴더 안에서 실행하세요.

$cssPath = ".\style.css"

if (Test-Path $cssPath) {
  $css = Get-Content $cssPath -Raw -Encoding UTF8

  if ($css -notmatch "site-image-box") {
@"

.site-image-box {
  max-width: 760px;
  margin: 34px auto;
  padding: 10px;
  border-radius: 26px;
  background: linear-gradient(135deg, rgba(212, 175, 55, 0.22), rgba(255, 255, 255, 0.04));
  border: 1px solid rgba(212, 175, 55, 0.32);
  box-shadow: 0 22px 55px rgba(0, 0, 0, 0.45);
}

.site-image-box img {
  width: 100%;
  display: block;
  border-radius: 20px;
}
"@ | Add-Content -Path $cssPath -Encoding UTF8
  }
}

# 메인 페이지 이미지 적용
$rootPath = ".\index.html"
if ((Test-Path $rootPath) -and (Test-Path ".\images\main.png")) {
  $html = Get-Content $rootPath -Raw -Encoding UTF8
  $html = $html -replace '(?s)\s*<div class="site-image-box">\s*<img[^>]*>\s*</div>\s*', "`n"
  $block = @"

<div class="site-image-box">
  <img src="images/main.png" alt="마사지1004 메인 안내 이미지" />
</div>

"@
  $regex = [regex]'(<section class="section)'
  $html = $regex.Replace($html, $block + '$1', 1)
  Set-Content -Path $rootPath -Value $html -Encoding UTF8
  Write-Host "메인 페이지 이미지 적용 완료"
}

# 지역 페이지 이미지 적용: 폴더명과 같은 이미지 사용
Get-ChildItem -Directory | Where-Object { $_.Name -ne "images" } | ForEach-Object {
  $name = $_.Name
  $path = ".\$name\index.html"

  if (Test-Path $path) {
    $imageFile = $null

    foreach ($ext in @("png","jpg","jpeg","webp")) {
      if (Test-Path ".\images\$name.$ext") {
        $imageFile = "$name.$ext"
        break
      }
    }

    if ($imageFile) {
      $html = Get-Content $path -Raw -Encoding UTF8
      $html = $html -replace '(?s)\s*<div class="site-image-box">\s*<img[^>]*>\s*</div>\s*', "`n"

      $block = @"

<div class="site-image-box">
  <img src="../images/$imageFile" alt="$name 안내 이미지" />
</div>

"@

      $regex = [regex]'(<section class="section)'
      $html = $regex.Replace($html, $block + '$1', 1)
      Set-Content -Path $path -Value $html -Encoding UTF8
      Write-Host "$name 페이지에 $imageFile 적용 완료"
    } else {
      Write-Host "$name 이미지 없음 - 건너뜀"
    }
  }
}
