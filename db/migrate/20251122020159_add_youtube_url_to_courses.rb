class AddYoutubeUrlToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :youtube_url, :string
  end
end
