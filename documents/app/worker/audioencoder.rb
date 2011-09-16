class Audioencoder
  @queue = :audios_queue
  def self.perform(audio_id)
    audio = Audio.find(audio_id)
    Audio.file.reprocess!
  end
end