$files = Get-ChildItem -Path "outputs" -Filter "*.html"

$langHtml = @'
    <div class="lang-switcher" data-language-switcher>
      <button class="lang-toggle" type="button" aria-haspopup="true" aria-expanded="false" aria-label="Change language">
        <span class="lang-globe" aria-hidden="true">&#127760;</span>
        <span class="lang-current">EN</span>
      </button>
      <div class="lang-menu" role="menu" aria-label="Language selector">
        <a class="lang-item" data-lang="en" href="/en/" role="menuitem"><span>English</span><small>EN</small></a>
        <a class="lang-item" data-lang="es" href="/es/" role="menuitem"><span>Espa&ntilde;ol</span><small>ES</small></a>
        <a class="lang-item" data-lang="ru" href="/ru/" role="menuitem"><span>&#1056;&#1091;&#1089;&#1089;&#1082;&#1080;&#1081;</span><small>RU</small></a>
        <a class="lang-item" data-lang="ar" href="/ar/" role="menuitem"><span>&#1575;&#1604;&#1593;&#1585;&#1576;&#1610;&#1577;</span><small>AR</small></a>
        <a class="lang-item" data-lang="fr" href="/fr/" role="menuitem"><span>Fran&ccedil;ais</span><small>FR</small></a>
        <a class="lang-item" data-lang="pt" href="/pt/" role="menuitem"><span>Portugu&ecirc;s</span><small>PT</small></a>
      </div>
    </div>
'@

foreach ($file in $files) {
  $content = Get-Content -Path $file.FullName -Raw
  $content = [regex]::Replace(
    $content,
    '(?s)<div class="lang-switcher" data-language-switcher>.*?</div>\s*<a class="quote"',
    $langHtml + "`r`n    <a class=""quote""",
    1
  )
  Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
