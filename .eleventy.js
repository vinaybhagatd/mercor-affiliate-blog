const { DateTime } = require("luxon");

module.exports = function(eleventyConfig) {
  // ✅ Passthrough assets (CSS, images, etc.)
  eleventyConfig.addPassthroughCopy("src/assets");

  // ✅ Date filter (fixes "filter not found: date")
  eleventyConfig.addNunjucksFilter("date", function(dateObj, format = "yyyy-LL-dd") {
    if (!dateObj) return "";
    return DateTime.fromJSDate(dateObj).toFormat(format);
  });

  // ✅ Year filter (optional, if used in layouts)
  eleventyConfig.addNunjucksFilter("year", function(dateObj) {
    if (!dateObj) return "";
    return DateTime.fromJSDate(dateObj).toFormat("yyyy");
  });

  // ✅ Categories collection (builds category pages dynamically)
  eleventyConfig.addCollection("categories", function(collectionApi) {
    let categories = new Set();
    collectionApi.getAll().forEach(item => {
      if (item.data.tags) {
        item.data.tags.forEach(tag => categories.add(tag));
      }
    });
    return [...categories];
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
