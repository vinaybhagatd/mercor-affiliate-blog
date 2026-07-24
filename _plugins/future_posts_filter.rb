# _plugins/future_posts_filter.rb
# Bulletproof future-post filter for Jekyll

module Jekyll
  module FuturePostsFilter

    # Include posts dated today or in the future (UTC-safe)
    def include_future(posts)
      now = Time.now.utc

      posts.select do |post|
        begin
          post_time = post.date.to_time.utc
          post_time >= now - 86400   # allow 24 hours ahead
        rescue
          false
        end
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::FuturePostsFilter)
