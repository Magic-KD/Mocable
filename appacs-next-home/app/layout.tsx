import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "APPACS | OEM/ODM USB Cable Manufacturer",
  description:
    "APPACS manufactures USB-C, iPhone and 3-in-1 fast charging cables for global importers, distributors and private label brands.",
  keywords: [
    "USB cable manufacturer",
    "USB C cable supplier",
    "fast charging cable factory",
    "OEM USB cable manufacturer",
    "custom charging cable supplier"
  ],
  openGraph: {
    title: "APPACS | OEM/ODM USB Cable Manufacturer",
    description:
      "Source custom USB-C, iPhone and 3-in-1 charging cables from APPACS with OEM/ODM support, catalog download and fast inquiry response.",
    images: ["/assets/u87-3in1.jpg"]
  }
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
