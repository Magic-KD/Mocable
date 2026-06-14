import Image from "next/image";
import AppacsInquiryForm from "./components/AppacsInquiryForm";

const products = [
  {
    name: "100W 3-in-1 USB-C Cable",
    detail: "One braided cable for USB-C, Lightning and Micro USB bulk programs.",
    image: "/assets/u87-3in1.jpg"
  },
  {
    name: "100W LED Display USB-C Cable",
    detail: "Real-time power display for fast charging retail and private label lines.",
    image: "/assets/u87d-display.jpg"
  },
  {
    name: "3-in-1 Watch Charging Cable",
    detail: "Multi-device charging cable with watch charging module for travel kits.",
    image: "/assets/u87-watch.jpg"
  }
];

const categories = [
  "USB-C to USB-C Cable",
  "iPhone Cable",
  "3-in-1 Charging Cable",
  "LED Display Cable",
  "Watch Charging Cable",
  "Custom Logo Cable"
];

const proof = [
  ["2011", "Established"],
  ["3,000+ m²", "Factory Area"],
  ["80+", "Elite Team"],
  ["CE / RoHS", "Available Certifications"]
];

const advantages = [
  "Custom logo, color, length and retail packaging",
  "Sample support for importers, distributors and brand owners",
  "Factory-direct OEM/ODM communication and project follow-up",
  "Product detail pages ready for SEO and paid landing pages"
];

const process = [
  ["01", "Requirement Review", "Confirm connector type, wattage, cable length, surface finish, package and target market."],
  ["02", "Sample & Quotation", "Prepare sample direction, quote by quantity tier and align delivery schedule."],
  ["03", "Logo & Packaging", "Support brand logo, retail box, barcode, label and private label presentation."],
  ["04", "Production & QC", "Track production, appearance checks, charging tests, packing and shipment preparation."]
];

const applications = [
  ["Importers", "Stable SKUs for regional wholesalers and retail channels."],
  ["Brand Owners", "Private label product lines with packaging and logo support."],
  ["Promotional Gifts", "Custom cable sets for events, campaigns and corporate programs."],
  ["E-commerce Sellers", "Fast-moving charging accessories with clear product visuals."]
];

const markets = ["Russia", "Europe", "America", "South America", "Middle East", "Southeast Asia"];

const seoPages = [
  ["USB C Cable Manufacturer", "/usb-c-cable-manufacturer/"],
  ["Fast Charging Cable Manufacturer", "/fast-charging-cable-manufacturer/"],
  ["Custom USB Cable Manufacturer", "/custom-usb-cable-manufacturer/"],
  ["USB Cable Supplier UAE", "/markets/usb-cable-supplier-uae/"],
  ["USB Cable Supplier Nigeria", "/markets/usb-cable-supplier-nigeria/"],
  ["How to Choose a USB Cable Supplier", "/blog/how-to-choose-usb-cable-supplier/"]
];

const faq = [
  {
    question: "Can APPACS support OEM and ODM charging cable projects?",
    answer:
      "Yes. The site should position APPACS around OEM/ODM, custom logo, packaging, cable length and product configuration support."
  },
  {
    question: "Which products should receive priority landing pages?",
    answer:
      "Start with USB-C cable manufacturer, fast charging cable manufacturer, custom USB cable manufacturer, iPhone cable supplier and 3-in-1 charging cable pages."
  },
  {
    question: "What should buyers submit for a useful quotation?",
    answer:
      "Ask for country, product requirement, target quantity, connector type, packaging needs and preferred contact method."
  }
];

export default function Home() {
  return (
    <main>
      <header className="site-header">
        <a className="brand" href="#">
          <Image src="/assets/company-logo.jpg" alt="APPACS logo" width={44} height={44} priority />
          <span>APPACS</span>
        </a>
        <nav aria-label="Primary navigation">
          <a href="#products">Products</a>
          <a href="#oem">OEM/ODM</a>
          <a href="#factory">Factory</a>
          <a href="#markets">Markets</a>
          <a href="#faq">FAQ</a>
        </nav>
        <a className="header-cta" href="#inquiry">Get a Quote</a>
      </header>

      <section className="hero">
        <div className="hero-copy">
          <h1>OEM/ODM Fast Charging Cables Built for Global Brands</h1>
          <p>
            Source USB-C, iPhone and 3-in-1 charging cables from APPACS with factory-direct customization,
            catalog support and responsive sales follow-up for international B2B buyers.
          </p>
          <div className="hero-actions">
            <a className="button primary" href="#inquiry">Get a Quote</a>
            <a className="button secondary" href="#products">View Products</a>
          </div>
          <dl className="hero-proof">
            {proof.map(([value, label]) => (
              <div key={label}>
                <dt>{value}</dt>
                <dd>{label}</dd>
              </div>
            ))}
          </dl>
        </div>
        <div className="hero-media" aria-label="APPACS charging cable product showcase">
          <Image src="/assets/u87-3in1.jpg" alt="APPACS 3-in-1 braided charging cable" width={820} height={820} priority />
        </div>
      </section>

      <section className="strategy-strip" aria-label="Website strategy summary">
        <p>Recommended site focus</p>
        <strong>USB Cable Manufacturer + OEM/ODM factory website</strong>
        <span>Built for inquiry conversion, SEO pages, AIO/GEO answers and future ad landing pages.</span>
      </section>

      <section className="section category-section">
        <div className="section-heading">
          <h2>Build the Site Around Buyer Search Intent</h2>
          <p>
            The homepage should quickly branch buyers into product, customization, factory proof and contact paths.
          </p>
        </div>
        <div className="category-grid">
          {categories.map((category) => (
            <a href="#products" key={category}>{category}</a>
          ))}
        </div>
      </section>

      <section className="section product-section" id="products">
        <div className="section-heading">
          <h2>Priority Product Pages</h2>
          <p>These categories match your current product photos, keyword system and buyer intent.</p>
        </div>
        <div className="product-grid">
          {products.map((product) => (
            <article className="product-card" key={product.name}>
              <Image src={product.image} alt={product.name} width={520} height={520} />
              <div>
                <h3>{product.name}</h3>
                <p>{product.detail}</p>
                <a href="#inquiry">Request specs</a>
              </div>
            </article>
          ))}
        </div>
      </section>

      <section className="section product-detail-band">
        <div>
          <h2>Product Detail Template Direction</h2>
          <p>
            Each product detail page should be more than a photo gallery. Use a repeatable template for SEO and paid
            traffic: hero image, wattage, connector options, cable material, custom options, packaging, FAQ and inquiry CTA.
          </p>
        </div>
        <div className="spec-table" role="table" aria-label="Recommended product detail content">
          <div role="row"><span>Core specs</span><strong>Wattage, connector, length, material, color</strong></div>
          <div role="row"><span>Buyer proof</span><strong>Samples, MOQ, lead time, QC and package options</strong></div>
          <div role="row"><span>SEO blocks</span><strong>FAQ, related products, internal links, schema markup</strong></div>
        </div>
      </section>

      <section className="section split-section" id="oem">
        <div className="media-panel">
          <Image src="/assets/banner.jpg" alt="APPACS factory and exhibition collage" width={1100} height={389} />
        </div>
        <div className="split-copy">
          <h2>OEM/ODM Pages Should Become the Conversion Engine</h2>
          <p>
            For foreign trade buyers, the strongest pages are not just product galleries. They should prove customization,
            sampling, packaging, quality control and stable delivery before asking for an inquiry.
          </p>
          <div className="advantage-list">
            {advantages.map((item) => (
              <div className="advantage" key={item}>
                <span aria-hidden="true">✓</span>
                <p>{item}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section className="section process-section">
        <div className="section-heading">
          <h2>OEM/ODM Cooperation Flow</h2>
          <p>A clear process reduces hesitation for new importers and makes ad traffic easier to convert.</p>
        </div>
        <div className="process-grid">
          {process.map(([step, title, text]) => (
            <article key={step}>
              <span>{step}</span>
              <h3>{title}</h3>
              <p>{text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section factory-section" id="factory">
        <div>
          <h2>Trust Blocks for Buyers and Ads</h2>
          <p>
            Use factory visuals, process explanations and verifiable claims to support both Google SEO and paid traffic.
            Avoid invented client logos, unsupported certifications or vague quality language.
          </p>
        </div>
        <div className="trust-grid">
          <article>
            <h3>Factory Proof</h3>
            <p>Workshop, production, QC, packaging and shipment photos.</p>
          </article>
          <article>
            <h3>Procurement Proof</h3>
            <p>MOQ, sample process, lead time, custom packaging and quotation flow.</p>
          </article>
          <article>
            <h3>SEO Proof</h3>
            <p>FAQ schema, product schema, internal links and searchable specification tables.</p>
          </article>
        </div>
      </section>

      <section className="section applications-section">
        <div className="section-heading">
          <h2>Application Scenarios</h2>
          <p>Application pages help buyers recognize themselves and give SEO more long-tail entry points.</p>
        </div>
        <div className="application-grid">
          {applications.map(([title, text]) => (
            <article key={title}>
              <h3>{title}</h3>
              <p>{text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section markets-section" id="markets">
        <div className="section-heading">
          <h2>Market Landing Page Plan</h2>
          <p>Start with English global pages, then expand into country pages for high-intent B2B searches.</p>
        </div>
        <div className="market-row">
          {markets.map((market) => (
            <span key={market}>{market}</span>
          ))}
        </div>
      </section>

      <section className="section seo-section">
        <div className="section-heading">
          <h2>SEO / AIO Content Architecture</h2>
          <p>
            Your keyword table is already strong. The next step is mapping each keyword cluster to a page with one clear
            search intent and one conversion action.
          </p>
        </div>
        <div className="seo-grid">
          {seoPages.map(([title, url]) => (
            <article key={url}>
              <h3>{title}</h3>
              <p>{url}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section faq-section" id="faq">
        <div className="section-heading">
          <h2>AIO / GEO Answer Blocks</h2>
          <p>Short, direct Q&A sections help buyers and AI answer engines understand the supplier fit.</p>
        </div>
        <div className="faq-list">
          {faq.map((item) => (
            <article key={item.question}>
              <h3>{item.question}</h3>
              <p>{item.answer}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section resource-section">
        <div>
          <h2>Resources That Support Sales Follow-up</h2>
          <p>
            Add downloadable catalog, spec sheets and buying guides after the first version. These assets help collect
            leads from buyers who are researching before they are ready to submit a full RFQ.
          </p>
        </div>
        <div className="resource-actions">
          <a href="#inquiry">Request Catalog</a>
          <a href="#products">Compare Product Options</a>
          <a href="#faq">Read Procurement FAQ</a>
        </div>
      </section>

      <section className="inquiry" id="inquiry">
        <div>
          <h2>Get a Quote for Your Cable Project</h2>
          <p>Tell APPACS your target market, product type, quantity and packaging needs.</p>
        </div>
        <AppacsInquiryForm />
      </section>

      <footer>
        <strong>APPACS</strong>
        <span>Shenzhen APPACS Electronic Technology Co., Ltd</span>
        <span>sales2@szappacs.com · WhatsApp +86 159 2002 6822</span>
      </footer>
    </main>
  );
}
