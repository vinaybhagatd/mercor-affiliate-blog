const { DateTime } = require("luxon");

module.exports = function(eleventyConfig) {
  eleventyConfig.addPassthroughCopy("src/assets");

  // Allowed categories
  const allowedCategories = [
    "misc",
    "creative",
    "engineering",
    "finance",
    "data",
    "law",
    "medicine",
    "language",
    "operations",
    "sciences",
    "tech"
  ];

  // Dynamic category collections with whitelist
  eleventyConfig.addCollection("categories", function(collection) {
    return collection.getAll().reduce((cats, item) => {
      if(item.data.tags) {
        item.data.tags.forEach(tag => {
          if (allowedCategories.includes(tag)) {
            const slug = eleventyConfig.getFilter("slug")(tag);
            if(!cats[slug]) cats[slug] = [];
            cats[slug].push(item);
          }
        });
      }
      return cats;
    }, {});
  });

  // Render body safely
  eleventyConfig.addFilter("renderBody", function(data) {
    if(data && data.body) return data.body;
    return "";
  });

  // Date filter
  eleventyConfig.addFilter("date", function(dateObj, format = "dd LLL yyyy") {
    return DateTime.fromJSDate(new Date(dateObj)).toFormat(format);
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
