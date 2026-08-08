#!/usr/bin/env node
const fs = require("fs");
const path = require("path");

const IGNORED_DIRS = new Set([".git", "node_modules", "_site", "output", "affiliate-system"]);
const AFFILIATE_REGEX = /https?:\/\/(?:t\.)?mercor\.com\/[A-Za-z0-9]+|https?:\/\/www\.mercor\.com\/remote-[a-z0-9-]+/gi;

class MercorIndexer {
  constructor(rootDir = process.cwd()) {
    this.rootDir = rootDir;
    this.outputDir = path.join(this.rootDir, "output");
  }

  async run() {
    const files = await this.findMarkdownFiles(this.rootDir);
    const records = await Promise.all(files.map(filePath => this.buildRecord(filePath)));
    const filtered = records.filter(Boolean);

    const linkMap = new Map();
    const categoryMap = new Map();

    filtered.forEach(record => {
      record.affiliateLinks.forEach(link => {
        const entry = linkMap.get(link) || { link, count: 0, sources: [] };
        entry.count += 1;
        if (!entry.sources.includes(record.relativePath)) {
          entry.sources.push(record.relativePath);
        }
        linkMap.set(link, entry);
      });

      record.categories.forEach(category => {
        const entry = categoryMap.get(category) || { category, count: 0, pages: [] };
        entry.count += 1;
        if (!entry.pages.includes(record.relativePath)) {
          entry.pages.push(record.relativePath);
        }
        categoryMap.set(category, entry);
      });
    });

    const index = {
      generatedAt: new Date().toISOString(),
      root: this.rootDir,
      totalFiles: filtered.length,
      totalAffiliateLinks: linkMap.size,
      totalCategories: categoryMap.size,
      affiliateLinks: Array.from(linkMap.values()).sort((a, b) => b.count - a.count || a.link.localeCompare(b.link)),
      categories: Array.from(categoryMap.values()).sort((a, b) => b.count - a.count || a.category.localeCompare(b.category)),
      files: filtered.sort((a, b) => a.relativePath.localeCompare(b.relativePath))
    };

    await fs.promises.mkdir(this.outputDir, { recursive: true });
    await fs.promises.writeFile(path.join(this.outputDir, "mercor-index.json"), JSON.stringify(index, null, 2), "utf8");
    await fs.promises.writeFile(path.join(this.outputDir, "mercor-affiliate-links.md"), this.generateMarkdown(index), "utf8");

    console.log("Mercor indexer completed:");
    console.log("  - output/mercor-index.json");
    console.log("  - output/mercor-affiliate-links.md");
  }

  async findMarkdownFiles(dir) {
    const entries = await fs.promises.readdir(dir, { withFileTypes: true });
    const results = [];

    for (const entry of entries) {
      if (entry.name.startsWith(".") && entry.name !== ".gitignore") {
        if (IGNORED_DIRS.has(entry.name)) {
          continue;
        }
      }

      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (IGNORED_DIRS.has(entry.name)) continue;
        results.push(...await this.findMarkdownFiles(fullPath));
      } else if (entry.isFile() && entry.name.toLowerCase().endsWith(".md")) {
        results.push(fullPath);
      }
    }

    return results;
  }

  async buildRecord(filePath) {
    const raw = await fs.promises.readFile(filePath, "utf8");
    const relativePath = path.relative(this.rootDir, filePath).replace(/\\/g, "/");
    const frontMatter = this.parseFrontMatter(raw);
    const affiliateLinks = this.extractAffiliateLinks(raw);
    const categories = this.normalizeCategories(frontMatter);
    const title = frontMatter.title || path.basename(filePath, ".md");

    return {
      relativePath,
      title,
      categories,
      frontMatter,
      affiliateLinks,
      excerpt: this.extractExcerpt(raw)
    };
  }

  parseFrontMatter(raw) {
    const match = raw.match(/^---\s*\n([\s\S]*?)\n---\s*\n/);
    if (!match) return {};
    const body = match[1];
    const data = {};
    let currentKey = null;

    for (const line of body.split(/\r?\n/)) {
      const trimmed = line.trim();
      if (!trimmed) continue;

      if (/^[A-Za-z0-9_-]+:\s*/.test(trimmed)) {
        const [key, rawValue] = trimmed.split(/:\s*/, 2);
        currentKey = key;
        if (rawValue === "" || rawValue === "|") {
          data[key] = "";
        } else if (rawValue.startsWith("[") && rawValue.endsWith("]")) {
          data[key] = rawValue.slice(1, -1).split(",").map(v => v.trim()).filter(Boolean);
        } else {
          data[key] = rawValue === undefined ? "" : rawValue;
        }
      } else if (/^-\s+/.test(trimmed) && currentKey) {
        const item = trimmed.replace(/^-\s+/, "");
        if (!Array.isArray(data[currentKey])) {
          data[currentKey] = [];
        }
        data[currentKey].push(item);
      }
    }

    return data;
  }

  normalizeCategories(frontMatter) {
    const categories = new Set();
    const values = [];

    if (frontMatter.tags) {
      values.push(...this.normalizeValue(frontMatter.tags));
    }
    if (frontMatter.categories) {
      values.push(...this.normalizeValue(frontMatter.categories));
    }
    if (frontMatter.category) {
      values.push(...this.normalizeValue(frontMatter.category));
    }

    values.forEach(value => {
      const v = String(value).trim().toLowerCase();
      if (v) categories.add(v);
    });

    return Array.from(categories);
  }

  normalizeValue(value) {
    if (Array.isArray(value)) return value;
    if (typeof value === "string") return value.split(/,\s*/).filter(Boolean);
    return [];
  }

  extractAffiliateLinks(raw) {
    const matches = raw.match(AFFILIATE_REGEX) || [];
    return Array.from(new Set(matches.map(link => link.trim())));
  }

  extractExcerpt(raw) {
    const lines = raw.split(/\r?\n/).filter(line => line.trim() && !line.trim().startsWith("---") && !line.trim().startsWith("#"));
    return lines.slice(0, 2).join(" ").trim();
  }

  generateMarkdown(index) {
    const lines = [
      "# Mercor Indexer Generated Affiliate Links",
      "",
      `Generated: ${index.generatedAt}`,
      "",
      "## Affiliate Links",
      "",
    ];

    if (index.affiliateLinks.length === 0) {
      lines.push("No Mercor affiliate links found.");
    } else {
      index.affiliateLinks.forEach(link => {
        lines.push(`- ${link.link} (${link.count} reference${link.count === 1 ? "" : "s"})`);
        link.sources.forEach(source => lines.push(`  - ${source}`));
      });
    }

    lines.push("", "## Categories Found", "",");
    if (index.categories.length === 0) {
      lines.push("No categories found in markdown metadata.");
    } else {
      index.categories.forEach(item => {
        lines.push(`- ${item.category} (${item.count} pages)`);
        item.pages.forEach(page => lines.push(`  - ${page}`));
      });
    }

    lines.push("", "## Indexed Files", "", ...index.files.map(file => {
      const lines = [`- ${file.relativePath}`];
      if (file.categories.length) lines.push(`  - categories: ${file.categories.join(", ")}`);
      if (file.affiliateLinks.length) lines.push(`  - affiliateLinks: ${file.affiliateLinks.join(", ")}`);
      if (file.excerpt) lines.push(`  - excerpt: ${file.excerpt}`);
      return lines.join("\n");
    }));

    return lines.join("\n");
  }
}

if (require.main === module) {
  new MercorIndexer().run().catch(error => {
    console.error("MercorIndexer failed:", error);
    process.exit(1);
  });
}

module.exports = { MercorIndexer };
