const { DateTime } = require("luxon");

module.exports = function(eleventyConfig) {
  // ✅ Passthrough assets (CSS, images, etc.)
  eleventyConfig.addPassthroughCopy("src/assets");

  // ✅ Date filter (fixes "filter not found: date")
  eleventyConfig.addNunjucksFilter("date", function(dateObj, format = "yyyy-LL-dd") {
    if (!dateObj) return "";
    try {
      if (dateObj instanceof Date) {
        return DateTime.fromJSDate(dateObj, { zone: "utc" }).toFormat(format);
      }
      return DateTime.fromISO(dateObj, { zone: "utc" }).toFormat(format);
    } catch {
      return "";
    }
  });

  // ✅ Year filter (optional, if used in layouts)
  eleventyConfig.addNunjucksFilter("year", function(dateObj) {
    if (!dateObj) return "";
    try {
      if (dateObj instanceof Date) {
        return DateTime.fromJSDate(dateObj, { zone: "utc" }).toFormat("yyyy");
      }
      return DateTime.fromISO(dateObj, { zone: "utc" }).toFormat("yyyy");
    } catch {
      return "";
    }
  });

  // ✅ Dynamic categories collection (builds category list automatically)
  eleventyConfig.addCollection("categories", function(collectionApi) {
    let categories = new Set();
    collectionApi.getAll().forEach(item => {
      if (item.data.tags) {
        item.data.tags.forEach(tag => categories.add(tag));
      }
    });
    return [...categories];
  });

  // ✅ Explicit category collections (ensures all 11 categories exist)
  const categoryList = [
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
  ];

  categoryList.forEach(category => {
    eleventyConfig.addCollection(category, function(collectionApi) {
      return collectionApi.getFilteredByTag(category);
    });
  });

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes",
      layouts: "_layouts"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk"
  };
};

eleventyConfig.addShortcode("affLink", function(productId, text) {
  return `<a href="https://affiliate.example.com/${productId}?affid=12345" target="_blank">${text}</a>`;
});
