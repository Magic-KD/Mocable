import { redirect } from "next/navigation";

export const metadata = {
  title: "FAQ | APPACS OEM/ODM USB Cable Manufacturer",
  description:
    "Frequently asked questions about APPACS USB cable manufacturing, OEM/ODM customization, MOQ, samples, certifications, lead time and quotation requirements."
};

export default function FaqPage() {
  redirect("/en/faq");
}
