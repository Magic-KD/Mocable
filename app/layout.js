import "./globals.css";

export const metadata = {
  title: "Mocable | APPACS USB Cable Manufacturer",
  description: "OEM/ODM USB cable manufacturer for global B2B buyers."
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
