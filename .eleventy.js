module.exports = function(eleventyConfig) {

  // Copy assets directly
  eleventyConfig.addPassthroughCopy("assets");

  // Create collections for each category
  const categories = [
    "creative", "engineering", "data", "finance", "operations",
    "medicine", "law", "sciences", "arts", "language", "misc"
  ];

  categories.forEach(cat => {
    eleventyConfig.addCollection(cat, function(collection) {
      return collection.getFilteredByTag(cat);
    });
  });

  return {
    dir: {
      input: "src",
      includes: "_includes",
      layouts: "_layouts",
      output: "_site"
    }
  };
};
