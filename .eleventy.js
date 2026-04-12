// .eleventy.js
// Everest Capital content engine — Eleventy 3.x
// Reads markdown from content/, renders via _layouts/, outputs to _site/

import yaml from "js-yaml";
import fs from "node:fs";
import path from "node:path";

export default function (eleventyConfig) {
  // --- YAML frontmatter support (beyond the default) ---
  eleventyConfig.addDataExtension("yaml,yml", (contents) => yaml.load(contents));

  // --- Load design tokens from design.md as a global data source ---
  // Parses the YAML code blocks in design.md and exposes them as { design: {...} }
  eleventyConfig.addGlobalData("design", () => {
    const raw = fs.readFileSync(path.join(process.cwd(), "design.md"), "utf-8");
    const tokens = {};
    const yamlBlockRe = /```yaml\n([\s\S]*?)```/g;
    let m;
    while ((m = yamlBlockRe.exec(raw)) !== null) {
      try {
        const parsed = yaml.load(m[1]);
        if (parsed && typeof parsed === "object") {
          Object.assign(tokens, parsed);
        }
      } catch (e) {
        // Skip malformed blocks silently — design.md is human-editable
      }
    }
    return tokens;
  });

  // --- Passthrough copy for static assets ---
  eleventyConfig.addPassthroughCopy({ "assets": "assets" });
  eleventyConfig.addPassthroughCopy({ "pdfs": "pdfs" });
  eleventyConfig.addPassthroughCopy({ "videos": "videos" });
  eleventyConfig.addPassthroughCopy("CNAME");
  eleventyConfig.addPassthroughCopy("design.md"); // Make canonical tokens readable at /design.md

  // --- Collections ---
  eleventyConfig.addCollection("research", (collectionApi) => {
    return collectionApi
      .getFilteredByGlob("content/research/**/*.md")
      .sort((a, b) => new Date(b.data.date) - new Date(a.data.date));
  });

  eleventyConfig.addCollection("reports", (collectionApi) => {
    return collectionApi
      .getFilteredByGlob("content/reports/**/*.md")
      .sort((a, b) => new Date(b.data.date) - new Date(a.data.date));
  });

  // --- Date filter for templates ---
  eleventyConfig.addFilter("isoDate", (d) => {
    if (!d) return "";
    return new Date(d).toISOString().split("T")[0];
  });

  eleventyConfig.addFilter("readableDate", (d) => {
    if (!d) return "";
    return new Date(d).toLocaleDateString("en-US", {
      year: "numeric", month: "long", day: "numeric",
    });
  });

  return {
    dir: {
      input: ".",
      output: "_site",
      includes: "_includes",
      layouts: "_layouts",
      data: "_data",
    },
    templateFormats: ["md", "njk", "html"],
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    pathPrefix: "/",
  };
}
