import { NextResponse } from "next/server";

const PUBLIC_FILE = /\.[^/]+$/;
const SUPPORTED_LANGUAGES = ["en", "es", "ru", "ar", "fr", "pt"];

export function middleware(request) {
  const { pathname, search } = request.nextUrl;

  if (
    pathname.startsWith("/_next") ||
    pathname.startsWith("/outputs") ||
    pathname.startsWith("/api") ||
    PUBLIC_FILE.test(pathname)
  ) {
    return NextResponse.next();
  }

  const [, firstSegment = ""] = pathname.split("/");

  if (SUPPORTED_LANGUAGES.includes(firstSegment)) {
    return NextResponse.next();
  }

  const localizedPath =
    pathname === "/" ? "/en/" : `/en${pathname.endsWith("/") ? pathname.slice(0, -1) : pathname}`;

  const url = request.nextUrl.clone();
  url.pathname = localizedPath;
  url.search = search;

  return NextResponse.redirect(url);
}

export const config = {
  matcher: ["/((?!_next|api|outputs).*)"]
};
