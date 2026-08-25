module.exports = function(eleventyConfig) {

  eleventyConfig.addPassthroughCopy("assets");
  eleventyConfig.addPassthroughCopy(".nojekyll");

  // Unified posts collection: authored + generated
  eleventyConfig.addCollection("posts", function(collectionApi) {
    return [
      // Authored posts
      ...collectionApi.getFilteredByGlob("src/posts/**/*.md"),
      // Generated posts (now inside src)
      ...collectionApi.getFilteredByGlob("src/GeneratedBlogs/*.md")
    ];
  });

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

  categories.forEach(cat => {
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
    }
  };
};
