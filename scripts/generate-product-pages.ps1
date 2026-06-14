param(
  [Parameter(Mandatory = $true)]
  [string]$SourceRoot
)

$ErrorActionPreference = "Stop"

$workspace = "C:\Users\kodiak\Documents\Codex\2026-06-13\files-mentioned-by-the-user-product"
$outputRoot = Join-Path $workspace "outputs"
$assetRoot = Join-Path $outputRoot "assets\products"
$sourceRoot = $SourceRoot

function Ensure-Directory {
  param([string]$Path)
  if (-not (Test-Path $Path)) {
    New-Item -ItemType Directory -Path $Path | Out-Null
  }
}

function Copy-AssetSet {
  param(
    [hashtable]$Product
  )

  $targetDir = Join-Path $assetRoot $Product.slug
  Ensure-Directory $targetDir

  $mainFiles = @()
  $index = 1
  foreach ($src in $Product.mainImages) {
    if (Test-Path $src) {
      $ext = [System.IO.Path]::GetExtension($src)
      $name = "main-$index$ext"
      $dest = Join-Path $targetDir $name
      Copy-Item -LiteralPath $src -Destination $dest -Force
      $mainFiles += "assets/products/$($Product.slug)/$name"
      $index++
    }
  }

  $detailFiles = @()
  $index = 1
  foreach ($src in $Product.detailImages) {
    if (Test-Path $src) {
      $ext = [System.IO.Path]::GetExtension($src)
      $name = "detail-$index$ext"
      $dest = Join-Path $targetDir $name
      Copy-Item -LiteralPath $src -Destination $dest -Force
      $detailFiles += "assets/products/$($Product.slug)/$name"
      $index++
    }
  }

  return @{
    mainFiles = $mainFiles
    detailFiles = $detailFiles
  }
}

function Render-Specs {
  param([array]$Specs)
  return (($Specs | ForEach-Object {
@"
            <div>
              <span>$($_.label)</span>
              <strong>$($_.value)</strong>
            </div>
"@
  }) -join "")
}

function Render-Chips {
  param([array]$Items)
  return (($Items | ForEach-Object { "<span>$($_)</span>" }) -join "")
}

function Render-Thumbs {
  param([array]$MainFiles, [string]$Title)
  $index = 0
  return (($MainFiles | ForEach-Object {
    $active = if ($index -eq 0) { " class=`"is-active`"" } else { "" }
    $html = "<img$active src=`"$_`" data-large=`"$_`" alt=`"$Title view $($index + 1)`" />"
    $index++
    $html
  }) -join "")
}

function Render-DetailImages {
  param([array]$DetailFiles, [string]$Title)
  $index = 1
  return (($DetailFiles | ForEach-Object {
    $html = "<img src=`"$_`" alt=`"$Title detail image $index`" />"
    $index++
    $html
  }) -join "`n          ")
}

function Render-FAQ {
  param([array]$Faqs)
  return (($Faqs | ForEach-Object {
@"
          <article class="faq-card">
            <h3>$($_.q)</h3>
            <p>$($_.a)</p>
          </article>
"@
  }) -join "")
}

function Render-Related {
  param([array]$Related)
  return (($Related | ForEach-Object {
@"
          <article class="related-card">
            <a href="$($_.href)"><img src="$($_.image)" alt="$($_.title)" /></a>
            <h3><a href="$($_.href)">$($_.title)</a></h3>
            <p>$($_.text)</p>
          </article>
"@
  }) -join "")
}

function Render-Page {
  param(
    [hashtable]$Product,
    [array]$MainFiles,
    [array]$DetailFiles
  )

  if (-not $MainFiles -or $MainFiles.Count -eq 0) {
    $MainFiles = @("assets/categories/$($Product.category)-cables.jpg")
  }
  if (-not $DetailFiles -or $DetailFiles.Count -eq 0) {
    $DetailFiles = @($MainFiles[0])
  }

  $mainImage = $MainFiles[0]
  $thumbs = Render-Thumbs -MainFiles $MainFiles -Title $Product.title
  $specHtml = Render-Specs -Specs $Product.specs
  $chips = Render-Chips -Items $Product.chips
  $detailHtml = Render-DetailImages -DetailFiles $DetailFiles -Title $Product.title
  $faqHtml = Render-FAQ -Faqs $Product.faqs
  $relatedHtml = Render-Related -Related $Product.related

@"
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>$($Product.title) | APPACS</title>
  <meta name="description" content="$($Product.metaDescription)" />
  <style>
    :root {
      --green: #19b85a;
      --green-2: #30e47f;
      --dark: #06100c;
      --dark-2: #0d1814;
      --text: #111816;
      --muted: #68746e;
      --line: #dfe7e2;
      --paper: #f5f8f6;
      --white: #fff;
      --shadow: 0 24px 70px rgba(6,16,12,.14);
    }
    * { box-sizing: border-box; }
    html { scroll-behavior: smooth; }
    body { margin: 0; background: var(--paper); color: var(--text); font-family: "Segoe UI", Arial, sans-serif; }
    a { color: inherit; text-decoration: none; }
    img { max-width: 100%; display: block; }
    .nav {
      width: min(1180px, calc(100% - 48px));
      height: 74px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 28px;
      padding: 0 18px 0 22px;
      background: rgba(7,17,13,.72);
      color: #fff;
      position: sticky;
      top: 14px;
      z-index: 10;
      margin: 14px auto -88px;
      border: 1px solid rgba(255,255,255,.16);
      border-radius: 18px;
      box-shadow: 0 24px 70px rgba(0,0,0,.28);
      backdrop-filter: blur(18px) saturate(140%);
    }
    .brand { display: flex; align-items: center; gap: 13px; font-weight: 900; font-size: 22px; }
    .brand img { width: 42px; height: 42px; border-radius: 7px; }
    .nav-links { height: 100%; display: flex; align-items: center; justify-content: center; gap: 6px; color: rgba(255,255,255,.78); font-size: 14px; }
    .nav-links > a { height: 42px; display: inline-flex; align-items: center; padding: 0 13px; border-radius: 999px; }
    .nav-links > a:hover { background: rgba(255,255,255,.09); color: #fff; }
    .quote { padding: 13px 21px; background: var(--green); color: #041008; border-radius: 6px; font-weight: 800; }
    .hero {
      padding: 158px 62px 70px;
      background:
        linear-gradient(105deg, rgba(6,16,12,.98) 0%, rgba(6,16,12,.91) 54%, rgba(18,89,49,.72) 100%),
        url("$mainImage") center/cover;
      color: #fff;
    }
    .breadcrumb { max-width: 1180px; margin: 0 auto 28px; color: rgba(255,255,255,.62); font-size: 14px; }
    .breadcrumb span { color: #fff; }
    .product-hero {
      max-width: 1180px; margin: 0 auto; display: grid; grid-template-columns: minmax(360px, .95fr) minmax(360px, .85fr);
      gap: 54px; align-items: start;
    }
    .gallery { display: grid; grid-template-columns: 84px 1fr; gap: 14px; }
    .thumbs { display: grid; gap: 12px; }
    .thumbs img {
      width: 84px; height: 84px; object-fit: cover; border-radius: 14px; background: #fff; border: 2px solid transparent; cursor: pointer;
      box-shadow: 0 14px 28px rgba(6,16,12,.08);
    }
    .thumbs img.is-active { border-color: var(--green); }
    .main-frame {
      min-height: 510px; display: grid; place-items: center; background: rgba(255,255,255,.96); border-radius: 24px;
      padding: 32px; box-shadow: var(--shadow);
    }
    .main-frame img { max-height: 440px; object-fit: contain; }
    .info-card {
      background: rgba(255,255,255,.94); border-radius: 24px; padding: 32px; box-shadow: var(--shadow);
    }
    h1 { margin: 0; font-size: 58px; line-height: .98; letter-spacing: -.03em; color: #13201b; }
    .intro { margin: 18px 0 0; color: var(--muted); font-size: 18px; line-height: 1.65; }
    .chips { display: flex; flex-wrap: wrap; gap: 10px; margin: 22px 0 0; }
    .chips span {
      padding: 9px 12px; border-radius: 999px; background: #ecf8f1; color: #0c8040; font-size: 12px; font-weight: 800;
      border: 1px solid #d5efe0;
    }
    .spec-grid {
      display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 0; margin-top: 28px; border: 1px solid var(--line);
      border-radius: 18px; overflow: hidden;
    }
    .spec-grid div { padding: 18px 20px; background: #fff; border-right: 1px solid var(--line); border-bottom: 1px solid var(--line); }
    .spec-grid div:nth-child(2n) { border-right: 0; }
    .spec-grid div:nth-last-child(-n+2) { border-bottom: 0; }
    .spec-grid span { display: block; color: var(--muted); font-size: 12px; font-weight: 800; letter-spacing: .08em; text-transform: uppercase; }
    .spec-grid strong { display: block; margin-top: 8px; font-size: 28px; line-height: 1.18; color: #12211b; }
    .cta-row { display: flex; gap: 14px; margin-top: 28px; }
    .btn {
      min-width: 158px; padding: 15px 22px; border-radius: 8px; font-weight: 900; display: inline-flex; align-items: center; justify-content: center;
    }
    .btn.primary { background: linear-gradient(135deg, var(--green), var(--green-2)); color: #051109; }
    .btn.secondary { border: 1px solid #cad8d1; color: #13201b; background: rgba(255,255,255,.9); }
    section { padding: 72px 62px; }
    .section-inner { max-width: 1180px; margin: 0 auto; }
    .section-head { max-width: 760px; margin: 0 auto 34px; text-align: center; }
    .section-head h2 { margin: 0; font-size: 46px; line-height: 1.04; letter-spacing: -.03em; }
    .section-head p { margin: 16px 0 0; color: var(--muted); line-height: 1.65; font-size: 17px; }
    .detail-strip { display: grid; grid-template-columns: .9fr 1.1fr; gap: 28px; align-items: center; }
    .detail-media img { border-radius: 24px; box-shadow: var(--shadow); background: #fff; }
    .timeline { display: grid; gap: 18px; margin-top: 24px; }
    .timeline div { background: #fff; border: 1px solid var(--line); border-radius: 18px; padding: 20px; }
    .timeline h3 { margin: 0 0 8px; font-size: 24px; }
    .muted { color: var(--muted); line-height: 1.7; }
    .detail-gallery { display: grid; gap: 18px; }
    .detail-gallery img { width: 100%; border-radius: 22px; background: #fff; box-shadow: var(--shadow); }
    .dark { background: #07120e; color: #fff; }
    .dark .section-head p { color: rgba(255,255,255,.7); }
    .faq-grid, .related-grid, .oem-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 18px; }
    .faq-card, .related-card, .oem-card {
      background: rgba(255,255,255,.08); border: 1px solid rgba(255,255,255,.12); border-radius: 20px; padding: 22px;
    }
    .related-card { background: #fff; color: var(--text); border: 1px solid var(--line); }
    .related-card img { border-radius: 14px; margin-bottom: 14px; background: #f5f8f6; }
    .related-card h3, .faq-card h3, .oem-card h3 { margin: 0 0 10px; font-size: 22px; line-height: 1.18; }
    .faq-card p, .related-card p, .oem-card p { margin: 0; line-height: 1.65; color: inherit; }
    .inquiry { background: linear-gradient(180deg, #f5f8f6, #eef5f1); }
    .inquiry-wrap {
      max-width: 1180px; margin: 0 auto; display: grid; grid-template-columns: .78fr 1.22fr; gap: 22px; align-items: start;
      background: #fff; border-radius: 28px; padding: 28px; box-shadow: var(--shadow);
    }
    form { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
    input, select, textarea {
      width: 100%; padding: 14px 16px; border: 1px solid var(--line); border-radius: 12px; font: inherit; background: #fff; color: var(--text);
    }
    textarea { min-height: 124px; grid-column: 1 / -1; resize: vertical; }
    button {
      width: fit-content; padding: 15px 24px; border: 0; border-radius: 8px; font: inherit; font-weight: 900; color: #051109;
      background: linear-gradient(135deg, var(--green), var(--green-2)); cursor: pointer;
    }
    footer {
      display: grid; grid-template-columns: 1.3fr 1fr 1fr 1fr 1fr; gap: 30px; padding: 44px 62px 60px; background: #07120e; color: rgba(255,255,255,.7);
    }
    footer strong { display: block; color: #fff; margin-bottom: 12px; }
    footer p { margin: 8px 0; }
    @media (max-width: 1040px) {
      .product-hero, .detail-strip, .inquiry-wrap, .faq-grid, .related-grid, .oem-grid { grid-template-columns: 1fr; }
      h1 { font-size: 42px; }
      .gallery { grid-template-columns: 1fr; }
      .thumbs { grid-template-columns: repeat(4, 84px); }
      footer { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 720px) {
      .nav { width: calc(100% - 20px); padding: 0 12px; gap: 14px; }
      .nav-links { display: none; }
      .hero, section, footer { padding-left: 20px; padding-right: 20px; }
      .spec-grid, form, footer { grid-template-columns: 1fr; }
      .thumbs { grid-template-columns: repeat(2, 84px); }
      footer { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <header class="nav">
    <a class="brand" href="appacs-homepage-long-preview.html"><img src="../appacs-next-home/public/assets/company-logo.jpg" alt="APPACS logo" />APPACS</a>
    <nav class="nav-links">
      <a href="$($Product.categoryPage)">Products</a>
      <a href="appacs-homepage-long-preview.html#solutions">OEM/ODM</a>
      <a href="appacs-homepage-long-preview.html#factory">Factory</a>
      <a href="appacs-homepage-long-preview.html#applications">Applications</a>
      <a href="appacs-blog.html">Blog</a>
      <a href="appacs-inquiry-form.html">Contact</a>
    </nav>
    <a class="quote" href="appacs-inquiry-form.html">Get a Quote</a>
  </header>

  <main>
    <section class="hero">
      <div class="breadcrumb">Home / <a href="$($Product.categoryPage)">$($Product.categoryLabel)</a> / <span>$($Product.title)</span></div>
      <div class="product-hero">
        <div class="gallery">
          <div class="thumbs">
            $thumbs
          </div>
          <div class="main-frame" id="productMainImageFrame">
            <img id="productMainImage" src="$mainImage" alt="$($Product.title)" />
          </div>
        </div>
        <div class="info-card">
          <h1>$($Product.title)</h1>
          <p class="intro">$($Product.intro)</p>
          <div class="chips">$chips</div>
          <div class="spec-grid">
            $specHtml
          </div>
          <div class="cta-row">
            <a class="btn primary" href="appacs-inquiry-form.html">Enquiry Now</a>
            <a class="btn secondary" href="$($Product.categoryPage)">Back to Category</a>
          </div>
        </div>
      </div>
    </section>

    <section id="specifications">
      <div class="section-inner">
        <div class="section-head">
          <h2>Product Highlights</h2>
          <p>$($Product.highlightsLead)</p>
        </div>
        <div class="oem-grid">
          <article class="oem-card"><h3>$($Product.highlightCards[0].title)</h3><p>$($Product.highlightCards[0].text)</p></article>
          <article class="oem-card"><h3>$($Product.highlightCards[1].title)</h3><p>$($Product.highlightCards[1].text)</p></article>
          <article class="oem-card"><h3>$($Product.highlightCards[2].title)</h3><p>$($Product.highlightCards[2].text)</p></article>
          <article class="oem-card"><h3>$($Product.highlightCards[3].title)</h3><p>$($Product.highlightCards[3].text)</p></article>
        </div>
      </div>
    </section>

    <section id="packing">
      <div class="section-inner detail-strip">
        <div class="detail-media">
          <img src="$($detailFiles[0])" alt="$($Product.title) application scene" />
        </div>
        <div>
          <h2>Application & Packing Info</h2>
          <p class="muted">$($Product.applicationLead)</p>
          <div class="timeline">
            <div><h3>1. $($Product.timeline[0].title)</h3><p class="muted">$($Product.timeline[0].text)</p></div>
            <div><h3>2. $($Product.timeline[1].title)</h3><p class="muted">$($Product.timeline[1].text)</p></div>
            <div><h3>3. $($Product.timeline[2].title)</h3><p class="muted">$($Product.timeline[2].text)</p></div>
          </div>
        </div>
      </div>
    </section>

    <section>
      <div class="section-inner">
        <div class="section-head">
          <h2>Product Detail Images</h2>
          <p>$($Product.detailLead)</p>
        </div>
        <div class="detail-gallery">
          $detailHtml
        </div>
      </div>
    </section>

    <section class="dark" id="faq">
      <div class="section-inner">
        <div class="section-head">
          <h2>Buyer FAQ</h2>
          <p>FAQ content supports both conversion and AIO/GEO visibility when written as short direct answers.</p>
        </div>
        <div class="faq-grid">
          $faqHtml
        </div>
      </div>
    </section>

    <section>
      <div class="section-inner">
        <div class="section-head">
          <h2>Related Products</h2>
          <p>Keep buyers browsing within the product family and link related pages for SEO.</p>
        </div>
        <div class="related-grid">
          $relatedHtml
        </div>
      </div>
    </section>

    <section class="inquiry" id="inquiry">
      <div class="inquiry-wrap">
        <div>
          <h2>Enquiry Now</h2>
          <p class="muted">Send your $($Product.model) cable requirement. APPACS can reply with product details, sample direction and quotation information.</p>
        </div>
        <form>
          <input placeholder="Name *" />
          <input placeholder="Email *" />
          <input placeholder="Country / Region *" />
          <input placeholder="WhatsApp" />
          <select><option>$($Product.title)</option><option>Custom USB Cable</option><option>OEM / ODM Project</option></select>
          <input placeholder="Estimated Quantity" />
          <textarea placeholder="Tell us connector, color, length, package, logo and target market..."></textarea>
          <button type="button">Submit Inquiry</button>
        </form>
      </div>
    </section>
  </main>

  <footer>
    <div><strong>APPACS</strong><p>OEM/ODM USB cable and fast charging cable manufacturer for global B2B buyers.</p></div>
    <div><strong>Products</strong><p><a href="appacs-usb-c-cables.html">USB-C Cables</a></p><p><a href="appacs-lightning-cables.html">Lightning Cables</a></p><p><a href="appacs-adapter-cables.html">Adapter Cables</a></p><p><a href="appacs-multi-function-cables.html">Multi-function Cables</a></p></div>
    <div><strong>Solutions</strong><p>OEM/ODM</p><p>Private Label</p><p>Promotional Gifts</p></div>
    <div><strong>Company</strong><p>About APPACS</p><p>Factory</p><p>Blog</p></div>
    <div><strong>Contact</strong><p>sales2@szappacs.com</p><p>WhatsApp +86 159 2002 6822</p><p>Shenzhen, China</p></div>
  </footer>
  <script>
    const thumbnails = document.querySelectorAll(".thumbs img[data-large]");
    const mainImage = document.querySelector("#productMainImage");
    thumbnails.forEach((thumbnail) => {
      thumbnail.addEventListener("click", () => {
        const nextImage = thumbnail.dataset.large;
        if (!nextImage || !mainImage) return;
        mainImage.src = nextImage;
        mainImage.alt = thumbnail.alt;
        thumbnails.forEach((item) => item.classList.remove("is-active"));
        thumbnail.classList.add("is-active");
      });
    });
  </script>
</body>
</html>
"@
}

$products = @(
  @{
    slug = "u11-lightning-white"
    model = "U11"
    fileName = "appacs-product-u11-lightning-white.html"
    category = "lightning"
    categoryLabel = "Lightning Cables"
    categoryPage = "appacs-lightning-cables.html"
    title = "U11 White Lightning Charging Cable"
    metaDescription = "APPACS U11 white Lightning charging cable for wholesale and OEM projects, suitable for iPhone charging, retail accessory programs and private label packaging."
    intro = "A clean white Lightning charging cable direction for importers and accessory brands that need a practical iPhone charging SKU with simple packaging and stable repeat-order potential."
    chips = @("USB-A to Lightning", "White Cable", "Retail Ready", "Private Label")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U11" },
      @{ label = "Type"; value = "USB-A to Lightning" },
      @{ label = "Material"; value = "PVC" },
      @{ label = "Use"; value = "Daily Charging" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U11\U11-iPhone-W.jpg",
      "$sourceRoot\U11\U11 001.jpg",
      "$sourceRoot\U11\U11-Packing.jpg",
      "$sourceRoot\U11\U11-Packing2.jpg"
    )
    detailImages = @(
      "$sourceRoot\U11\U11-iPhone-W.jpg",
      "$sourceRoot\U11\U11 001.jpg",
      "$sourceRoot\U11\U11-Packing.jpg",
      "$sourceRoot\U11\U11-Packing2.jpg"
    )
    highlightsLead = "Use the real U11 materials to present a practical Lightning cable for retail-friendly accessory programs and OEM quote discussions."
    highlightCards = @(
      @{ title = "Clean White Look"; text = "Bright product styling fits retail packs, gift channels and simple online catalogs." },
      @{ title = "iPhone Charging Use"; text = "Built for buyers who need an everyday Lightning charging item inside a stable accessory line." },
      @{ title = "OEM / ODM Support"; text = "Discuss logo, packaging, barcode label and color presentation before mass production." },
      @{ title = "Repeat Order Fit"; text = "A straightforward cable direction that is easy to quote for wholesale and distribution business." }
    )
    applicationLead = "Show the product, package and presentation direction before the buyer moves to sample discussion or a quotation request."
    timeline = @(
      @{ title = "Retail-Friendly Presentation"; text = "Suitable for clean blister packs, small gift sets and e-commerce accessory listings." },
      @{ title = "Simple Charging Program"; text = "Focused on daily iPhone charging needs rather than over-complicated technical positioning." },
      @{ title = "Branding Discussion"; text = "Private label logo and packaging details can be aligned with destination market requirements." }
    )
    detailLead = "These product visuals can be used to strengthen product understanding and improve buyer confidence before inquiry."
    faqs = @(
      @{ q = "Is this model suitable for iPhone charging programs?"; a = "Yes. U11 is positioned as a practical Lightning charging cable for daily retail and wholesale programs." },
      @{ q = "Can APPACS support custom packaging for U11?"; a = "Yes. Packaging, logo and barcode label requirements can be discussed according to the target market." },
      @{ q = "Is this product suitable for entry-level retail lines?"; a = "Yes. The clean appearance and straightforward use case make it a strong fit for entry-level accessory programs." },
      @{ q = "What should buyers include in the RFQ?"; a = "Quantity, country, packaging idea, connector type and whether logo printing is required." }
    )
    related = @(
      @{ href = "appacs-product-u11-lightning-black.html"; image = "assets/products/u11-lightning-black/main-1.jpg"; title = "U11 Black Lightning Cable"; text = "Black variant for mainstream retail and distribution programs." },
      @{ href = "appacs-product-u11-usb-c-white.html"; image = "assets/products/u11-usb-c-white/main-1.jpg"; title = "U11 White USB-C Cable"; text = "Matching family SKU for USB-C cable buyers." },
      @{ href = "appacs-lightning-cables.html"; image = "assets/categories/lightning-cables.jpg"; title = "More Lightning Cables"; text = "Return to the Lightning cable category page." }
    )
  },
  @{
    slug = "u11-lightning-black"
    model = "U11"
    fileName = "appacs-product-u11-lightning-black.html"
    category = "lightning"
    categoryLabel = "Lightning Cables"
    categoryPage = "appacs-lightning-cables.html"
    title = "U11 Black Lightning Charging Cable"
    metaDescription = "APPACS U11 black Lightning charging cable for wholesale, distribution and OEM packaging projects, suitable for mainstream iPhone charging accessory programs."
    intro = "A mainstream black Lightning cable direction for buyers who want a darker retail style, everyday iPhone charging use and easy OEM packaging discussion."
    chips = @("USB-A to Lightning", "Black Cable", "Wholesale", "Private Label")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U11" },
      @{ label = "Type"; value = "USB-A to Lightning" },
      @{ label = "Material"; value = "PVC" },
      @{ label = "Color"; value = "Black" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U11\U11-Lightning-black.jpg",
      "$sourceRoot\U11\U11 002.jpg",
      "$sourceRoot\U11\U11-Packing.jpg"
    )
    detailImages = @(
      "$sourceRoot\U11\U11-Lightning-black.jpg",
      "$sourceRoot\U11\U11 002.jpg",
      "$sourceRoot\U11\U11-Packing.jpg"
    )
    highlightsLead = "Use the U11 black materials to present a practical, darker retail-ready Lightning cable for distribution and private label programs."
    highlightCards = @(
      @{ title = "Mainstream Black SKU"; text = "A common and easy-to-sell color direction for retail and wholesale markets." },
      @{ title = "Daily Charging Use"; text = "Built for straightforward iPhone charging rather than niche specialty positioning." },
      @{ title = "Simple RFQ Process"; text = "Buyers can move quickly from product review to quote request with clear packaging inputs." },
      @{ title = "Repeat Order Friendly"; text = "A stable style that fits large-volume replenishment and long-term accessory catalogs." }
    )
    applicationLead = "Use the real product and packing images to show a black Lightning cable direction that fits mainstream accessory demand."
    timeline = @(
      @{ title = "Classic Retail Look"; text = "Black cable styling fits darker electronics bundles and universal shelf presentation." },
      @{ title = "Bulk Accessory Program"; text = "Appropriate for importers looking for a simple charging cable line with low explanation cost." },
      @{ title = "OEM Packaging Support"; text = "APPACS can discuss outer box, insert card, sticker and barcode information." }
    )
    detailLead = "These images can support product review and prepare the buyer for sample and packaging discussion."
    faqs = @(
      @{ q = "Is U11 black suitable for volume orders?"; a = "Yes. It is positioned as a mainstream charging cable style for wholesale and distribution programs." },
      @{ q = "Can this model be used for private label business?"; a = "Yes. OEM packaging, logo and other commercial requirements can be reviewed with APPACS." },
      @{ q = "Does black color help for bundled programs?"; a = "Yes. Black accessories are often easier to match with existing device bundles and catalog lines." },
      @{ q = "What information helps speed up quotation?"; a = "Target quantity, destination market, package type and whether you need logo printing." }
    )
    related = @(
      @{ href = "appacs-product-u11-lightning-white.html"; image = "assets/products/u11-lightning-white/main-1.jpg"; title = "U11 White Lightning Cable"; text = "Bright retail version for gift channels and clean accessory lines." },
      @{ href = "appacs-product-u11-usb-c-white.html"; image = "assets/products/u11-usb-c-white/main-1.jpg"; title = "U11 White USB-C Cable"; text = "Matching family SKU for USB-C cable inquiries." },
      @{ href = "appacs-lightning-cables.html"; image = "assets/categories/lightning-cables.jpg"; title = "More Lightning Cables"; text = "Return to the Lightning cable category page." }
    )
  },
  @{
    slug = "u11-usb-c-white"
    model = "U11"
    fileName = "appacs-product-u11-usb-c-white.html"
    category = "usb-c"
    categoryLabel = "USB-C Cables"
    categoryPage = "appacs-usb-c-cables.html"
    title = "U11 White USB-C Charging Cable"
    metaDescription = "APPACS U11 white USB-C charging cable for wholesale and OEM projects, suitable for retail-ready USB-C accessory programs and private label packaging."
    intro = "A white USB-C charging cable direction for buyers who need a cleaner retail presentation, simple daily charging use and flexible packaging support."
    chips = @("USB-A to USB-C", "White Cable", "Retail Ready", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U11" },
      @{ label = "Type"; value = "USB-A to USB-C" },
      @{ label = "Material"; value = "PVC" },
      @{ label = "Color"; value = "White" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U11\U11-usb-c-White (1).jpg",
      "$sourceRoot\U11\U11-usb-c-White (2).jpg",
      "$sourceRoot\U11\U11-Packing2.jpg"
    )
    detailImages = @(
      "$sourceRoot\U11\U11-usb-c-White (1).jpg",
      "$sourceRoot\U11\U11-usb-c-White (2).jpg",
      "$sourceRoot\U11\U11-Packing2.jpg"
    )
    highlightsLead = "Use the U11 USB-C variant to support product discovery for buyers who want a simple, clean USB-C accessory program."
    highlightCards = @(
      @{ title = "Clean White Direction"; text = "Useful for brighter accessory catalogs, gift channels and compact retail packs." },
      @{ title = "Mainstream USB-C Use"; text = "A straightforward USB-C charging cable option for practical, daily demand." },
      @{ title = "OEM Package Ready"; text = "Discuss box style, label, logo and retail presentation during quotation." },
      @{ title = "Easy Catalog SKU"; text = "Works as a simple product-line filler for buyers building broader USB-C collections." }
    )
    applicationLead = "Show the white USB-C direction and packaging readiness before the buyer moves into RFQ or sample review."
    timeline = @(
      @{ title = "Daily Charging Fit"; text = "A simple cable for mainstream charging programs rather than specialized high-power positioning." },
      @{ title = "Retail Presentation"; text = "The white color direction supports clean online product cards and shelf display." },
      @{ title = "Private Label Support"; text = "Logo and packaging details can be adjusted for destination market needs." }
    )
    detailLead = "Use these visuals to support buying decisions and clarify product direction before inquiry."
    faqs = @(
      @{ q = "Is this model suitable for simple USB-C cable programs?"; a = "Yes. U11 white USB-C is positioned for mainstream charging and retail-friendly presentation." },
      @{ q = "Can APPACS support custom labels and packaging?"; a = "Yes. Package structure, insert card, logo and barcode label details can be reviewed." },
      @{ q = "Is this a premium high-power model?"; a = "It is better positioned as a simple daily charging USB-C cable rather than a feature-led premium SKU." },
      @{ q = "What should buyers share for quotation?"; a = "Target quantity, destination country, packaging requirement and whether logo printing is required." }
    )
    related = @(
      @{ href = "appacs-product-u123-usb-c-cable.html"; image = "assets/products/u123-usb-c-cable/main-1.jpg"; title = "U123 USB-C Cable"; text = "Classic black USB-C product direction for wholesale programs." },
      @{ href = "appacs-product-u87-c-braided-usb-c-cable.html"; image = "assets/products/u87-c-braided-usb-c-cable/main-1.jpg"; title = "U87 Braided USB-C Cable"; text = "Braided upgrade option for premium USB-C programs." },
      @{ href = "appacs-usb-c-cables.html"; image = "assets/categories/usb-c-cables.jpg"; title = "More USB-C Cables"; text = "Return to the USB-C cable category page." }
    )
  },
  @{
    slug = "u123-usb-c-cable"
    model = "U123"
    fileName = "appacs-product-u123-usb-c-cable.html"
    category = "usb-c"
    categoryLabel = "USB-C Cables"
    categoryPage = "appacs-usb-c-cables.html"
    title = "U123 USB-C to USB-C Charging Cable"
    metaDescription = "APPACS U123 USB-C to USB-C charging cable for wholesale and OEM projects, suitable for black cable programs, retail packaging and repeat-order B2B business."
    intro = "A classic black USB-C to USB-C cable direction for buyers who need a stable catalog SKU with clear product visuals and export-ready packaging discussion."
    chips = @("USB-C to USB-C", "Black Cable", "Wholesale", "Private Label")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U123" },
      @{ label = "Type"; value = "USB-C to USB-C" },
      @{ label = "Material"; value = "TPE / Standard Cable" },
      @{ label = "Color"; value = "Black" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U123\U123-主图\U123.jpg",
      "$sourceRoot\U123\U123-主图\未标题-1_0002_U123.1333.jpg",
      "$sourceRoot\U123\U123-主图\未标题-1_0003_U123.1326.jpg"
    )
    detailImages = @(
      "$sourceRoot\U123\U123-详情\U123-详情页_01.jpg",
      "$sourceRoot\U123\U123-详情\U123-详情页_02.jpg",
      "$sourceRoot\U123\U123-详情\U123-详情页_03.jpg",
      "$sourceRoot\U123\U123-详情\U123-详情页_04.jpg",
      "$sourceRoot\U123\U123-详情\U123-详情页_05.jpg",
      "$sourceRoot\U123\U123-详情\U123-详情页_06.jpg"
    )
    highlightsLead = "Use the U123 master and detail images to build a practical USB-C product page for wholesale and private label buyers."
    highlightCards = @(
      @{ title = "USB-C to USB-C Direction"; text = "A straightforward connector setup for modern device charging programs." },
      @{ title = "Classic Black Style"; text = "Appropriate for wide retail compatibility and lower explanation cost during sales." },
      @{ title = "Detail Image Support"; text = "Detail visuals help buyers review structure, finish and product direction before inquiry." },
      @{ title = "OEM Discussion Ready"; text = "Packaging, logo and commercial terms can be aligned with import program needs." }
    )
    applicationLead = "Show the U123 structure and usage direction before the buyer moves to sample confirmation or pricing discussion."
    timeline = @(
      @{ title = "Mainstream Device Fit"; text = "Useful for buyers who need a standard USB-C cable rather than a feature-led specialty item." },
      @{ title = "Simple Catalog SKU"; text = "The clean black look makes it easy to include inside wider cable product lines." },
      @{ title = "Export Program Support"; text = "Private label and packaging discussion can follow after model approval." }
    )
    detailLead = "These detail images can support specification review and improve product-page completeness."
    faqs = @(
      @{ q = "Is U123 suitable for mainstream USB-C cable business?"; a = "Yes. It is positioned as a clear, standard USB-C to USB-C cable direction for wholesale and distribution." },
      @{ q = "Can this model be used for private label projects?"; a = "Yes. Logo and packaging can be discussed according to quantity and destination market." },
      @{ q = "Why use a dedicated product page instead of only a category card?"; a = "A product page gives buyers clearer visuals, stronger trust signals and a better quote-preparation experience." },
      @{ q = "What information is useful for quotation?"; a = "Quantity, packaging idea, market destination and whether custom labeling is required." }
    )
    related = @(
      @{ href = "appacs-product-u87-c-braided-usb-c-cable.html"; image = "assets/products/u87-c-braided-usb-c-cable/main-1.jpg"; title = "U87 Braided USB-C Cable"; text = "Braided upgrade option for USB-C buyers." },
      @{ href = "appacs-product-u87t-cc-coiled-usb-c-cable.html"; image = "assets/products/u87t-cc-coiled-usb-c-cable/main-1.jpg"; title = "U87T-CC Coiled Cable"; text = "A different form factor for USB-C cable collections." },
      @{ href = "appacs-usb-c-cables.html"; image = "assets/categories/usb-c-cables.jpg"; title = "More USB-C Cables"; text = "Return to the USB-C cable category page." }
    )
  },
  @{
    slug = "u87-c-braided-usb-c-cable"
    model = "U87-C"
    fileName = "appacs-product-u87-c-braided-usb-c-cable.html"
    category = "usb-c"
    categoryLabel = "USB-C Cables"
    categoryPage = "appacs-usb-c-cables.html"
    title = "U87 Braided USB-C Charging Cable"
    metaDescription = "APPACS U87 braided USB-C charging cable for wholesale and OEM projects, suitable for premium-looking retail programs and private label accessory lines."
    intro = "A braided USB-C charging cable direction for buyers who need a slightly more premium visual style, stronger material expression and retail-friendly positioning."
    chips = @("USB-C Cable", "Braided", "Premium Look", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87-C" },
      @{ label = "Type"; value = "USB-C Charging Cable" },
      @{ label = "Material"; value = "Nylon Braided" },
      @{ label = "Finish"; value = "Dark Metallic" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87-C\U87-Nylon Braided-Micro&Type C-无孔\U87-type-c\U87-TYPE-C_0001_U87.14.jpg",
      "$sourceRoot\U87-C\U87-Nylon Braided-Micro&Type C-无孔\U87-type-c\U87-TYPE-C_0001_U87.15.jpg",
      "$sourceRoot\U87-C\U87-Nylon Braided-Micro&Type C-无孔\U87-type-c\U87-TYPE-C_0002_U87.24.jpg"
    )
    detailImages = @(
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_01.jpg",
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_02.jpg",
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_03.jpg",
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_04.jpg",
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_05.jpg",
      "$sourceRoot\U87-C\U87-C详情图\U87-C-详情页_06.jpg"
    )
    highlightsLead = "Use the U87 braided visuals to present a more premium-looking USB-C cable option within the APPACS product range."
    highlightCards = @(
      @{ title = "Braided Material Direction"; text = "Helps buyers understand the product as a stronger-looking upgrade from simple cable styles." },
      @{ title = "Retail-Ready Appearance"; text = "The darker metallic finish supports premium shelf presentation and stronger product photos." },
      @{ title = "Wholesale + OEM Fit"; text = "Suitable for distributors, accessory brands and project buyers needing packaging flexibility." },
      @{ title = "Category Page Support"; text = "Adds depth to the USB-C collection by introducing a more material-led SKU." }
    )
    applicationLead = "Use the detail images to explain the braided material direction before the buyer moves into sample or RFQ discussion."
    timeline = @(
      @{ title = "Premium Visual Positioning"; text = "The braided finish gives the cable a stronger value impression for retail and online programs." },
      @{ title = "Flexible Catalog Use"; text = "Suitable as a mid-tier upgrade inside broader USB-C cable collections." },
      @{ title = "OEM Package Planning"; text = "Discuss packaging, labeling and logo requirements after model review." }
    )
    detailLead = "These detail images can support material review and enrich the product page for B2B visitors."
    faqs = @(
      @{ q = "Why choose a braided USB-C cable page for B2B buyers?"; a = "It helps buyers quickly understand the material upgrade and product positioning compared with simpler cable lines." },
      @{ q = "Can U87 be used for branded accessory programs?"; a = "Yes. APPACS can discuss logo, packaging and product presentation requirements." },
      @{ q = "Is this page intended for direct retail checkout?"; a = "No. The goal is to support B2B inquiry generation and specification-led product selection." },
      @{ q = "What helps accelerate quotation?"; a = "Target market, quantity, package style and whether a private label program is needed." }
    )
    related = @(
      @{ href = "appacs-product-u123-usb-c-cable.html"; image = "assets/products/u123-usb-c-cable/main-1.jpg"; title = "U123 USB-C Cable"; text = "Standard USB-C to USB-C direction for wholesale programs." },
      @{ href = "appacs-product-u92-right-angle-usb-c-cable.html"; image = "assets/products/u92-right-angle-usb-c-cable/main-1.jpg"; title = "U92 Right-Angle Cable"; text = "Space-saving USB-C direction for application-focused buyers." },
      @{ href = "appacs-usb-c-cables.html"; image = "assets/categories/usb-c-cables.jpg"; title = "More USB-C Cables"; text = "Return to the USB-C cable category page." }
    )
  },
  @{
    slug = "u92-right-angle-usb-c-cable"
    model = "U92"
    fileName = "appacs-product-u92-right-angle-usb-c-cable.html"
    category = "usb-c"
    categoryLabel = "USB-C Cables"
    categoryPage = "appacs-usb-c-cables.html"
    title = "U92 Right-Angle USB-C Charging Cable"
    metaDescription = "APPACS U92 right-angle USB-C charging cable for wholesale and OEM projects, suitable for compact charging applications, accessory bundles and private label programs."
    intro = "A right-angle USB-C charging cable direction for buyers who need a more application-focused cable style, compact routing and differentiated catalog positioning."
    chips = @("Right-Angle", "USB-C Cable", "Compact Use", "OEM Ready")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U92" },
      @{ label = "Type"; value = "Right-Angle USB-C" },
      @{ label = "Material"; value = "TPE Cable" },
      @{ label = "Color"; value = "Black" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U92\U92-主图\U92_0000_U92.1385.jpg",
      "$sourceRoot\U92\U92-主图\U92_0001_U92-TPE详情页-黑色_01.jpg",
      "$sourceRoot\U92\U92-主图\U92_0002_U92.1379.jpg"
    )
    detailImages = @(
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_01.jpg",
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_02.jpg",
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_03.jpg",
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_04.jpg",
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_05.jpg",
      "$sourceRoot\U92\U92-详情图\U92-TPE详情页-黑色_06.jpg"
    )
    highlightsLead = "Use the U92 images to present an application-led USB-C cable with right-angle connector positioning."
    highlightCards = @(
      @{ title = "Right-Angle Layout"; text = "Useful for buyers who need a cable style that looks more application-specific than standard straight-head models." },
      @{ title = "Compact Product Story"; text = "Helps the category page cover more use scenarios and accessory-subtype search intent." },
      @{ title = "TPE Program Direction"; text = "Supports practical charging-line programs where simple material direction is enough." },
      @{ title = "OEM / ODM Discussion"; text = "Private label packaging and catalog presentation can be aligned during quotation." }
    )
    applicationLead = "Use the detail visuals to explain the right-angle cable direction and improve product-page completeness."
    timeline = @(
      @{ title = "Space-Saving Direction"; text = "A right-angle cable can help buyers present a more functional application story inside the catalog." },
      @{ title = "Practical Retail SKU"; text = "Suitable for accessory brands that want variety inside a mainstream USB-C collection." },
      @{ title = "Bulk Program Support"; text = "APPACS can discuss packaging, labeling and project requirements before order confirmation." }
    )
    detailLead = "The detail images help explain structure and improve buyer understanding before inquiry."
    faqs = @(
      @{ q = "Why add a right-angle cable to a USB-C collection?"; a = "It broadens the product range with a more application-focused option for buyers and distributors." },
      @{ q = "Can U92 be used for private label business?"; a = "Yes. Packaging, branding and labeling can be discussed according to the project scope." },
      @{ q = "Is this a standard USB-C cable or a specialty direction?"; a = "It is better positioned as a specialty direction inside a broader USB-C collection." },
      @{ q = "What is helpful when requesting a quote?"; a = "Quantity, target market, packaging plan and whether the cable is part of a wider project assortment." }
    )
    related = @(
      @{ href = "appacs-product-u87-c-braided-usb-c-cable.html"; image = "assets/products/u87-c-braided-usb-c-cable/main-1.jpg"; title = "U87 Braided USB-C Cable"; text = "Braided option for buyers who want a more premium USB-C line." },
      @{ href = "appacs-product-u87t-cc-coiled-usb-c-cable.html"; image = "assets/products/u87t-cc-coiled-usb-c-cable/main-1.jpg"; title = "U87T-CC Coiled Cable"; text = "Distinctive cable form for a broader USB-C assortment." },
      @{ href = "appacs-usb-c-cables.html"; image = "assets/categories/usb-c-cables.jpg"; title = "More USB-C Cables"; text = "Return to the USB-C cable category page." }
    )
  },
  @{
    slug = "u87t-cc-coiled-usb-c-cable"
    model = "U87T-CC"
    fileName = "appacs-product-u87t-cc-coiled-usb-c-cable.html"
    category = "usb-c"
    categoryLabel = "USB-C Cables"
    categoryPage = "appacs-usb-c-cables.html"
    title = "U87T-CC Coiled USB-C Cable"
    metaDescription = "APPACS U87T-CC coiled USB-C cable for wholesale and OEM projects, suitable for distinctive cable assortments, travel use and premium accessory lines."
    intro = "A coiled USB-C cable direction for buyers who want a more distinctive form factor inside their USB-C collection and a stronger product-photo presence."
    chips = @("Coiled Cable", "USB-C to USB-C", "Travel Use", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87T-CC" },
      @{ label = "Type"; value = "USB-C to USB-C" },
      @{ label = "Material"; value = "Coiled Cable" },
      @{ label = "Style"; value = "Spring Form" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87T-CC\U87T-CC-主图\U87T_0001_U87T-CC.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-主图\U87T_0000_U165.2811(1).jpg",
      "$sourceRoot\U87T-CC\U87T-CC-主图\U87T_0002_U165.6.jpg"
    )
    detailImages = @(
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_01.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_02.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_03.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_04.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_05.jpg",
      "$sourceRoot\U87T-CC\U87T-CC-详情图\U87T-CC-详情页_06.jpg"
    )
    highlightsLead = "Use the coiled U87T-CC visuals to build a more visually distinctive USB-C product page for overseas buyers."
    highlightCards = @(
      @{ title = "Distinctive Coiled Form"; text = "The spring-like cable shape helps the SKU stand out inside crowded USB-C cable collections." },
      @{ title = "Travel / Compact Story"; text = "Useful for buyers who want to pitch a neater or more compact cable-use experience." },
      @{ title = "Visual Shelf Differentiation"; text = "The coiled structure gives the product stronger photography and merchandising value." },
      @{ title = "OEM Program Fit"; text = "Suitable for product-line extension, packaging customization and private label proposals." }
    )
    applicationLead = "Use the detail images to explain the coiled structure and support buyer understanding before inquiry."
    timeline = @(
      @{ title = "Form-Led Positioning"; text = "The product can be marketed as a more differentiated alternative to straight cable styles." },
      @{ title = "Catalog Extension"; text = "Suitable for expanding USB-C collections with a visually distinct SKU." },
      @{ title = "Private Label Discussion"; text = "Packaging and accessory-line integration can be reviewed during quote preparation." }
    )
    detailLead = "These images support structure review and help the buyer assess whether the form factor fits the target market."
    faqs = @(
      @{ q = "Why add a coiled cable to a USB-C category page?"; a = "It gives buyers a more visually distinctive option and broadens the assortment." },
      @{ q = "Can U87T-CC be used for private label programs?"; a = "Yes. Branding, packaging and related commercial requirements can be discussed with APPACS." },
      @{ q = "Is the page intended to replace the category page?"; a = "No. It supports deeper product understanding while the category page remains the main discovery entry." },
      @{ q = "What should buyers provide when requesting a quote?"; a = "Quantity, market destination, packaging idea and any brand presentation requirements." }
    )
    related = @(
      @{ href = "appacs-product-u123-usb-c-cable.html"; image = "assets/products/u123-usb-c-cable/main-1.jpg"; title = "U123 USB-C Cable"; text = "Standard USB-C option for broader product-line balance." },
      @{ href = "appacs-product-u92-right-angle-usb-c-cable.html"; image = "assets/products/u92-right-angle-usb-c-cable/main-1.jpg"; title = "U92 Right-Angle Cable"; text = "Application-led USB-C cable for a differentiated assortment." },
      @{ href = "appacs-usb-c-cables.html"; image = "assets/categories/usb-c-cables.jpg"; title = "More USB-C Cables"; text = "Return to the USB-C cable category page." }
    )
  },
  @{
    slug = "u93-usb-c-audio-adapter-cable"
    model = "U93"
    fileName = "appacs-product-u93-usb-c-audio-adapter-cable.html"
    category = "adapter"
    categoryLabel = "Adapter Cables"
    categoryPage = "appacs-adapter-cables.html"
    title = "U93 USB-C Audio Adapter Cable"
    metaDescription = "APPACS U93 USB-C audio adapter cable for wholesale and OEM projects, suitable for compact conversion accessory lines, retail bundles and private label packaging."
    intro = "A compact USB-C audio adapter cable direction for buyers who need conversion accessories, catalog variety and a retail-ready add-on item."
    chips = @("USB-C Adapter", "Audio Use", "Compact Accessory", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U93" },
      @{ label = "Type"; value = "USB-C Audio Adapter" },
      @{ label = "Use"; value = "Audio Conversion" },
      @{ label = "Color"; value = "Black + Blue" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U93\U93-主图\未标题-1_0000_U93.982.jpg",
      "$sourceRoot\U93\U93-主图\未标题-1_0001_U93.1005.jpg",
      "$sourceRoot\U93\U93-主图\未标题-1_0002_U93.1008.jpg"
    )
    detailImages = @(
      "$sourceRoot\U93\U93-详情图\U93详情页_01.jpg",
      "$sourceRoot\U93\U93-详情图\U93详情页_02.jpg",
      "$sourceRoot\U93\U93-详情图\U93详情页_03.jpg",
      "$sourceRoot\U93\U93-详情图\U93详情页_04.jpg",
      "$sourceRoot\U93\U93-详情图\U93详情页_05.jpg",
      "$sourceRoot\U93\U93-详情图\U93详情页_06.jpg"
    )
    highlightsLead = "Use the U93 product set to present a compact adapter cable for accessory wholesalers and private label buyers."
    highlightCards = @(
      @{ title = "Conversion Accessory Direction"; text = "Adds a clear adapter category product to the website instead of relying only on charging cables." },
      @{ title = "Compact Retail Item"; text = "Useful as an add-on product for small packs, gift sets and e-commerce bundles." },
      @{ title = "Visual Category Depth"; text = "A dedicated product page helps the adapter category look more complete and more credible." },
      @{ title = "OEM Opportunity"; text = "Logo, shell finish and packaging can be discussed with APPACS according to project needs." }
    )
    applicationLead = "Use the detail images to explain the adapter direction and help the buyer judge whether the product fits the target assortment."
    timeline = @(
      @{ title = "Accessory-Line Expansion"; text = "U93 can help broaden an accessory program beyond standard charging cables." },
      @{ title = "Bundle-Friendly Positioning"; text = "Compact size makes it suitable for bundled accessory kits and retail add-on sales." },
      @{ title = "Private Label Planning"; text = "Packaging and logo discussion can happen after the buyer confirms the interface direction." }
    )
    detailLead = "These detail images help present the conversion accessory more clearly before RFQ."
    faqs = @(
      @{ q = "Why add adapter products to a cable website?"; a = "They support broader buyer intent and help the site cover more practical accessory requirements." },
      @{ q = "Can U93 be used in bundle programs?"; a = "Yes. It is well suited to compact retail bundles and accessory add-on programs." },
      @{ q = "Can APPACS support private label for this product?"; a = "Yes. Branding, package and commercial details can be discussed based on quantity." },
      @{ q = "What helps with quotation?"; a = "Target quantity, country, package format and whether the product is part of a wider project assortment." }
    )
    related = @(
      @{ href = "appacs-product-u87m-magnetic-charging-cable.html"; image = "assets/products/u87m-magnetic-charging-cable/main-1.jpg"; title = "U87M Magnetic Cable"; text = "Magnetic accessory direction for a broader adapter assortment." },
      @{ href = "appacs-product-u92-right-angle-usb-c-cable.html"; image = "assets/products/u92-right-angle-usb-c-cable/main-1.jpg"; title = "U92 Right-Angle Cable"; text = "Application-led charging cable with stronger use-case positioning." },
      @{ href = "appacs-adapter-cables.html"; image = "assets/categories/adapter-cables.jpg"; title = "More Adapter Cables"; text = "Return to the adapter cable category page." }
    )
  },
  @{
    slug = "u87m-magnetic-charging-cable"
    model = "U87M"
    fileName = "appacs-product-u87m-magnetic-charging-cable.html"
    category = "adapter"
    categoryLabel = "Adapter Cables"
    categoryPage = "appacs-adapter-cables.html"
    title = "U87M Magnetic Charging Cable"
    metaDescription = "APPACS U87M magnetic charging cable for wholesale and OEM projects, suitable for accessory bundles, conversion programs and private label packaging."
    intro = "A magnetic charging cable direction for buyers who want a more specialized accessory option inside an adapter or conversion-focused product line."
    chips = @("Magnetic Cable", "Special Accessory", "Bundle Ready", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87M" },
      @{ label = "Type"; value = "Magnetic Charging Cable" },
      @{ label = "Material"; value = "Braided" },
      @{ label = "Color"; value = "Black" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87M\U87M-magnetic Cable (1).jpg",
      "$sourceRoot\U87M\U87M-magnetic Cable (2).jpg",
      "$sourceRoot\U87M\U87M-magnetic Cable (3).jpg"
    )
    detailImages = @(
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_01.jpg",
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_02.jpg",
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_03.jpg",
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_04.jpg",
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_05.jpg",
      "$sourceRoot\U87M\U87M-详情图\U87M-详情页_06.jpg"
    )
    highlightsLead = "Use the U87M assets to present a magnetic charging cable direction inside the adapter and accessory category."
    highlightCards = @(
      @{ title = "Magnetic Product Story"; text = "Helps the product range cover more special-use accessory requirements beyond standard charging lines." },
      @{ title = "Retail Add-On Potential"; text = "Useful for gift channels, compact bundles and accessory assortment expansion." },
      @{ title = "Braided Visual Value"; text = "The braided finish helps the product look more premium in online and printed catalogs." },
      @{ title = "OEM / ODM Fit"; text = "Discuss label, package and private label presentation according to the destination market." }
    )
    applicationLead = "Use the detail images to explain the magnetic design and support product-page trust before inquiry."
    timeline = @(
      @{ title = "Special-Use Accessory"; text = "A magnetic cable can serve buyers who need a more differentiated add-on product." },
      @{ title = "Catalog Variety"; text = "This direction helps the adapter category look deeper and more complete." },
      @{ title = "Private Label Discussion"; text = "APPACS can align branding and packaging with the wider accessory project." }
    )
    detailLead = "These detail images can improve product understanding and help the buyer judge commercial fit."
    faqs = @(
      @{ q = "Why create a page for magnetic cables?"; a = "It helps cover more buyer intent and strengthens the accessory section of the website." },
      @{ q = "Can U87M support branded accessory programs?"; a = "Yes. Packaging and logo requirements can be discussed according to order scope." },
      @{ q = "Is U87M a mainstream cable or a specialty item?"; a = "It is better positioned as a specialty accessory or add-on product." },
      @{ q = "What information is useful before quotation?"; a = "Target quantity, target market, packaging plan and where the product fits in your assortment." }
    )
    related = @(
      @{ href = "appacs-product-u93-usb-c-audio-adapter-cable.html"; image = "assets/products/u93-usb-c-audio-adapter-cable/main-1.jpg"; title = "U93 Audio Adapter"; text = "Compact conversion accessory for bundle and retail programs." },
      @{ href = "appacs-product-u168-watch-charging-cable.html"; image = "assets/products/u168-watch-charging-cable/main-1.jpg"; title = "U168 Watch Charging Cable"; text = "Magnetic watch-oriented charging direction for multi-function programs." },
      @{ href = "appacs-adapter-cables.html"; image = "assets/categories/adapter-cables.jpg"; title = "More Adapter Cables"; text = "Return to the adapter cable category page." }
    )
  },
  @{
    slug = "u168-watch-charging-cable"
    model = "U168"
    fileName = "appacs-product-u168-watch-charging-cable.html"
    category = "multi-function"
    categoryLabel = "Multi-function Cables"
    categoryPage = "appacs-multi-function-cables.html"
    title = "U168 Magnetic Watch Charging Cable"
    metaDescription = "APPACS U168 magnetic watch charging cable for wholesale and OEM projects, suitable for travel accessory programs, gift sets and private label packaging."
    intro = "A magnetic watch charging cable direction for buyers who want a more specialized travel accessory item or a differentiated add-on inside multi-device charging programs."
    chips = @("Watch Charging", "Magnetic Module", "Travel Accessory", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U168" },
      @{ label = "Type"; value = "Magnetic Watch Charging Cable" },
      @{ label = "Material"; value = "Braided" },
      @{ label = "Use"; value = "Travel / Gift" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U168\U168-主图\U168_0000_U167弯头.2791(2).jpg",
      "$sourceRoot\U168\U168-主图\U168_0001_U167弯头.2894.jpg",
      "$sourceRoot\U168\U168-主图\U168_0002_U167弯头.2906.jpg"
    )
    detailImages = @(
      "$sourceRoot\U168\U168-详情图\U168-详情页_01.jpg",
      "$sourceRoot\U168\U168-详情图\U168-详情页_02.jpg",
      "$sourceRoot\U168\U168-详情图\U168-详情页_03.jpg",
      "$sourceRoot\U168\U168-详情图\U168-详情页_04.jpg",
      "$sourceRoot\U168\U168-详情图\U168-详情页_05.jpg",
      "$sourceRoot\U168\U168-详情图\U168-详情页_06.jpg"
    )
    highlightsLead = "Use the U168 assets to introduce a watch charging direction inside the multi-function category and support feature-led buyer searches."
    highlightCards = @(
      @{ title = "Watch Charging Direction"; text = "Adds a wearable-device use case to the cable portfolio and broadens multi-function search intent." },
      @{ title = "Travel / Gift Fit"; text = "Suitable for buyers building travel accessory bundles or gift-oriented retail sets." },
      @{ title = "Magnetic Module Story"; text = "The charging module gives the product stronger differentiation than standard cables." },
      @{ title = "OEM Program Support"; text = "Logo, package and private label direction can be aligned during quotation." }
    )
    applicationLead = "Use the detail images to explain the watch charging direction and help the buyer understand the product's retail and gift potential."
    timeline = @(
      @{ title = "Wearable Charging Use"; text = "A good fit for buyers who want a watch-focused charging item inside the collection." },
      @{ title = "Gift-Channel Opportunity"; text = "The specialized format helps the product work in travel and gift-centered accessory programs." },
      @{ title = "Private Label Packaging"; text = "APPACS can discuss label, box and presentation direction based on market needs." }
    )
    detailLead = "These detail images support feature explanation and improve the product-page completeness for B2B buyers."
    faqs = @(
      @{ q = "Why add watch charging products to the site?"; a = "It helps the website cover more buyer needs and makes the multi-function category more valuable." },
      @{ q = "Can U168 be used in travel accessory bundles?"; a = "Yes. It is suitable for compact travel and gift-oriented accessory programs." },
      @{ q = "Can APPACS support private label projects for this model?"; a = "Yes. Packaging and branding can be discussed based on order requirements." },
      @{ q = "What should buyers share before quotation?"; a = "Target quantity, destination market, packaging idea and whether the model is part of a broader bundle line." }
    )
    related = @(
      @{ href = "appacs-product-u87-cw100w-watch-charging-cable.html"; image = "assets/products/u87-cw100w-watch-charging-cable/main-1.jpg"; title = "U87-CW100W Watch Cable"; text = "Higher-spec multi-function cable with watch charging support." },
      @{ href = "appacs-product-u87d-led-display-cable.html"; image = "assets/products/u87d-led-display-cable/main-1.jpg"; title = "U87D Display Cable"; text = "Feature-led charging cable for premium retail lines." },
      @{ href = "appacs-multi-function-cables.html"; image = "assets/categories/multi-function-cables.jpg"; title = "More Multi-function Cables"; text = "Return to the multi-function cable category page." }
    )
  },
  @{
    slug = "u87c-cc-dual-usb-c-cable"
    model = "U87C-CC"
    fileName = "appacs-product-u87c-cc-dual-usb-c-cable.html"
    category = "multi-function"
    categoryLabel = "Multi-function Cables"
    categoryPage = "appacs-multi-function-cables.html"
    title = "U87C-CC Dual USB-C Charging Cable"
    metaDescription = "APPACS U87C-CC dual USB-C charging cable for wholesale and OEM projects, suitable for multi-device charging programs, gift bundles and private label packaging."
    intro = "A dual USB-C charging cable direction for buyers who need a more flexible multi-device concept and a differentiated cable story inside their accessory lineup."
    chips = @("Dual USB-C", "Multi-device", "Braided", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87C-CC" },
      @{ label = "Type"; value = "Dual USB-C Cable" },
      @{ label = "Material"; value = "Braided + Alloy" },
      @{ label = "Use"; value = "Multi-device Charging" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87C-CC\U87C-CC主图\U87C-CC (1).jpg",
      "$sourceRoot\U87C-CC\U87C-CC主图\U87C-CC (2).jpg",
      "$sourceRoot\U87C-CC\U87C-CC主图\U87C-CC (3).jpg"
    )
    detailImages = @(
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_01.jpg",
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_02.jpg",
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_03.jpg",
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_04.jpg",
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_05.jpg",
      "$sourceRoot\U87C-CC\U87C-CC详情图\U87C-CC_06.jpg"
    )
    highlightsLead = "Use the U87C-CC product set to support a multi-device charging story inside the multi-function category."
    highlightCards = @(
      @{ title = "Dual USB-C Story"; text = "A more specialized cable concept helps the category page look deeper and more differentiated." },
      @{ title = "Braided Material"; text = "The braided finish supports stronger visual presentation for retail and online merchandising." },
      @{ title = "Bundle / Gift Fit"; text = "Useful for buyers creating travel kits or function-led accessory bundles." },
      @{ title = "OEM Support"; text = "Discuss logo, package and product-line planning based on order scope." }
    )
    applicationLead = "Use the detail images to explain the multi-device direction and improve buyer confidence before RFQ."
    timeline = @(
      @{ title = "Multi-device Positioning"; text = "This product adds a stronger feature-based story compared with single-function cable pages." },
      @{ title = "Retail Differentiation"; text = "A multi-device concept can help the product stand out inside B2B and e-commerce assortments." },
      @{ title = "Private Label Opportunity"; text = "Packaging and brand presentation can be aligned with the destination market." }
    )
    detailLead = "These images support product understanding and strengthen the multi-function section of the website."
    faqs = @(
      @{ q = "Why add a dual USB-C cable page?"; a = "It expands the site's feature-led product range and supports more buyer search intent." },
      @{ q = "Can this model be used in gift or bundle programs?"; a = "Yes. It is suitable for feature-rich accessory kits and retail bundles." },
      @{ q = "Can APPACS support custom packaging?"; a = "Yes. Packaging and brand presentation can be discussed based on volume and market needs." },
      @{ q = "What helps with quotation?"; a = "Quantity, target market, packaging direction and the intended sales channel." }
    )
    related = @(
      @{ href = "appacs-product-u87-cw100w-watch-charging-cable.html"; image = "assets/products/u87-cw100w-watch-charging-cable/main-1.jpg"; title = "U87-CW100W Watch Cable"; text = "Watch-oriented multi-function cable for travel and gift projects." },
      @{ href = "appacs-product-u87d-led-display-cable.html"; image = "assets/products/u87d-led-display-cable/main-1.jpg"; title = "U87D Display Cable"; text = "Display-led fast charging cable for stronger retail presentation." },
      @{ href = "appacs-multi-function-cables.html"; image = "assets/categories/multi-function-cables.jpg"; title = "More Multi-function Cables"; text = "Return to the multi-function cable category page." }
    )
  },
  @{
    slug = "u87-cw100w-watch-charging-cable"
    model = "U87-CW100W"
    fileName = "appacs-product-u87-cw100w-watch-charging-cable.html"
    category = "multi-function"
    categoryLabel = "Multi-function Cables"
    categoryPage = "appacs-multi-function-cables.html"
    title = "U87-CW100W Watch Charging Cable"
    metaDescription = "APPACS U87-CW100W watch charging cable for wholesale and OEM projects, suitable for multi-device charging, travel bundles and premium private label programs."
    intro = "A watch charging multi-function cable direction for buyers who need stronger charging features, broader device coverage and more premium product positioning."
    chips = @("Watch Charging", "100W / 60W", "Braided", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87-CW100W" },
      @{ label = "Type"; value = "Watch Charging Cable" },
      @{ label = "Power"; value = "100W / 60W Series" },
      @{ label = "Material"; value = "Braided + Alloy" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87-CW100W\U87-CW100W-主图\U87-UW_0003_U87-多合一.2484.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-主图\U87-UW_0004_U87-多合一.2483.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-主图\U87-UW_0000_U87-多合一.2475.jpg"
    )
    detailImages = @(
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_01.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_02.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_03.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_04.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_05.jpg",
      "$sourceRoot\U87-CW100W\U87-CW100W-详情图\U87-UW60W_06.jpg"
    )
    highlightsLead = "Use the U87-CW100W materials to support a stronger multi-function charging story with watch charging support."
    highlightCards = @(
      @{ title = "Watch Charging Module"; text = "Adds a wearable-focused feature that helps the product stand out inside travel and gift assortments." },
      @{ title = "Higher-Power Story"; text = "The 100W / 60W positioning supports a stronger premium impression for B2B buyers." },
      @{ title = "Braided Premium Look"; text = "The darker braided finish improves retail photos and premium catalog presentation." },
      @{ title = "OEM Program Value"; text = "APPACS can discuss packaging, logo and program fit according to buyer requirements." }
    )
    applicationLead = "Use the detail images to explain the multi-function charging direction and premium positioning before RFQ."
    timeline = @(
      @{ title = "Travel + Gift Fit"; text = "Suitable for buyers who need one cable concept to cover more charging needs in one package." },
      @{ title = "Premium Shelf Story"; text = "The higher-power positioning can help buyers justify a more premium retail placement." },
      @{ title = "Private Label Expansion"; text = "Packaging and product-line integration can be planned based on destination market requirements." }
    )
    detailLead = "These detail images help explain function, positioning and product value to global buyers."
    faqs = @(
      @{ q = "Why create a dedicated product page for U87-CW100W?"; a = "It gives buyers clearer information on the watch charging direction and higher-power product story." },
      @{ q = "Can this model fit travel and gift channels?"; a = "Yes. It is especially suitable for buyers building multi-use charging bundles." },
      @{ q = "Can APPACS support private label packaging?"; a = "Yes. Logo, packaging and accessory presentation can be discussed during quotation." },
      @{ q = "What helps with quote preparation?"; a = "Target quantity, sales channel, destination market and the planned package structure." }
    )
    related = @(
      @{ href = "appacs-product-u168-watch-charging-cable.html"; image = "assets/products/u168-watch-charging-cable/main-1.jpg"; title = "U168 Watch Charging Cable"; text = "Compact magnetic watch charging option for travel accessory programs." },
      @{ href = "appacs-product-u87d-led-display-cable.html"; image = "assets/products/u87d-led-display-cable/main-1.jpg"; title = "U87D Display Cable"; text = "Feature-led cable for premium retail presentation." },
      @{ href = "appacs-multi-function-cables.html"; image = "assets/categories/multi-function-cables.jpg"; title = "More Multi-function Cables"; text = "Return to the multi-function cable category page." }
    )
  },
  @{
    slug = "u87d-led-display-cable"
    model = "U87D"
    fileName = "appacs-product-u87d-led-display-cable.html"
    category = "multi-function"
    categoryLabel = "Multi-function Cables"
    categoryPage = "appacs-multi-function-cables.html"
    title = "U87D LED Display Fast Charging Cable"
    metaDescription = "APPACS U87D LED display fast charging cable for wholesale and OEM projects, suitable for premium retail lines, e-commerce display products and private label programs."
    intro = "A display-led fast charging cable direction for buyers who want stronger visual selling points, premium shelf impact and a more feature-rich product story."
    chips = @("LED Display", "Fast Charging", "Premium Look", "OEM Packaging")
    specs = @(
      @{ label = "Brand"; value = "APPACS" },
      @{ label = "Model"; value = "U87D" },
      @{ label = "Type"; value = "Display Charging Cable" },
      @{ label = "Feature"; value = "LED Power Display" },
      @{ label = "Material"; value = "Braided + Alloy" },
      @{ label = "OEM"; value = "Logo + Packaging" }
    )
    mainImages = @(
      "$sourceRoot\U87D\U87-CW100W-主图\U87D (1).jpg",
      "$sourceRoot\U87D\U87-CW100W-主图\U87D (2).jpg",
      "$sourceRoot\U87D\U87-CW100W-主图\U87D (3).jpg"
    )
    detailImages = @(
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_01.jpg",
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_02.jpg",
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_03.jpg",
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_04.jpg",
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_05.jpg",
      "$sourceRoot\U87D\U87-CW100W-详情图\U87D-详情页_06.jpg"
    )
    highlightsLead = "Use the U87D materials to support a premium display-led charging story inside the multi-function category."
    highlightCards = @(
      @{ title = "LED Display Feature"; text = "A visible power display helps the product stand out in online listings and on shelf." },
      @{ title = "Premium Retail Appeal"; text = "The display function creates a stronger premium impression for buyers and end customers." },
      @{ title = "Feature-Led Category Depth"; text = "It strengthens the multi-function section with a clear, easy-to-understand selling point." },
      @{ title = "OEM Packaging Support"; text = "APPACS can discuss retail box, label and branded presentation according to the project." }
    )
    applicationLead = "Use the detail images to explain the display feature and help buyers assess whether it fits premium retail demand."
    timeline = @(
      @{ title = "Visual Selling Point"; text = "The display feature can help buyers justify a stronger presentation and higher-value placement." },
      @{ title = "E-commerce Friendly"; text = "Feature-led products often perform better in visual online channels and social-style listings." },
      @{ title = "Private Label Planning"; text = "Packaging, box message and branding can be aligned with the target sales strategy." }
    )
    detailLead = "These images help explain the feature clearly and improve trust before the buyer sends an inquiry."
    faqs = @(
      @{ q = "Why add a display charging cable to the site?"; a = "It broadens the site's premium product coverage and supports feature-led buyer intent." },
      @{ q = "Is U87D suitable for retail-focused programs?"; a = "Yes. The visible display feature is especially valuable for retail and e-commerce presentation." },
      @{ q = "Can APPACS support custom packaging?"; a = "Yes. Retail packaging and branding details can be discussed according to the project scope." },
      @{ q = "What helps speed up quotation?"; a = "Target quantity, market destination, packaging direction and the intended sales channel." }
    )
    related = @(
      @{ href = "appacs-product-u87-cw100w-watch-charging-cable.html"; image = "assets/products/u87-cw100w-watch-charging-cable/main-1.jpg"; title = "U87-CW100W Watch Cable"; text = "Watch charging direction for broader multi-function collections." },
      @{ href = "appacs-product-u168-watch-charging-cable.html"; image = "assets/products/u168-watch-charging-cable/main-1.jpg"; title = "U168 Watch Cable"; text = "Compact magnetic watch charging option for travel bundles." },
      @{ href = "appacs-multi-function-cables.html"; image = "assets/categories/multi-function-cables.jpg"; title = "More Multi-function Cables"; text = "Return to the multi-function cable category page." }
    )
  }
)

Ensure-Directory $assetRoot

foreach ($product in $products) {
  $copied = Copy-AssetSet -Product $product
  $related = @()
  foreach ($entry in $product.related) { $related += $entry }
  $product.related = $related
  $html = Render-Page -Product $product -MainFiles $copied.mainFiles -DetailFiles $copied.detailFiles
  $targetFile = Join-Path $outputRoot $product.fileName
  [System.IO.File]::WriteAllText($targetFile, $html, [System.Text.Encoding]::UTF8)
  Write-Host "Generated $($product.fileName)"
}
