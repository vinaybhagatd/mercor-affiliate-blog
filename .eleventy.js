const { DateTime } = require("luxon");

module.exports = function(eleventyConfig) {
  // ✅ Passthrough copy for static assets
  eleventyConfig.addPassthroughCopy("src/assets");

  // ✅ Custom date filter using Luxon
  eleventyConfig.addFilter("date", (dateObj, format = "yyyy-LL-dd") => {
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

  // ✅ Strict dynamic categories collection (only 11 allowed)
  const allowedCategories = [
    "creative","data","engineering","finance","language",
    "law","medicine","misc","operations","sciences","tech"
  ];

  eleventyConfig.addCollection("categories", function(collectionApi) {
    const categories = {};
    collectionApi.getAll().forEach(item => {
      if (item.data && item.data.tags) {
        item.data.tags.forEach(tag => {
          if (allowedCategories.includes(tag)) {
            if (!categories[tag]) {
              categories[tag] = [];
            }
            categories[tag].push(item);
          }
        });
      }
    });
    return categories;
  });

  // ✅ Explicit collections for the 11 canonical categories
  allowedCategories.forEach(cat => {
    eleventyConfig.addCollection(cat, function(collectionApi) {
      return collectionApi.getFilteredByTag(cat);
    });
  });

  return {
    dir: {
      input: "src",
      includes: "_includes",
      layouts: "_layouts",
      output: "_site"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk"
  };
};
