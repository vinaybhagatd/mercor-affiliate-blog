module.exports = function(eleventyConfig) {
  // Copy assets directly
  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy(".nojekyll");

  // Create collections for each category
  const categories = [
    "creative", "engineering", "data", "finance", "operations",
    "medicine", "law", "sciences", "arts", "language", "misc"
  ];

  categories.forEach(cat => {
    eleventyConfig.addCollection(cat, function(collectionApi) {
      return collectionApi.getFilteredByTag(cat).sort((a, b) => b.date - a.date);
    });
  });

  // Directory and template engine settings
  return {
    dir: {
      input: "src",
      includes: "_includes",
      layouts: "_layouts",
      output: "_site"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk",
    templateFormats: ["njk", "md"]
  };
};
