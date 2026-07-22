import legalDocument from "./legal.json";
import type {PublishedLegalContent} from "./types";

export const publishedLegalContent = legalDocument as PublishedLegalContent;
export const publishedLegalPages = publishedLegalContent.pages;
