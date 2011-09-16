class Videoencoder
  @queue = :videos_queue
  def self.perform(video_id)
    video = Video.find(video_id)
    video.file.reprocess!
  end
end