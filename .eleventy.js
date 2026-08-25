module.exports = function(eleventyConfig) {
  // Copy static assets
  eleventyConfig.addPassthroughCopy("assets");

  // Define categories
  const categories = [
    "creative",
    "engineering",
    "data",
    "finance",
    "operations",
    "medicine",
    "law",
    "sciences",
    "language",
    "misc",
    "tech"
  ];

  // Generate collections for each category
  categories.forEach(category => {
    eleventyConfig.addCollection(category, function(collectionApi) {
      return collectionApi.getFilteredByGlob("src/GeneratedBlogs/**/*.md")
        .filter(item => item.data.category && item.data.category.toLowerCase() === category);
    });
  });

  // Default Eleventy config
  return {
    dir: {
      input: "src",
      includes: "_includes",
      data: "_data",
      output: "_site"
    },
    markdownTemplateEngine: "liquid",
    htmlTemplateEngine: "njk",
    dataTemplateEngine: "njk",
    passthroughFileCopy: true
  };
};
