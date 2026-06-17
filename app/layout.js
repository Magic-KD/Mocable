import "./globals.css";

const siteUrl = "https://www.mocable.com";

export const metadata = {
  metadataBase: new URL(siteUrl),
  title: "Mocable | OEM/ODM USB Cable Manufacturer",
  description: "Factory-direct USB-C cables, Lightning cables, adapter cables and multi-function charging cables for global B2B buyers.",
  alternates: {
    canonical: siteUrl
  },
  openGraph: {
    title: "Mocable | OEM/ODM USB Cable Manufacturer",
    description: "APPACS manufactures USB cables with OEM/ODM packaging, sample support and QC inspection for importers and private label buyers.",
    url: siteUrl,
    siteName: "Mocable",
    type: "website"
  },
  robots: {
    index: true,
    follow: true
  }
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
